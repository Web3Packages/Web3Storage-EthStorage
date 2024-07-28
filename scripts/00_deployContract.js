
const hre = require("hardhat");


// 0xf5E92c452BC65073dAD94F3432c15ee1BB840FfF deploy on 2024.07.28 08:55 at sepolia
async function depoly(){
  const Protocol = await hre.ethers.deployContract("FlatDirectory",[0, 0, "0x0000000000000000000000000000000000000000"]);
  await Protocol.waitForDeployment();
  console.log(`FlatDirectory done:  ${await Protocol.target}`);
  return  Protocol;
}

depoly()
