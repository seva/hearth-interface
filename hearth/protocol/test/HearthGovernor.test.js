const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("HearthGovernor", function () {
  let Token, Governor, Timelock, token, governor, timelock;
  let owner, user;

  beforeEach(async function () {
    [owner, user] = await ethers.getSigners();

    // 1. Deploy Token
    Token = await ethers.getContractFactory("HearthToken");
    token = await Token.deploy();
    await token.waitForDeployment();

    // 2. Deploy Timelock (needed for Governor)
    Timelock = await ethers.getContractFactory("Timelock");
    timelock = await Timelock.deploy(86400, [], [], owner.address);
    await timelock.waitForDeployment();

    // 3. Deploy Governor (Token + Timelock)
    Governor = await ethers.getContractFactory("HearthGovernor");
    governor = await Governor.deploy(await token.getAddress(), await timelock.getAddress());
    await governor.waitForDeployment();
  });

  it("Should have correct name", async function () {
    expect(await governor.name()).to.equal("HearthGovernor");
  });

  it("Should rely on Timelock", async function () {
    expect(await governor.timelock()).to.equal(await timelock.getAddress());
  });

  it("Should accept proposal", async function () {
    await token.delegate(owner.address);
    const tx = await governor.propose(
      [owner.address],
      [0],
      ["0x"],
      "Proposal #1: Test"
    );
    const receipt = await tx.wait();
    expect(receipt.status).to.equal(1);
  });
});
