const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // 1. Deploy Token
  const HearthToken = await hre.ethers.getContractFactory("HearthToken");
  // const token = await HearthToken.deploy();
  // await token.waitForDeployment();
  // const tokenAddress = await token.getAddress();
  const tokenAddress = "0xE03351070DF51Faf3eddAeb975fce169749c7007";
  const token = HearthToken.attach(tokenAddress); // Attach to existing
  console.log(`HearthToken deployed to: ${tokenAddress}`);

  // 2. Deploy Timelock
  // Min delay: 1 day (86400 seconds)
  // Proposers: [], Executors: [] (Will assume Governor is proposer, anyone can execute or restricted)
  // Admin: Deployer (temporarily, then renounced to Timelock itself)
  const MIN_DELAY = 86400; 
  const HearthTimelock = await hre.ethers.getContractFactory("HearthTimelock");
  // const timelock = await HearthTimelock.deploy(MIN_DELAY, [], [], deployer.address, {
  //   maxFeePerGas: 8000000,
  //   maxPriorityFeePerGas: 1500000
  // });
  // await timelock.waitForDeployment();
  const timelockAddress = "0x171E4E986ADDD4C81Ac0f10f96eAcb2688E8958a";
  const timelock = HearthTimelock.attach(timelockAddress);
  console.log(`HearthTimelock deployed to: ${timelockAddress}`);

  // 3. Deploy Governor
  const HearthGovernor = await hre.ethers.getContractFactory("HearthGovernor");
  // const governor = await HearthGovernor.deploy(tokenAddress, timelockAddress, {
  //   maxFeePerGas: 8000000,
  //   maxPriorityFeePerGas: 1500000
  // });
  // await governor.waitForDeployment();
  const governorAddress = "0x69B56F01098e800b836e6e8ebC1538c8E7808B47"
  const governor = HearthGovernor.attach(governorAddress);
  console.log(`HearthGovernor deployed to: ${governorAddress}`);

  // 4. Setup Roles
  // Grant Proposer role to Governor
  const PROPOSER_ROLE = await timelock.PROPOSER_ROLE();
  const EXECUTOR_ROLE = await timelock.EXECUTOR_ROLE();
  const CANCELLER_ROLE = await timelock.CANCELLER_ROLE();
  const ADMIN_ROLE = await timelock.DEFAULT_ADMIN_ROLE();

  console.log("Setting up Timelock roles...");
  let tx;
  // tx = await timelock.grantRole(PROPOSER_ROLE, governorAddress, {maxFeePerGas: 10000000, maxPriorityFeePerGas: 2000000});
  // await tx.wait();
  // console.log("Granted PROPOSER_ROLE to Governor");

  // tx = await timelock.grantRole(EXECUTOR_ROLE, "0x0000000000000000000000000000000000000000", {maxFeePerGas: 12000000, maxPriorityFeePerGas: 2500000}); // Anyone can execute
  // await tx.wait();
  // console.log("Granted EXECUTOR_ROLE to wildcard");

  // tx = await timelock.revokeRole(ADMIN_ROLE, deployer.address, {maxFeePerGas: 30000000, maxPriorityFeePerGas: 5000000}); // Revoke admin from deployer
  // await tx.wait();
  console.log("Timelock roles setup complete. Admin revoked.");

  // 5. Delegate votes to self (optional for testing, mandatory for governance)
  tx = await token.delegate(deployer.address, {maxFeePerGas: 40000000, maxPriorityFeePerGas: 8000000});
  await tx.wait();
  console.log("Delegated votes to deployer");
  console.log("Delegated votes to deployer");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
