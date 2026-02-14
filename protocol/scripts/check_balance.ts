import { ethers } from "hardhat";
require("dotenv").config();

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Checking balance for:", deployer.address);

  const TOKEN_ADDRESS = "0x7808D5b2F6615041B94B344b2C7Df6bd63A1Fcca";
  const TEARTH_CROWDSALE = "0x57d91E59b5A89CE4212dccf77906C0c3FFa31F5a";

  const token = await ethers.getContractAt("HearthToken", TOKEN_ADDRESS);
  
  const totalSupply = await token.totalSupply();
  console.log("Total Supply:", ethers.formatEther(totalSupply));

  const balance = await token.balanceOf(deployer.address);
  console.log("Deployer HRTH Balance:", ethers.formatEther(balance));
  
  const crowdsaleBalance = await token.balanceOf(TEARTH_CROWDSALE);
  console.log("Crowdsale HRTH Balance:", ethers.formatEther(crowdsaleBalance));

  if (balance >= ethers.parseEther("100000")) {
      console.log("Result: Sufficient balance to fund.");
  } else {
      console.log("Result: INSUFFICIENT balance.");
  }
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
