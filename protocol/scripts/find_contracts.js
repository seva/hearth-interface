
const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log(`Scanner: ${deployer.address}`);
  const nonce = await hre.ethers.provider.getTransactionCount(deployer.address);
  console.log(`Nonce: ${nonce}`);

  if (nonce === 0) console.log("No transactions sent yet.");

  // Iterate backwards to find recent deployments
  const start = Math.max(0, nonce - 10); 
  for (let i = start; i < nonce; i++) {
    try {
      const addr = hre.ethers.getCreateAddress({ from: deployer.address, nonce: i });
      const code = await hre.ethers.provider.getCode(addr);
      
      if (code && code !== "0x") {
        console.log(`[Nonce ${i}] 📄 Contract: ${addr} (Code size: ${(code.length-2)/2})`);
      } else {
        console.log(`[Nonce ${i}] 💸 Transaction (Not Contract Creation)`);
      }
    } catch (e) {
      console.log(`[Nonce ${i}] Error: ${e.message}`);
    }
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
