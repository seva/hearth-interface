import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying Crowdsale with account:", deployer.address);

  // Configuration
  // Base Sepolia Addresses (from MEMORY.md)
  const TOKEN_ADDRESS = "0x7808D5b2F6615041B94B344b2C7Df6bd63A1Fcca";
  // USDC on Base Sepolia: 0x036CbD53842c5426634e7929541eC2318f3dCF7e (Official Circle Testnet USDC)
  const USDC_ADDRESS = "0x036CbD53842c5426634e7929541eC2318f3dCF7e";
  
  // Rate: 10 HRTH PER 1 USDC.
  // 1 USDC (1e6) -> 10 HRTH (10e18)
  // Input: 1e6. Output: 1e19.
  // Formula: tokenAmount = usdcAmount * Rate
  // 1e19 = 1e6 * Rate
  // Rate = 1e13
  const RATE = 10000000000000n; // 1e13

  console.log(`Using Token: ${TOKEN_ADDRESS}`);
  console.log(`Using USDC: ${USDC_ADDRESS}`);
  console.log(`Rate: ${RATE} (1 USDC = 10 HRTH)`);

  // Deploy Crowdsale
  const HearthCrowdsale = await ethers.getContractFactory("HearthCrowdsale");
  const crowdsale = await HearthCrowdsale.deploy(
    deployer.address, // Initial Owner
    TOKEN_ADDRESS,
    USDC_ADDRESS,
    RATE
  );

  await crowdsale.waitForDeployment();
  const crowdsaleAddress = await crowdsale.getAddress();
  console.log(`HearthCrowdsale deployed to: ${crowdsaleAddress}`);

  // Fund Crowdsale
  // Transfer 100,000 HRTH from Deployer to Crowdsale contract
  const FUND_AMOUNT = ethers.parseEther("100000"); // 100k Tokens
  console.log(`Funding Crowdsale with ${ethers.formatEther(FUND_AMOUNT)} HRTH...`);
  
  const token = await ethers.getContractAt("HearthToken", TOKEN_ADDRESS);
  const tx = await token.transfer(crowdsaleAddress, FUND_AMOUNT);
  await tx.wait();
  
  console.log(`Funding successful. Tx: ${tx.hash}`);
  console.log(`Crowdsale Balance: ${ethers.formatEther(await token.balanceOf(crowdsaleAddress))}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
