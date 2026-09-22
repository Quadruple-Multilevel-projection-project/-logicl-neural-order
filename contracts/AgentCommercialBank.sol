// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./AgentIdentityRegistry.sol";
import "./OntologicalCoin.sol";
contract AgentCommercialBank {
 AgentIdentityRegistry public immutable registry; OntologicalCoin public immutable coin; address public immutable orchestrator;
 event Settlement(address indexed from,address indexed to,uint256 amount);
 modifier onlyOrchestrator(){require(msg.sender==orchestrator,"Bank: orchestrator only");_;}
 constructor(address registry_,address coin_){orchestrator=msg.sender;registry=AgentIdentityRegistry(registry_);coin=OntologicalCoin(coin_);}
 function settle(address from,address to,uint256 amount) external onlyOrchestrator {require(registry.isActive(from),"Bank: sender inactive");require(registry.isActive(to),"Bank: receiver inactive");require(coin.transferFrom(from,to,amount),"Bank: transfer failed");emit Settlement(from,to,amount);}
}