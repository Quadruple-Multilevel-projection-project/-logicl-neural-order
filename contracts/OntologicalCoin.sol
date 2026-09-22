// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./AgentIdentityRegistry.sol";
contract OntologicalCoin is ERC20 {
 AgentIdentityRegistry public immutable registry; address public immutable orchestrator;
 modifier onlyOrchestrator(){require(msg.sender==orchestrator,"TZERO: orchestrator only");_;}
 constructor(address registry_) ERC20("Ontological Coin","TZERO"){registry=AgentIdentityRegistry(registry_);orchestrator=msg.sender;}
 function mintReward(address recipient,uint256 amount,bytes32 sourceRef) external onlyOrchestrator {require(registry.verifyAgentProvenance(recipient,sourceRef),"TZERO: provenance gate failed");_mint(recipient,amount);}
}