const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("HearthGovernor", function () {
  let Token, Governor, token, governor;
  let owner, user;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();

    // 1. Deploy Token
    Token = await ethers.getContractFactory("HearthToken");
    token = await Token.deploy();
    await token.waitForDeployment();

    // 2. Deploy Governor (Token Address)
    Governor = await ethers.getContractFactory("HearthGovernor");
    // Constructor requires IVotes token
    governor = await Governor.deploy(await token.getAddress());
    await governor.waitForDeployment();
  });

  it("Should have correct name", async function () {
    expect(await governor.name()).to.equal("HearthGovernor");
  });

  it("Should have correct voting settings", async function () {
    // 1 block delay
    expect(await governor.votingDelay()).to.equal(1n);
    // 1 week (45818 blocks @ 13.2s)
    expect(await governor.votingPeriod()).to.equal(45818n);
    // 4% quorum
    // Note: Quorum is based on timepoint, hard to test static without checkpoints
    // but we can check the numerator in fraction (if exposed) or logic flows.
    // Default OZ exposes `quorumNumerator()`
    expect(await governor.quorumNumerator()).to.equal(4n);
  });

  it("Should accept proposal (basic flow)", async function () {
    // Delegate to self to have voting power
    await token.delegate(owner.address);
    
    // Create proposal
    const tx = await governor.propose(
      [owner.address],
      [0],
      ["0x"],
      "Proposal #1: Test"
    );
    const receipt = await tx.wait();
    
    // Just ensure it worked
    expect(receipt.status).to.equal(1);
  });
});
