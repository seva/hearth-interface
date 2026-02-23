const { expect } = require("chai");

describe("DS_HearthGovernor", function () {
  let DS_HearthGovernor;
  let contract;

  beforeEach(async function () {
    DS_HearthGovernor = await ethers.getContractFactory("DS_HearthGovernor");
    contract = await DS_HearthGovernor.deploy();
    await contract.deployed();
  });

  it("should return quorum of 4", async function () {
    expect(await contract.getQuorum()).to.equal(4);
  });
});