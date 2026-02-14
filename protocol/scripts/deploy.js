const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // 1. Deploy Token
  const HearthToken = await hre.ethers.getContractFactory("HearthToken");
  const token = await HearthToken.deploy();
  await token.waitForDeployment();
  const tokenAddress = await token.getAddress();
  console.log(`HearthToken deployed to: ${tokenAddress}`);

  // 2. Deploy Timelock
  // Min delay: 1 day (86400 seconds)
  // Proposers: [], Executors: [] (Will assume Governor is proposer, anyone can execute or restricted)
  // Admin: Deployer (temporarily, then renounced to Timelock itself)
  const MIN_DELAY = 86400; 
  const HearthTimelock = await hre.ethers.getContractFactory("HearthTimelock");
  const timelock = await HearthTimelock.deploy(MIN_DELAY, [], [], deployer.address);
  await timelock.waitForDeployment();
  const timelockAddress = await timelock.getAddress();
  console.log(`HearthTimelock deployed to: ${timelockAddress}`);

  // 3. Deploy Governor
  const HearthGovernor = await hre.ethers.getContractFactory("HearthGovernor");
  const governor = await HearthGovernor.deploy(tokenAddress, timelockAddress);
  await governor.waitForDeployment();
  const governorAddress = await governor.getAddress();
  console.log(`HearthGovernor deployed to: ${governorAddress}`);

  // 4. Setup Roles
  // Grant Proposer role to Governor
  const PROPOSER_ROLE = await timelock.PROPOSER_ROLE();
  const EXECUTOR_ROLE = await timelock.EXECUTOR_ROLE();
  const CANCELLER_ROLE = await timelock.CANCELLER_ROLE();
  const ADMIN_ROLE = await timelock.DEFAULT_ADMIN_ROLE();

  console.log("Setting up Timelock roles...");
  await timelock.grantRole(PROPOSER_ROLE, governorAddress);
  await timelock.grantRole(EXECUTOR_ROLE, "0x0000000000000000000000000000000000000000"); // Anyone can execute
  await timelock.revokeRole(ADMIN_ROLE, deployer.address); // Revoke admin from deployer
  console.log("Timelock roles setup complete. Admin revoked.");

  // 5. Delegate votes to self (optional for testing, mandatory for governance)
  await token.delegate(deployer.address);
  console.log("Delegated votes to deployer");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
