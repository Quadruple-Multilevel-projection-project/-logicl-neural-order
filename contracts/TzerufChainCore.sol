// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./AgentIdentityRegistry.sol";
import "./OntologicalCoin.sol";
contract TzerufChainCore {
 struct Block {uint256 blockNumber;bytes32 previousHash;bytes32 tzerufRootHash;string tzerufLiteral;address minerAgent;uint256 timestamp;bytes32 stateRoot;}
 AgentIdentityRegistry public immutable registry; OntologicalCoin public immutable coin; address public immutable orchestrator;
 uint256 public currentBlockNumber; uint256 public constant MIN_CAPACITY_SCORE=85; uint256 public constant MINT_REWARD_AMOUNT=100 ether;
 mapping(uint256=>Block) public chain; mapping(bytes32=>bool) public usedTzerufRoots;
 event TzerufBlockMined(uint256 indexed blockNumber,bytes32 indexed tzerufHash,address indexed miner,bytes32 stateRoot);
 constructor(address registry_,address coin_){orchestrator=msg.sender;registry=AgentIdentityRegistry(registry_);coin=OntologicalCoin(coin_);bytes32 genesis=keccak256(abi.encodePacked("GENESIS_TZERUF_ROOT_001"));chain[0]=Block(0,bytes32(0),genesis,"ALEF-TAV-INITIAL",msg.sender,block.timestamp,keccak256(abi.encodePacked("GENESIS_STATE")));usedTzerufRoots[genesis]=true;}
 function mineTzerufBlock(string calldata tzerufLiteral,bytes32 stateRoot) external {
  require(registry.isActive(msg.sender),"Core: inactive agent"); require(registry.getAgentCapacity(msg.sender)>=MIN_CAPACITY_SCORE,"Core: capacity below threshold");
  bytes32 tzerufHash=keccak256(bytes(tzerufLiteral)); require(!usedTzerufRoots[tzerufHash],"Core: combination already used");
  Block memory latest=chain[currentBlockNumber]; bytes32 previousHash=keccak256(abi.encode(latest.blockNumber,latest.previousHash,latest.tzerufRootHash,latest.stateRoot,latest.timestamp));
  currentBlockNumber++; chain[currentBlockNumber]=Block(currentBlockNumber,previousHash,tzerufHash,tzerufLiteral,msg.sender,block.timestamp,stateRoot); usedTzerufRoots[tzerufHash]=true;
  coin.mintReward(msg.sender,MINT_REWARD_AMOUNT,tzerufHash); emit TzerufBlockMined(currentBlockNumber,tzerufHash,msg.sender,stateRoot);
 }
 function getLatestBlock() external view returns(Block memory){return chain[currentBlockNumber];}
}