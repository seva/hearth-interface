import { ethers } from "hardhat";
import { expect } from "chai";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { time } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("HearthGovernor", function () {
  async function deployContracts() {
    const [deployer, otherUser] = await ethers.getSigners();

    // Deploy HearthToken
    const HearthToken = await ethers.getContractFactory("HearthToken");
    const token = await HearthToken.deploy();

    // Deploy HearthTimelock
    const HearthTimelock = await ethers.getContractFactory("HearthTimelock");
    const timelock = await HearthTimelock.deploy(3600, [], [], deployer.address);

    // Deploy HearthGovernor
    const HearthGovernor = await ethers.getContractFactory("HearthGovernor");
    const governor = await HearthGovernor.deploy(token.getAddress(), timelock.getAddress());

    return { token, timelock, governor, deployer, otherUser };
  }

  it("should execute proposal successfully", async function () {
    const { token, timelock, governor, deployer, otherUser } = await loadFixture(deployContracts);

    // 1. Grant PROPOSER_ROLE to Governor and revoke admin from deployer
    const PROPOSER_ROLE = await timelock.PROPOSER_ROLE();
    await timelock.grantRole(PROPOSER_ROLE, await governor.getAddress());
    const ADMIN_ROLE = await timelock.DEFAULT_ADMIN_ROLE();
    await timelock.revokeRole(ADMIN_ROLE, deployer.address);

    // 2. Delegate tokens to self
    await token.delegate(deployer.address);

    // 3. Create proposal
    const transferCalldata = token.interface.encodeFunctionData("transfer", [otherUser.address, 1000]);
    const proposeTx = await governor.propose(
      [await token.getAddress()],
      [0],
      [transferCalldata],
      "Transfer 1000 tokens"
    );
    const proposeReceipt = await proposeTx.wait();
    const proposalId = proposeReceipt.logs[0].args.proposalId;

    // 4. Advance time past voting delay
    await time.increase(await governor.votingDelay());

    // 5. Vote 'For'
    await governor.castVote(proposalId, 1); // 1 = For

    // 6. Advance time past voting period
    // Voting Period is 1 week (604800 seconds).
    await time.increase(604801); 

    // Mine a block to ensure state transition
    await network.provider.send("evm_mine");

    // 7. Queue proposal
    const descriptionHash = ethers.keccak256(ethers.toUtf8Bytes("Transfer 1000 tokens"));
    await governor.queue([await token.getAddress()], [0], [transferCalldata], descriptionHash);

    // 8. Advance time past timelock delay
    await time.increase(3600); // timelock delay

    // 9. Execute proposal
    await governor.execute([await token.getAddress()], [0], [transferCalldata], descriptionHash);

    // 10. Assert state and token balance
    const proposalState = await governor.state(proposalId);
    expect(proposalState).to.equal(7); // 7 = Executed
    
    const otherUserBalance = await token.balanceOf(otherUser.address);
    expect(otherUserBalance).to.equal(1000);
  });
});