const Safe = require('@safe-global/protocol-kit').default;
const { ethers } = require('hardhat');
const fs = require('fs');
require('dotenv').config();

async function main() {
    console.log('--- Transferring Crowdsale Ownership to New Safe ---');
    
    let newSafeAddress;
    try {
        const safeData = JSON.parse(fs.readFileSync('sepolia-safe.json', 'utf8'));
        newSafeAddress = safeData.safeAddress;
    } catch(e) {
        throw new Error("Could not read sepolia-safe.json.");
    }

    const crowdsaleAddress = "0xef990083409741011b6ed280a1519D75De8F8012";
    const oldSafeAddress = "0xCAbA3c631515949165dc544CbD17FDBdD4Eb88bE";
    
    const [deployer] = await ethers.getSigners();
    
    const crowdsale = await ethers.getContractAt("HearthCrowdsale", crowdsaleAddress);
    const currentOwner = await crowdsale.owner();
    console.log(`Current Crowdsale Owner: ${currentOwner}`);
    
    if (currentOwner.toLowerCase() === newSafeAddress.toLowerCase()) {
        console.log("✅ Crowdsale is already owned by the new Safe.");
        return;
    }
    
    let tx;
    if (currentOwner.toLowerCase() === deployer.address.toLowerCase()) {
        console.log("Deployer is owner. Direct transfer.");
        tx = await crowdsale.transferOwnership(newSafeAddress);
        await tx.wait();
        console.log("✅ Transfer complete! Tx Hash:", tx.hash);
    } else if (currentOwner.toLowerCase() === oldSafeAddress.toLowerCase()) {
        console.log(`Old Safe (${oldSafeAddress}) is owner. Executing Safe tx...`);
        
        const protocolKit = await Safe.init({
            provider: ethers.provider.connection ? ethers.provider.connection.url : "https://sepolia.base.org",
            signer: process.env.PRIVATE_KEY,
            safeAddress: oldSafeAddress
        });
        
        const data = crowdsale.interface.encodeFunctionData("transferOwnership", [newSafeAddress]);
        
        const safeTransaction = await protocolKit.createTransaction({
            transactions: [{
                to: crowdsaleAddress,
                value: '0',
                data: data
            }]
        });
        
        console.log("Executing transaction...");
        const executeTxResponse = await protocolKit.executeTransaction(safeTransaction);
        const receipt = await executeTxResponse.transactionResponse?.wait();
        console.log("✅ Transfer complete! Tx Hash:", executeTxResponse.hash);
    } else {
        console.log("Unknown owner! Cannot transfer.");
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
