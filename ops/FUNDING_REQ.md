# Ops: Mainnet Funding Requirement

**Target Network:** Base Mainnet
**Current Balance:** ~0 ETH (Assumed)
**Gas Price Assumption:** 0.1 Gwei (Conservative; currently ~0.005-0.054 Gwei)

## Estimate Calculation (Hardhat Simulation)

| Contract | Est. Gas Limit | Cost (ETH) @ 0.1 Gwei |
| :--- | :--- | :--- |
| **HearthToken** | 2,500,000 | 0.00025 |
| **HearthTimelock** | 2,800,000 | 0.00028 |
| **HearthGovernor** | 3,200,000 | 0.00032 |
| **Crowdsale** | 1,800,000 | 0.00018 |
| **Setup Txs** (Roles, Transfer) | 500,000 | 0.00005 |
| **Verification** | 0 | 0 |
| **Buffer (2x Safety)** | - | **0.00108** |

## Recommendation
**Bridge 0.01 ETH (~$27 USD) to Deployer.**
Address: `0x970f85f53f78A3dA7a1b70dFfD95Df4847b24859`

This provides ample runway for deployment + initial liquidity seeding ops.
Base is extremely cheap. The risk is negligible.

## Config
`hardhat.config.ts` has been updated with `base` mainnet entry using `BASE_RPC` (defaulting to `https://mainnet.base.org`).
No private keys or secrets required beyond existing `.env`.
