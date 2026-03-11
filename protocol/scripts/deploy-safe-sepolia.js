const Safe = require('@safe-global/protocol-kit').default;
const { ethers } = require('hardhat');
require('dotenv').config();

async function main() {
    console.log('--- Deploying New Safe on Sepolia ---');
    const [deployer] = await ethers.getSigners();
    
    const owners = [
        deployer.address,
        '0x00D5bE34afE6C2a90256fbCaDE9Ce9CafA544D12' // Mock cold address
    ];
    
    console.log('Owners:', owners);
    
    const safeAccountConfig = {
        owners,
        threshold: 1, 
    };

    const predictedSafe = { safeAccountConfig };

    const protocolKit = await Safe.init({
        provider: ethers.provider.connection ? ethers.provider.connection.url : "https://sepolia.base.org",
        signer: process.env.PRIVATE_KEY,
        predictedSafe
    });

    console.log('Deploying Safe...');
    const safeDeploymentTransaction = await protocolKit.createSafeDeploymentTransaction();
    
    const ethAdapter = protocolKit.getSafeProvider();
    
    // send transaction
    const txResponse = await deployer.sendTransaction({
        to: safeDeploymentTransaction.to,
        value: safeDeploymentTransaction.value,
        data: safeDeploymentTransaction.data
    });
    
    console.log('Tx hash:', txResponse.hash);
    const receipt = await txResponse.wait();
    
    const safeAddress = await protocolKit.getAddress();
    console.log('✅ New Safe deployed to:', safeAddress);
    
    const fs = require('fs');
    fs.writeFileSync('sepolia-safe.json', JSON.stringify({ safeAddress }));
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
