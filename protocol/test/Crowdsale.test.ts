import { expect } from "chai";
import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";

describe("HearthCrowdsale", function () {
  async function deployCrowdsaleFixture() {
    const [owner, buyer, otherAccount] = await ethers.getSigners();

    // 1. Deploy HearthToken (HRTH)
    const HearthToken = await ethers.getContractFactory("HearthToken");
    const token = await HearthToken.deploy();
    
    // 2. Deploy MockUSDC
    const MockUSDC = await ethers.getContractFactory("MockUSDC");
    const usdc = await MockUSDC.deploy();

    // 3. Deploy Crowdsale
    // Rate: 10 HRTH (1e18) per 1 USDC (1e6).
    // So if 1 USDC = 1e6, we want 10 * 1e18 HRTH.
    // Logic: tokenAmount = usdcAmount * rate.
    // 1e6 * rate = 10 * 1e18
    // rate = 10 * 1e12.
    const RATE = 10n * (10n ** 12n); 

    const HearthCrowdsale = await ethers.getContractFactory("HearthCrowdsale");
    const crowdsale = await HearthCrowdsale.deploy(owner.address, await token.getAddress(), await usdc.getAddress(), RATE);

    // 4. Fund the Crowdsale
    const CROWDSALE_SUPPLY = ethers.parseEther("100000"); // 100k HRTH
    await token.transfer(await crowdsale.getAddress(), CROWDSALE_SUPPLY);

    return { crowdsale, token, usdc, owner, buyer, RATE, CROWDSALE_SUPPLY };
  }

  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      const { crowdsale, owner } = await loadFixture(deployCrowdsaleFixture);
      expect(await crowdsale.owner()).to.equal(owner.address);
    });

    it("Should have correct rate", async function () {
      const { crowdsale, RATE } = await loadFixture(deployCrowdsaleFixture);
      expect(await crowdsale.rate()).to.equal(RATE);
    });
  });

  describe("Purchasing", function () {
    it("Should allow buying tokens with USDC", async function () {
      const { crowdsale, token, usdc, buyer, RATE } = await loadFixture(deployCrowdsaleFixture);

      // Mint USDC to buyer (10 USDC)
      const usdcAmount = 10n * (10n ** 6n); // 10 USDC
      await usdc.mint(buyer.address, usdcAmount);

      // Approve Crowdsale
      await usdc.connect(buyer).approve(await crowdsale.getAddress(), usdcAmount);

      // Buy
      await expect(crowdsale.connect(buyer).buyTokens(usdcAmount))
        .to.emit(crowdsale, "TokensPurchased")
        .withArgs(buyer.address, usdcAmount, usdcAmount * RATE);
      
      // Check balances
      // Buyer should have 10 * 10 = 100 HRTH (100e18)
      expect(await token.balanceOf(buyer.address)).to.equal(usdcAmount * RATE);
      expect(await usdc.balanceOf(await crowdsale.getAddress())).to.equal(usdcAmount);
    });

    it("Should fail if amount is zero", async function () {
      const { crowdsale, buyer } = await loadFixture(deployCrowdsaleFixture);
      await expect(crowdsale.connect(buyer).buyTokens(0)).to.be.revertedWith("Amount is zero");
    });
    
    it("Should fail if crowdsale has insufficient tokens", async function () {
        const { crowdsale, usdc, buyer, CROWDSALE_SUPPLY, RATE } = await loadFixture(deployCrowdsaleFixture);
        
        // Try to buy more than supply
        // Supply 100k. Rate 10 Token/USDC.
        // Needs 10k USDC.
        const excessiveUSDC = (100001n * (10n ** 18n)) / RATE; // Rough conversion
        // Simplify: 20000 USDC -> 200000 Tokens > 100000 Supply
        const bigBuy = 20000n * (10n ** 6n);

        await usdc.mint(buyer.address, bigBuy);
        await usdc.connect(buyer).approve(await crowdsale.getAddress(), bigBuy);

        await expect(crowdsale.connect(buyer).buyTokens(bigBuy)).to.be.revertedWith("Insufficient tokens in contract");
    });
  });

  describe("Admin", function () {
      it("Should allow owner to withdraw tokens", async function () {
          const { crowdsale, token, owner, CROWDSALE_SUPPLY } = await loadFixture(deployCrowdsaleFixture);
          
          await expect(crowdsale.withdrawToken(await token.getAddress(), CROWDSALE_SUPPLY))
            .to.emit(crowdsale, "FundsWithdrawn")
            .withArgs(await token.getAddress(), CROWDSALE_SUPPLY);
            
          expect(await token.balanceOf(await crowdsale.getAddress())).to.equal(0);
      });

      it("Should allow owner to set rate", async function () {
        const { crowdsale, RATE } = await loadFixture(deployCrowdsaleFixture);
        const newRate = RATE * 2n;
        await crowdsale.setRate(newRate);
        expect(await crowdsale.rate()).to.equal(newRate);
      });
  });
});
