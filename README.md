# TNRL Agent Bank Sandbox

This branch contains the first coherent sandbox deployment layer for the TNRL/Tzeruf agent architecture.

## Components
- AgentIdentityRegistry
- OntologicalCoin (TZERO)
- TzerufChainCore
- AgentCommercialBank
- deterministic 100,000-agent simulator
- 21^3 topology state and architecture snapshot

## Local run
npm install
npx hardhat compile
npx hardhat node
npx hardhat run scripts/deploy_agent_bank.js --network localhost
python3 sim/simulate_100k.py

## Boundary
The 100,000-agent layer is a deterministic simulation. No public-chain deployment is claimed. Contracts are an unaudited prototype.
