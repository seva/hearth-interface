const { ethers } = require('hardhat');
const fs = require('fs');
require('dotenv').config();

const ProposalState = [
    "Pending", "Active", "Canceled", "Defeated", "Succeeded", "Queued", "Expired", "Executed"
];

async function main() {
    console.log('--- Verifying Sepolia Deployment ---');
    
    let safeAddress;
    try {
        const safeData = JSON.parse(fs.readFileSync('sepolia-safe.json', 'utf8'));
        safeAddress = safeData.safeAddress;
    } catch(e) {
        throw new Error("Could not read sepolia-safe.json.");
    }
    
    const tokenAddress = "0x27cfe8EdF0B8D2Af78F9668fD35aA96b612FEEDe";
    const crowdsaleAddress = "0xef990083409741011b6ed280a1519D75De8F8012";
    const timelockAddress = "0xc13E5FFaE89324fA5bb2eb7cB2a021aB15d71d6F";
    const governorAddress = "0x70C5A7d5FBc03DeCBB15332BE384791645041387";
    
    const token = await ethers.getContractAt("HearthToken", tokenAddress);
    const crowdsale = await ethers.getContractAt("HearthCrowdsale", crowdsaleAddress);
    const governor = await ethers.getContractAt("HearthGovernor", governorAddress);
    const timelock = await ethers.getContractAt("HearthTimelock", timelockAddress);
    
    console.log("1. Safe Address:", safeAddress);
    
    const balance = await token.balanceOf(safeAddress);
    console.log(`2. Token Treasury: Safe holds ${ethers.formatUnits(balance, 18)} HRTH`);
    if (balance === 0n) {
        console.log("   ❌ ERROR: Safe has no tokens.");
    } else {
        console.log("   ✅ Token balance successfully transferred to Safe.");
    }
    
    const crowdsaleOwner = await crowdsale.owner();
    console.log(`3. Crowdsale Owner: ${crowdsaleOwner}`);
    if (crowdsaleOwner.toLowerCase() === safeAddress.toLowerCase()) {
        console.log("   ✅ Crowdsale ownership successfully transferred to Safe.");
    } else {
        console.log("   ❌ ERROR: Crowdsale owner mismatch.");
    }
    
    // Proposal Parameters
    const PROPOSER_ROLE = await timelock.PROPOSER_ROLE();
    const EXECUTOR_ROLE = await timelock.EXECUTOR_ROLE();
    const CANCELLER_ROLE = await timelock.CANCELLER_ROLE();
    
    const targets = [timelockAddress, timelockAddress, timelockAddress];
    const values = [0, 0, 0];
    const calldatas = [
        timelock.interface.encodeFunctionData("grantRole", [PROPOSER_ROLE, safeAddress]),
        timelock.interface.encodeFunctionData("grantRole", [EXECUTOR_ROLE, safeAddress]),
        timelock.interface.encodeFunctionData("grantRole", [CANCELLER_ROLE, safeAddress])
    ];
    const description = "Configure Timelock Roles for New Safe";
    const descriptionHash = ethers.id(description);
    const proposalId = await governor.hashProposal(targets, values, calldatas, descriptionHash);
    
    console.log("4. Governance Proposal State:");
    try {
        const state = await governor.state(proposalId);
        const stateName = ProposalState[Number(state)];
        
        const votes = await governor.proposalVotes(proposalId);
        const againstVotes = ethers.formatUnits(votes[0], 18);
        const forVotes = ethers.formatUnits(votes[1], 18);
        const abstainVotes = ethers.formatUnits(votes[2], 18);
        
        console.log(`   Proposal ID: ${proposalId}`);
        console.log(`   State: ${stateName} (${state})`);
        console.log(`   Votes: For=${forVotes}, Against=${againstVotes}, Abstain=${abstainVotes}`);
        
        if (stateName === "Pending" || stateName === "Active" || stateName === "Succeeded" || stateName === "Queued") {
            console.log("   ✅ Governance Proposal is valid and progressing.");
        } else {
            console.log("   ❌ Governance Proposal is in an invalid or failed state.");
        }
    } catch(e) {
        console.log("   ❌ Error querying proposal state:", e.message);
    }
    
    console.log("5. Timelock Roles:");
    const hasProposer = await timelock.hasRole(PROPOSER_ROLE, safeAddress);
    const hasExecutor = await timelock.hasRole(EXECUTOR_ROLE, safeAddress);
    const hasCanceller = await timelock.hasRole(CANCELLER_ROLE, safeAddress);
    
    console.log(`   PROPOSER_ROLE: ${hasProposer ? "✅ Granted" : "❌ Not Granted"}`);
    console.log(`   EXECUTOR_ROLE: ${hasExecutor ? "✅ Granted" : "❌ Not Granted"}`);
    console.log(`   CANCELLER_ROLE: ${hasCanceller ? "✅ Granted" : "❌ Not Granted"}`);
    
    if (hasProposer && hasExecutor && hasCanceller) {
        console.log("   ✅ All Timelock roles successfully granted to Safe.");
    } else {
        console.log("   ⏳ Waiting for Governance Proposal to execute to grant Timelock roles.");
    }
}

main().catch(console.error);
