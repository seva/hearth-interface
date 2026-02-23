const hre = require("hardhat");

async function main() {
    const feeData = await hre.ethers.provider.getFeeData();
    console.log("Gas Price:", feeData.gasPrice.toString());
    console.log("Max Fee Per Gas:", feeData.maxFeePerGas?.toString());
    console.log("Max Priority Fee Per Gas:", feeData.maxPriorityFeePerGas?.toString());
}

main();