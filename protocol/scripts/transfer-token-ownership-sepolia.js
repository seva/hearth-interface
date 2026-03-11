const { ethers } = require("hardhat");
const fs = require("fs");

async function main() {
  console.log('--- Transferring Token Balance to Safe ---');
  let safeAddress;
  try {
    const safeData = JSON.parse(fs.readFileSync('sepolia-safe.json', 'utf8'));
    safeAddress = safeData.safeAddress;
  } catch(e) {
    throw new Error("Could not read sepolia-safe.json. Run deploy-safe-sepolia.js first.");
  }
  
  const tokenAddress = "0x27cfe8EdF0B8D2Af78F9668fD35aA96b612FEEDe";
  const token = await ethers.getContractAt("HearthToken", tokenAddress);
  
  const [deployer] = await ethers.getSigners();
  console.log("Deployer:", deployer.address);
  console.log("Note: HearthToken does not inherit Ownable, so 'transfer ownership' means transferring the treasury balance.");
  
  const balance = await token.balanceOf(deployer.address);
  console.log("Deployer Balance:", ethers.formatUnits(balance, 18), "HRTH");
  
  if (balance > 0n) {
    console.log(`Transferring ${ethers.formatUnits(balance, 18)} HRTH to Safe ${safeAddress}...`);
    const tx = await token.transfer(safeAddress, balance);
    await tx.wait();
    console.log("✅ Transfer complete! Tx Hash:", tx.hash);
  } else {
    console.log("No balance to transfer. Token balance already transferred.");
  }
}

main().catch(console.error);
