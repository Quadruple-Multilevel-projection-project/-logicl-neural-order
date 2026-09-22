// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
contract AgentIdentityRegistry {
 struct AgentIdentity { bytes32 tzerufHash; bytes publicKey; bytes32 provenanceSeal; uint64 registrationTimestamp; uint8 capacityScore; bool isActive; }
 mapping(address=>AgentIdentity) public agents; mapping(bytes32=>bool) public usedTzerufRoots; address public immutable orchestrator;
 event AgentRegistered(address indexed agent,bytes32 indexed tzerufHash); event AgentQuarantined(address indexed agent,string reason);
 modifier onlyOrchestrator(){require(msg.sender==orchestrator,"Registry: orchestrator only");_;}
 constructor(){orchestrator=msg.sender;}
 function registerAgent(address agent,string calldata tzerufLiteral,bytes calldata publicKey,bytes32 provenanceSeal,uint8 capacityScore) external onlyOrchestrator {
  require(!agents[agent].isActive,"Registry: already active"); require(capacityScore<=100,"Registry: bad capacity");
  bytes32 h=keccak256(bytes(tzerufLiteral)); require(!usedTzerufRoots[h],"Registry: root already used");
  agents[agent]=AgentIdentity(h,publicKey,provenanceSeal,uint64(block.timestamp),capacityScore,true); usedTzerufRoots[h]=true; emit AgentRegistered(agent,h);
 }
 function quarantineAgent(address agent,string calldata reason) external onlyOrchestrator {require(agents[agent].isActive,"Registry: inactive");agents[agent].isActive=false;agents[agent].capacityScore=0;emit AgentQuarantined(agent,reason);}
 function verifyAgentProvenance(address agent,bytes32 sourceRef) external view returns(bool){AgentIdentity memory a=agents[agent];return a.isActive&&a.provenanceSeal==sourceRef;}
 function getAgentCapacity(address agent) external view returns(uint8){return agents[agent].capacityScore;}
 function isActive(address agent) external view returns(bool){return agents[agent].isActive;}
}