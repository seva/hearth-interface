const { run } = require("hardhat");

const TOKEN = "0x27cfe8EdF0B8D2Af78F9668fD35aA96b612FEEDe";
const TIMELOCK = "0xc13E5FFaE89324fA5bb2eb7cB2a021aB15d71d6F";
const GOVERNOR = "0x70C5A7d5FBc03DeCBB15332BE384791645041387";
const CROWDSALE = "0xef990083409741011b6ed280a1519D75De8F8012";

const DEPLOYER = "0x970f85f53f78A3dA7a1b70dFfD95Df4847b24859";
const MIN_DELAY = 86400;

// CROWDSALE ARGS
const STRATEGY_USDC = "0x036CbD53842c5426634e7929541eC2318f3dCF7e";
const RATE = "10000000000000"; // 1e13

async function main() {
  console.log("Verifying Timelock...");
  try {
    await run("verify:verify", {
      address: TIMELOCK,
      constructorArguments: [MIN_DELAY, [], [], DEPLOYER],
      contract: "contracts/HearthTimelock.sol:HearthTimelock"
    });
  } catch (e) {
      console.log("Timelock error:", e.message);
  }

  console.log("Verifying Governor...");
  try {
    await run("verify:verify", {
      address: GOVERNOR,
      constructorArguments: [TOKEN, TIMELOCK],
      contract: "contracts/HearthGovernor.sol:HearthGovernor"
    });
  } catch (e) {
      console.log("Governor error:", e.message);
  }

  console.log("Verifying Crowdsale...");
  try {
    await run("verify:verify", {
      address: CROWDSALE,
      constructorArguments: [DEPLOYER, TOKEN, STRATEGY_USDC, RATE],
      contract: "contracts/Crowdsale.sol:HearthCrowdsale"
    });
  } catch (e) {
      console.log("Crowdsale error:", e.message);
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});