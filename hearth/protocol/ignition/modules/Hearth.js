const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("HearthProtocol", (m) => {
  // 1. Deploy Token
  const token = m.contract("HearthToken");

  // 2. Deploy Timelock
  // Min Delay: 1 day (86400)
  // Proposers: [] (Governor will be added later)
  // Executors: [] (Open to all?) usually [] means restricted, [address(0)] means all.
  // Admin: Deployer (initially)
  const minDelay = 86400;
  const proposers = [];
  const executors = []; 
  const admin = m.getAccount(0);

  const timelock = m.contract("Timelock", [minDelay, proposers, executors, admin]);

  // 3. Deploy Governor
  // Token: HearthToken
  // Timelock: Timelock
  const governor = m.contract("HearthGovernor", [token, timelock]);

  return { token, timelock, governor };
});
