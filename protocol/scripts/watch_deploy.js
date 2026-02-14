
const hre = require("hardhat");
const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function main() {
  console.log("Starting L2 Fund Watcher...");
  const target = 0.01;

  for (let i = 0; i < 40; i++) {
    const [deployer] = await hre.ethers.getSigners();
    const balance = await hre.ethers.provider.getBalance(deployer.address);
    const eth = parseFloat(hre.ethers.formatEther(balance));
    
    process.stdout.write(`Attempt ${i+1}: ${eth} ETH... `);

    if (eth >= target) {
      console.log("\n💰 Funds Arrived! Deploying...");
      await hre.run("run", { script: "scripts/deploy.js" });
      console.log("✅ DEPLOYMENT COMPLETE");
      return;
    }
    console.log("Waiting...");
    await sleep(30000); // 30s
  }
  console.log("\n❌ TIMEOUT");
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
