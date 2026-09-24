"""External epistemic instrument: LLM proposes; deterministic layers check and preserve state.

The instrument deliberately does not claim that the model itself understands or reasons.
It turns a model call into a reproducible pipeline with explicit names, claims,
dependencies, objections, and tests.
"""

from dataclasses import dataclass, field
from typing import Callable, Iterable, Optional
import re


@dataclass
class Claim:
    text: str
    status: str = "unverified"
    evidence: list[str] = field(default_factory=list)
    parent_ids: list[int] = field(default_factory=list)


@dataclass
class Turn:
    prompt: str
    answer: str
    claims: list[Claim]


class Lexicon:
    def __init__(self, definitions: Optional[dict[str, str]] = None):
        self.definitions = definitions or {}

    def define(self, name: str, definition: str) -> None:
        self.definitions[name] = definition

    def check(self, text: str) -> list[str]:
        unknown = []
        for quoted in re.findall(r"["“”']([^"“”']+)["“”']", text):
            if len(quoted.split()) <= 5 and quoted not in self.definitions:
                unknown.append(quoted)
        return unknown


class ClaimLedger:
    def __init__(self):
        self.claims: list[Claim] = []

    def add(self, claim: Claim) -> int:
        self.claims.append(claim)
        return len(self.claims) - 1

    def unresolved(self) -> list[int]:
        return [i for i, c in enumerate(self.claims) if c.status == "unverified"]

    def contradictions(self, checker: Callable[[str, str], bool]) -> list[tuple[int, int]]:
        out = []
        for i, a in enumerate(self.claims):
            for j in range(i + 1, len(self.claims)):
                if checker(a.text, self.claims[j].text):
                    out.append((i, j))
        return out


class Instrument:
    """A small, model-agnostic scaffold for testing whether external structure helps."""

    def __init__(self, model: Callable[[str], str], lexicon: Lexicon):
        self.model = model
        self.lexicon = lexicon
        self.ledger = ClaimLedger()
        self.history: list[Turn] = []

    def run(self, question: str) -> Turn:
        answer = self.model(self._prompt(question))
        claims = [Claim(text=s.strip()) for s in self._sentences(answer) if s.strip()]
        for c in claims:
            self.ledger.add(c)
        turn = Turn(question, answer, claims)
        self.history.append(turn)
        return turn

    def _prompt(self, question: str) -> str:
        known = "\n".join(f"- {k}: {v}" for k, v in self.lexicon.definitions.items())
        return (
            "Answer only from the supplied vocabulary when possible. "
            "Separate observation, inference, and unknown. Do not invent definitions.\n"
            f"VOCABULARY:\n{known}\nQUESTION:\n{question}"
        )

    @staticmethod
    def _sentences(text: str) -> Iterable[str]:
        return re.split(r"(?<=[.!?])\s+|\n+", text.strip())


def format_audit(turn: Turn, lexicon: Lexicon) -> str:
    unknown = lexicon.check(turn.answer)
    lines = [
        "AUDIT",
        f"claims={len(turn.claims)}",
        f"unknown_quoted_terms={unknown}",
        "claim_statuses=" + ",".join(c.status for c in turn.claims),
    ]
    return "\n".join(lines)
