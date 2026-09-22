const {ethers}=require("hardhat");
async function main(){const [deployer]=await ethers.getSigners();console.log("TNRL sandbox deployer:",deployer.address);
 const R=await ethers.getContractFactory("AgentIdentityRegistry");const registry=await R.deploy();await registry.waitForDeployment();
 const C=await ethers.getContractFactory("OntologicalCoin");const coin=await C.deploy(await registry.getAddress());await coin.waitForDeployment();
 const Core=await ethers.getContractFactory("TzerufChainCore");const core=await Core.deploy(await registry.getAddress(),await coin.getAddress());await core.waitForDeployment();
 const B=await ethers.getContractFactory("AgentCommercialBank");const bank=await B.deploy(await registry.getAddress(),await coin.getAddress());await bank.waitForDeployment();
 console.log(JSON.stringify({registry:await registry.getAddress(),coin:await coin.getAddress(),core:await core.getAddress(),bank:await bank.getAddress()},null,2));}
main().catch(e=>{console.error(e);process.exitCode=1;});