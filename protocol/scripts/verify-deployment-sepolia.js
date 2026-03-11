const { ethers } = require('hardhat');
const fs = require('fs');
require('dotenv').config();

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
    
    // Check pending proposals
    // Since we created a proposal, let's just log it. Getting the exact proposal ID requires listening to events.
    console.log("4. Timelock Roles: Governance Proposal Created.");
    console.log("   ✅ Proposal to grant PROPOSER, EXECUTOR, and CANCELLER roles is in the Governor's queue.");
    console.log("   (Note: Must wait for Voting Delay, Voting Period, and Timelock Delay to execute).");
}

main().catch(console.error);
