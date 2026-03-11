const Safe = require('@safe-global/protocol-kit').default;
const { ethers } = require('hardhat');
const fs = require('fs');
require('dotenv').config();

async function main() {
    console.log('--- Configuring Timelock Roles via Governance ---');
    
    let safeAddress;
    try {
        const safeData = JSON.parse(fs.readFileSync('sepolia-safe.json', 'utf8'));
        safeAddress = safeData.safeAddress;
    } catch(e) {
        throw new Error("Could not read sepolia-safe.json.");
    }

    const governorAddress = "0x70C5A7d5FBc03DeCBB15332BE384791645041387";
    const timelockAddress = "0xc13E5FFaE89324fA5bb2eb7cB2a021aB15d71d6F";
    const tokenAddress = "0x27cfe8EdF0B8D2Af78F9668fD35aA96b612FEEDe";
    
    const [deployer] = await ethers.getSigners();
    
    const governor = await ethers.getContractAt("HearthGovernor", governorAddress);
    const timelock = await ethers.getContractAt("HearthTimelock", timelockAddress);
    const token = await ethers.getContractAt("HearthToken", tokenAddress);
    
    const PROPOSER_ROLE = await timelock.PROPOSER_ROLE();
    const EXECUTOR_ROLE = await timelock.EXECUTOR_ROLE();
    const CANCELLER_ROLE = await timelock.CANCELLER_ROLE();
    const ADMIN_ROLE = ethers.ZeroHash;
    
    console.log("Safe Address:", safeAddress);
    
    // First, check if Safe already has PROPOSER_ROLE
    if (await timelock.hasRole(PROPOSER_ROLE, safeAddress)) {
        console.log("✅ Safe already has PROPOSER_ROLE.");
        return;
    }

    // Delegate votes from Safe to Deployer so we can propose
    const deployerVotes = await token.getVotes(deployer.address);
    if (deployerVotes === 0n) {
        console.log("Deployer has no votes. Executing delegation from Safe...");
        const protocolKit = await Safe.init({
            provider: ethers.provider.connection ? ethers.provider.connection.url : "https://sepolia.base.org",
            signer: process.env.PRIVATE_KEY,
            safeAddress: safeAddress
        });
        const delegateData = token.interface.encodeFunctionData("delegate", [deployer.address]);
        const safeTx = await protocolKit.createTransaction({
            transactions: [{ to: tokenAddress, value: '0', data: delegateData }]
        });
        const txResp = await protocolKit.executeTransaction(safeTx);
        await txResp.transactionResponse?.wait();
        console.log("✅ Delegated votes from Safe to Deployer.");
    }

    // Build Proposal
    console.log("Building Proposal...");
    const targets = [timelockAddress, timelockAddress, timelockAddress];
    const values = [0, 0, 0];
    const calldatas = [
        timelock.interface.encodeFunctionData("grantRole", [PROPOSER_ROLE, safeAddress]),
        timelock.interface.encodeFunctionData("grantRole", [EXECUTOR_ROLE, safeAddress]),
        timelock.interface.encodeFunctionData("grantRole", [CANCELLER_ROLE, safeAddress])
    ];
    const description = "Configure Timelock Roles for New Safe";
    
    try {
        console.log("Submitting Governance Proposal...");
        const proposeTx = await governor.propose(targets, values, calldatas, description);
        await proposeTx.wait();
        console.log("✅ Proposal created! Tx Hash:", proposeTx.hash);
        console.log("Note: Governance voting delay/period applies. Cannot execute immediately on Testnet.");
    } catch (e) {
        console.error("Proposal failed:", e.message);
        console.log("If votes are zero, wait 1 block after delegation and try again.");
    }
}

main().catch(console.error);
