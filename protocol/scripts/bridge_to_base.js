
const hre = require("hardhat");

async function main() {
  const BRIDGE_ADDRESS = "0xfd0Bf71F60660E2f608ed56e1659C450eB113120"; // Base Sepolia L1StandardBridgeProxy
  const AMOUNT_TO_BRIDGE = hre.ethers.parseEther("0.05"); // 0.05 ETH
  const MIN_GAS_LIMIT = 200000; // 200k gas min for L2 execution
  const EXTRA_DATA = "0x"; // No extra data

  const [deployer] = await hre.ethers.getSigners();
  console.log("Bridging from account:", deployer.address);
  
  const balance = await hre.ethers.provider.getBalance(deployer.address);
  console.log("Current L1 Balance:", hre.ethers.formatEther(balance), "ETH");

  if (balance < AMOUNT_TO_BRIDGE) {
    throw new Error("Insufficient balance on L1 to bridge 0.05 ETH + gas.");
  }

  // Minimal ABI for depositETH
  const abi = [
    "function depositETH(uint32 _minGasLimit, bytes calldata _extraData) external payable"
  ];

  const bridge = new hre.ethers.Contract(BRIDGE_ADDRESS, abi, deployer);

  console.log(`Initiating bridge of 0.05 ETH to Base Sepolia...`);
  console.log(`Target Bridge Contract: ${BRIDGE_ADDRESS}`);

  const tx = await bridge.depositETH(MIN_GAS_LIMIT, EXTRA_DATA, {
    value: AMOUNT_TO_BRIDGE
  });

  console.log("Transaction sent:", tx.hash);
  console.log("Waiting for confirmation on L1...");
  
  await tx.wait();

  console.log("✅ Bridge transaction confirmed on L1!");
  console.log("🔗 Etherscan: https://sepolia.etherscan.io/tx/" + tx.hash);
  console.log("⏳ Funds should arrive on Base Sepolia in 2-5 minutes.");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
