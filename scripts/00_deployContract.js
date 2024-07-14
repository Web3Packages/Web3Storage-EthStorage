
const hre = require("hardhat");

// 0x5d0b47BDD72265C0443D6F96065aA45c24677F04 deploy on 2024.07.07 15:00 at sepolia
async function depoly(){
  const Protocol = await hre.ethers.deployContract("FlatDirectory",[0, 0, "0x0000000000000000000000000000000000000000"]);
  await Protocol.waitForDeployment();
  console.log(`FlatDirectory done:  ${await Protocol.target}`);
  return  Protocol;
}

depoly()
