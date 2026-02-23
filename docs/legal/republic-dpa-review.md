# Republic Token DPA Compliance Review
**Hearth DAO**  
**Date:** February 20, 2026

## 1. Algorithmic Management Compatibility

**Finding:** The Token Debt Purchase Agreement (Token DPA) is a contract between the **Issuer** (Hearth Protocol DAO LLC) and the **Investor**.

*   **Signatory:** Under Wyoming law, an "Authorized Person" or "Member" can sign on behalf of an algorithmically managed DAO LLC. Seva (Wsevolod Lapsha) will sign as the founder/authorized member.
*   **Management Reps:** Standard DPA language regarding "responsible management" of funds can be interpreted within the DAO paradigm. Managerial authority is vested in the HearthGovernor ( treasury oversight).
*   **Conclusion:** NO conflict. The legal wrapper (LLC) acts as the counterparty; the underlying management logic (Code-as-Manager) is an internal operational election disclosed in the application text.

## 2. Transfer Restriction Logic (Reg D 12-Month Hold)

**Finding:** Republic handles the primary custody and accreditation verification.

*   **Enforcement:** Republic's platform enforces the 12-month Regulation D lockup through its escrow and distribution phase. Tokens are typically not distributed to investor wallets until the legal compliance period is met or are distributed into restricted accounts (e.g., via INX).
*   **Smart Contract Impact:** We do **NOT** need to hardcode a complex 12-month restriction into the primary `HearthToken.sol` contract at this stage. 
*   **Recommendation:** Maintain the current clean HRTH implementation. Enforcement will be handled at the **Distribution Layer** (e.g., minting to a vesting/lockup contract or Republic's omnibus account) rather than the **Token Layer**.

## 3. USDC Distributions

**Finding:** The DPA identifies the "debt" can be repaid in tokens or cash.

*   **On-Chain Flow:** Our plan to distribute yield in USDC directly to HRTH holders via contract aligns perfectly with the "payable by asset" nature of the DPA.
*   **Conclusion:** Fully compatible.

---
**Status:** GREEN (Ready for submission)
