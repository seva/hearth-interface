import { ethers } from "hardhat";
require("dotenv").config();

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Redeploying Full Stack with:", deployer.address);

  // 1. Deploy Token
  const HearthToken = await ethers.getContractFactory("HearthToken");
  const token = await HearthToken.deploy();
  await token.waitForDeployment();
  const tokenAddr = await token.getAddress();
  console.log(`HearthToken: ${tokenAddr}`);

  // 2. Deploy Timelock
  const MIN_DELAY = 86400; // 1 day
  const HearthTimelock = await ethers.getContractFactory("HearthTimelock");
  const timelock = await HearthTimelock.deploy(MIN_DELAY, [], [], deployer.address);
  await timelock.waitForDeployment();
  const timelockAddr = await timelock.getAddress();
  console.log(`HearthTimelock: ${timelockAddr}`);

  // 3. Deploy Governor
  const HearthGovernor = await ethers.getContractFactory("HearthGovernor");
  const governor = await HearthGovernor.deploy(tokenAddr, timelockAddr);
  await governor.waitForDeployment();
  const governorAddr = await governor.getAddress();
  console.log(`HearthGovernor: ${governorAddr}`);

  // 4. Deploy Crowdsale
  // Rate 1 USDC = 10 HRTH. 1e13 rate.
  const STRATEGY_USDC = "0x036CbD53842c5426634e7929541eC2318f3dCF7e";
  const RATE = 10000000000000n; 
  const HearthCrowdsale = await ethers.getContractFactory("HearthCrowdsale");
  const crowdsale = await HearthCrowdsale.deploy(deployer.address, tokenAddr, STRATEGY_USDC, RATE);
  await crowdsale.waitForDeployment();
  const crowdsaleAddr = await crowdsale.getAddress();
  console.log(`HearthCrowdsale: ${crowdsaleAddr}`);

  // 5. Fund Crowdsale (100k HRTH)
  console.log("Funding Crowdsale...");
  const fundTx = await token.transfer(crowdsaleAddr, ethers.parseEther("100000"));
  await fundTx.wait();
  console.log("Funded.");
  
  // 6. Setup Governor Roles
  const PROPOSER_ROLE = await timelock.PROPOSER_ROLE();
  const EXECUTOR_ROLE = await timelock.EXECUTOR_ROLE();
  const ADMIN_ROLE = await timelock.DEFAULT_ADMIN_ROLE();

  console.log("Setting up roles...");
  await timelock.grantRole(PROPOSER_ROLE, governorAddr);
  await timelock.grantRole(EXECUTOR_ROLE, ethers.ZeroAddress);
  await timelock.revokeRole(ADMIN_ROLE, deployer.address);
  console.log("Roles done.");
  
  // 7. Delegate Votes
  await token.delegate(deployer.address);
  console.log("Delegated votes.");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
