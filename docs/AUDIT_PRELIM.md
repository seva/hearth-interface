# Security Audit Report (Preliminary)
**Date:** 2026-02-14
**Scope:** `protocol/contracts/`
**Method:** Slither Static Analysis + Manual Review (Agent: Code)

## Slither Findings

### 1. High/Critical
*None found.* (OpenZeppelin base contracts are robust).

### 2. Medium
- **`HearthCrowdsale.token` & `usdc` Immutable:**
    - *Finding:* Variables are set in constructor but not marked `immutable`.
    - *Risk:* Gas inefficiency. No security risk if no setters exist (they don't).
    - *Fix:* Add `immutable` keyword.

### 3. Low / Informational
- **Pragma Version:** Contracts operate on `^0.8.20`. Base Mainnet supports `cancun` (0.8.24+). Config is safe but could be tighter.
- **Access Control:** `HearthCrowdsale` inherits `Ownable`.
    - *Check:* Who is owner? Currently Deployer. MUST transfer to `Timelock` before Mainnet.

## Manual Review (VixeYult)

### Governor
- **Voting Delay:** 1 day. (Standard).
- **Voting Period:** 1 week. (Standard).
- **Quorum:** 4%. (Standard OZ default). *Risk: Low turnout could stall DAO.*
- **Timelock:** Enforced.

### Crowdsale
- **Rate:** Fixed. *Risk: If ETH/USDC price fluctuates? No, it's USDC-pegged. 1 USDC = 10 HRTH.*
- **Oracle:** None. Relies on `rate` state variable. `setRate()` is `onlyOwner`.
- **Beneficiary:** Funds stay in contract until `withdrawToken` called by Owner.
    - *Fix:* Should auto-forward to Treasury? No, simpler to batch withdraw.
    - *Critical:* Owner MUST be Timelock.

## Recommendations
1.  **Add `immutable` to Crowdsale.**
2.  **Add `revert` string to require statements** in Crowdsale for debugging.
3.  **Governance Handover:** Ensure `transferOwnership(timelock)` is part of the deployment script.

## Verification
- [ ] Slither log saved to `docs/slither_report.txt`.
- [x] Functional Tests passing (Governor verified).
