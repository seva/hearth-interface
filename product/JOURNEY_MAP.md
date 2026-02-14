# Hearth DAO - Customer Journey Map & Capabilities

## 1. Persona: The Investor (Passive Yield Seeker)
*Goal: Park capital, earn stable yield (USDC), minimize effort.*

### Journey Flow
1.  **Discovery:** Sees Hearth on Twitter or gets referred. Lands on `hearthdao.com`.
2.  **Onboarding:** Connects Wallet (Coinbase Wallet / MetaMask).
3.  **Purchase:**
    -   *Scenario A (Crowdsale):* Sends USDC to Crowdsale Contract -> Receives HRTH instantly.
    -   *Scenario B (DEX):* Swaps USDC for HRTH on Aerodrome (if liquid).
4.  **Holding:** Assets sit in wallet.
5.  **Earning:**
    -   Property yields paid in USDC to Treasury.
    -   *Yield Claim:* Investor visits Dashboard -> "Claim Rewards" (pulls pro-rata share).
    -   *Or Auto-Drop:* Smart contract pushes USDC (Gas expensive, Claim preferred).
6.  **Exit:** Swaps HRTH -> USDC on DEX.

### Required Capabilities
- [P0] **Crowdsale Interface:** Simple "Buy HRTH" widget (USDC approval + Transfer).
- [P0] **Dashboard:** "My Balance", "Estimated Yield", "Treasury Health".
- [P1] **Yield Claiming:** Merkle Distributor or similar contract for efficient payout.
- [P2] **Fiat On-Ramp:** Integrated Stripe/MoonPay widget for buying USDC with card.

---

## 2. The Proposer (Active Operator / Scout)
*Goal: Find properties, propose acquisition, earn success fee.*

### Journey Flow
1.  **Scouting:** Identifies a profitable Airbnb in Target Market (AZ).
2.  **Analysis:** Runs numbers (AirDNA) -> Calculates Cap Rate.
3.  **Proposal:**
    -   Connects wallet.
    -   Creates "Acquisition Proposal" on Dashboard.
    -   Uploads: Zillow Link, Financial Model (PDF/CSV), Ask Price.
    -   *On-Chain:* Submits `propose()` tx to Governor (Calldata: "Transfer X USDC to Escrow if Passed").
4.  **Campaigning:** Shares proposal link on Discord/Twitter to rally votes.
5.  **Execution:**
    -   Vote Passes -> Timelock queues tx.
    -   *Closing:* funds released to Title Co / Attorney.

### Required Capabilities
- [P1] **Proposal UI:** Form to draft on-chain proposals without coding.
- [P1] **Metadata Storage:** IPFS/Arweave pinning for proposal documents (Zillow links, PDFs).
- [P2] **Simulation:** "Simulate Transaction" to verify the proposal actually sends money correctly.

---

## 3. The Voter (Governance Participant)
*Goal: Ensure quality investments, protect treasury.*

### Journey Flow
1.  **Notification:** Receives email/Telegram alert: "New Proposal: Sedona Cabin ($1.2M)".
2.  **Review:** Checks Dashboard. Reads Proposer's analysis.
3.  **Voting:**
    -   Selects "For", "Against", "Abstain".
    -   Signs transaction (Gasless if snapshot? No, on-chain Governor requires gas).
4.  **Outcome:** Sees result (Quorum reached?).

### Required Capabilities
- [P0] **Governance Dashboard:** List active/past proposals.
- [P0] **Voting Widget:** Cast vote on-chain.
- [P1] **Delegation:** "Delegate to Expert" UI for passive holders.

---

## 4. Stack Ranked Capabilities Matrix

| Rank | Capability | Description | Dependencies |
| :--- | :--- | :--- | :--- |
| **P0** | **Buy Interface** | Crowdsale UI (USDC -> HRTH). | `Crowdsale.sol` |
| **P0** | **Wallet Connect** | Auth via RainbowKit/Wagmi. | n/a |
| **P0** | **Gov Dashboard** | View Proposals & Cast Vote. | `HearthGovernor.sol` |
| **P1** | **Proposal Builder** | UI to craft `propose()` calldata. | `HearthTimelock.sol` |
| **P1** | **Yield Claim** | Contract + UI for dividend distribution. | Treasury Funding |
| **P2** | **Docs Hosting** | IPFS integration for proposal attachments. | n/a |
| **P2** | **Fiat On-Ramp** | Credit Card -> USDC. | Legal/KYC Provider |

**Product Roadmap Implication:**
1.  **MVP (Phase 3 Launch):** Buy Interface + Wallet Connect. (Fundraising).
2.  **V1.1 (Gov):** Gov Dashboard + Proposal Builder. ( Spending).
3.  **V1.2 (Yield):** Yield Claiming. (Operations).
