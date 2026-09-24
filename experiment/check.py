from pathlib import Path
import re

ROOT=Path(__file__).parent
source=(ROOT/"source.txt").read_text()
candidates=ROOT/"candidates"

# This first smoke test is deliberately mechanical:
# it does not decide what Maimonides means. It checks whether a candidate
# preserves required source terms and whether it introduces terms absent
# from the source.
required=["המקרה","שני זמנים","מקרה אחר"]
results=[]
for p in sorted(candidates.glob("*.txt")):
    text=p.read_text()
    missing=[x for x in required if x not in text]
    source_words=set(re.findall(r"[א-ת]{3,}",source))
    candidate_words=set(re.findall(r"[א-ת]{3,}",text))
    invented=sorted(candidate_words-source_words)
    results.append((p.name,missing,invented))

for name,missing,invented in results:
    print(f"== {name} ==")
    print("MISSING:", " | ".join(missing) if missing else "none")
    print("NEW_WORDS:", " | ".join(invented) if invented else "none")

assert dict((n,m) for n,m,i in results)["correct.txt"]==[]
assert "מקרה אחר" in (candidates/"correct.txt").read_text()
assert dict((n,m) for n,m,i in results)["omission.txt"]!=[]

print("\nSMOKE TEST: PASS")
