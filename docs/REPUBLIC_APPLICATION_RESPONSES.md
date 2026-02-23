# Hearth DAO — Republic Application: Strategic Responses
**Offering:** $500,000 Reg D 506(c) Tokenized Real Estate Raise  
**Entity:** Hearth Protocol DAO LLC (Wyoming)  
**Date Prepared:** February 18, 2026

---

## 1. Business Strategy

**How Hearth DAO Solves "Friction" in Real Estate Investing via Autonomous Smart Contracts on Base**

### The Problem

Real estate remains the world's largest asset class (~$330 trillion globally) yet one of its least accessible. An individual investor seeking yield from short-term rental properties faces a compounding friction stack:

- **Capital barriers** — median U.S. vacation-rental acquisition exceeds $500K, excluding the vast majority of accredited investors from diversified real estate exposure.
- **Operational drag** — third-party property managers extract 25–40% of gross rental revenue and introduce a single point of human failure across pricing, guest communications, and maintenance dispatch.
- **Illiquidity** — exiting a traditional real estate position takes 3–6 months, incurs 5–6% transaction costs, and offers zero price discovery between closings.
- **Opacity** — investors in syndications and legacy REITs receive quarterly reports at best, with limited visibility into per-asset performance or fee leakage.

### The Solution: Code Is the Manager

Hearth DAO replaces the property manager with a deterministic, auditable software stack:

1. **Tokenized Ownership.** Each property is tokenized into HRTH governance tokens (ERC-20 with ERC20Votes), issued by a Wyoming DAO LLC that holds legal title to the underlying real estate. Token holders are LLC members with pro-rata equity and yield rights, full stop.

2. **The Operator (AI Agent).** Day-to-day property operations — dynamic pricing via PriceLabs/AirDNA, guest communication through LLM-powered messaging, and maintenance dispatch via TaskRabbit/Thumbtack APIs — are handled by an autonomous AI management layer. No human property manager sits in the loop; the Operator executes against defined parameters approved by governance.

3. **On-Chain Yield Distribution.** Rental income is converted to USDC and distributed to HRTH holders via smart contract. The entire income waterfall — from gross booking revenue through operating expenses to net yield — is recorded on-chain, delivering real-time transparency that no quarterly PDF can match.

4. **Instant Liquidity.** HRTH tokens are freely transferable (subject to Reg D transfer restrictions and a 12-month hold for U.S. holders), enabling secondary-market price discovery that traditional real estate simply cannot offer.

### Why Base

Hearth deploys on **Base** (Coinbase's L2) for three strategic reasons: (i) sub-cent transaction costs make micro-distributions economically viable; (ii) native USDC settlement via Coinbase's institutional rails simplifies the fiat↔crypto bridge for investors; and (iii) Base's growing DeFi ecosystem provides future composability for lending, staking, and secondary liquidity.

Our governance stack is **live on Base mainnet** — the HearthGovernor contract is deployed at `0x69B56F01098e800b836e6e8ebC1538c8E7808B47`, alongside HearthToken, HearthTimelock, and HearthCrowdsale contracts — demonstrating that the technical infrastructure is not speculative. It is built, deployed, and verifiable.

### The Autonomous Cycle

```
Investor → Buys HRTH Token → DAO LLC Acquires Property → 
The Operator (AI) Manages STR Operations → 
Rental Revenue → USDC On-Chain → Yield Streams to Token Holders
```

We are not building a pitch deck for a future product. We are capitalizing a deployed protocol.

---

## 2. Legal & Regulatory Strategy

**Wyoming DAO LLC Wrapper + HRTH Token Governance (ERC20Votes) + Reg D 506(c) Compliance**

### Entity Structure: Wyoming DAO LLC

Hearth Protocol DAO LLC is organized under the **Wyoming Decentralized Autonomous Organization Supplement** (W.S. §17-31-101 et seq.), the most mature DAO-specific legislation in the United States. Key structural features:

- **Legal Personhood.** The DAO LLC is a recognized legal entity that can hold real property title, enter contracts, maintain bank accounts, and sue or be sued — resolving the single largest risk in DAO-based projects: legal ambiguity.
- **Algorithmically Managed.** Per W.S. §17-31-104, the Company is designated as "algorithmically managed," meaning day-to-day managerial authority is vested in deployed smart contracts rather than named human managers. This designation is not cosmetic — it is a statutory election filed with the Wyoming Secretary of State.
- **Limited Liability.** Members (HRTH holders) enjoy the same liability protections as members of any Wyoming LLC. No member is personally liable for the debts or obligations of the Company solely by reason of token ownership (Operating Agreement, Article IV, §4.1).
- **Registered Office.** 30 N Gould St, Ste N, Sheridan, WY 82801, with a professional registered agent on file.

### Token Governance Architecture

The HRTH token is an **ERC-20 with ERC20Votes and ERC20Permit** extensions (OpenZeppelin v5), purpose-built for on-chain governance:

| Component | Contract | Function |
|---|---|---|
| **HearthToken (HRTH)** | ERC20 + ERC20Votes + ERC20Permit | Membership representation, vote delegation, gasless approvals |
| **HearthGovernor** | OZ Governor + GovernorSettings + GovernorVotesQuorumFraction + GovernorTimelockControl | Proposal creation, voting (1-day delay, 1-week period), 4% quorum |
| **HearthTimelock** | TimelockController (86,400s delay) | Execution buffer for approved proposals, prevents governance attacks |
| **HearthCrowdsale** | Custom (Ownable, ReentrancyGuard) | USDC-denominated token purchase with configurable rate |

This is a full **Governor Bravo-equivalent** governance stack with timelock protection. Proposals for treasury allocations, property acquisitions, protocol upgrades, and dissolution all flow through this on-chain governance pipeline. The smart contract address referenced in the Operating Agreement will be updated to the live Base mainnet deployment addresses upon completion of this offering.

### Operating Agreement: Code-First, Law-Second

Per Article II, §2.3 of the Hearth Protocol DAO LLC Operating Agreement:

> *"In the event of a conflict between this Agreement and the smart contract code, the smart contract code shall prevail to the extent permitted by law, except where such code result would constitute a criminal act."*

This creates a clear hierarchy: the protocol is the primary governance layer, with the legal wrapper serving as a compliance and liability bridge to the traditional legal system — not the other way around.

### Reg D 506(c) Compliance

The $500,000 raise is structured under **Rule 506(c) of Regulation D** of the Securities Act of 1933:

- **Accredited Investors Only.** All purchasers must be verified accredited investors. Verification will be conducted via Republic's integrated KYC/accreditation flow or a third-party verification service (e.g., Parallel Markets, Verify Investor).
- **General Solicitation Permitted.** 506(c) explicitly permits public marketing and general solicitation, provided all purchasers are verified accredited. This enables us to leverage Republic's platform distribution without restriction.
- **Transfer Restrictions.** HRTH tokens issued under this offering are restricted securities subject to a 12-month holding period. Transfer restriction logic can be enforced at the smart contract level or via Republic's transfer agent infrastructure.
- **Form D Filing.** A Form D will be filed with the SEC within 15 days of the first sale of securities.
- **Blue Sky.** State-level notice filings will be made as required based on investor residency.

### Why This Structure Is Defensible

The combination of (i) a recognized state-law entity, (ii) Reg D exemption compliance, and (iii) on-chain governance with timelock protections means Hearth is not operating in a regulatory gray zone. We are building within the existing legal framework, using blockchain as an execution layer — not as a mechanism to evade securities law.

---

## 3. Competitive Edge

**Why "Zero Touch" Property Yield Is Superior to Legacy REITs and Manual Syndications**

### The Landscape

| Feature | Legacy Public REIT | Manual Syndication (GP/LP) | **Hearth DAO** |
|---|---|---|---|
| **Minimum Investment** | ~$50 (share price) | $25K–$100K | **$100** (token-based) |
| **Fee Drag** | 1.0–1.5% AUM + internal costs | 2% mgmt + 20% carry | **15% of gross revenue, no carry** |
| **Transparency** | Quarterly 10-Q filings | Annual K-1 + manager updates | **Real-time on-chain** |
| **Liquidity** | Public market (T+1) | Illiquid (5–10yr lockup) | **24/7 token transfers** (post-restriction) |
| **Governance** | Board of directors (proxy voting) | GP has full discretion | **Token-weighted on-chain voting** |
| **Operational Layer** | Outsourced PM firms | GP selects and oversees PM | **Autonomous AI (The Operator)** |
| **Geographic Access** | Global (public equity) | Accredited, networked | **Global (w/ compliance gates)** |

### The "Zero Touch" Thesis

Traditional real estate yield depends on a chain of human intermediaries: the syndicator who sources the deal, the property manager who operates it, the accountant who reconciles the books, and the attorney who distributes K-1s. Each link in this chain extracts fees, introduces latency, and creates the possibility of error or misalignment.

Hearth's competitive thesis is the **systematic elimination of these intermediaries through software:**

1. **Zero-Touch Operations.** The Operator handles pricing optimization, guest messaging, cleaning coordination, and maintenance dispatch without human intervention. This is not a "future feature" — dynamic pricing via PriceLabs, automated guest messaging via LLM, and vendor dispatch via API are all technically feasible today and constitute our operational model from Day 1.

2. **Zero-Touch Yield.** Rental income flows from booking platform → DAO treasury → smart contract → HRTH holders. No manual reconciliation. No quarterly wait. No discretionary withholding by a GP.

3. **Zero-Touch Governance.** Major decisions (property acquisition, disposition, renovation, dissolution) are proposed and executed on-chain through the HearthGovernor with timelock protection. No board meetings. No proxy ballots. No information asymmetry between manager and investor.

### Structural Advantages Over Specific Competitors

**vs. Public REITs (e.g., VICI Properties, American Tower):**
Public REITs offer liquidity but zero asset-level transparency and no investor governance over specific properties. An investor in a REIT has no ability to vote on whether to acquire or dispose of a particular asset. Hearth provides property-specific token exposure with direct governance rights — it is a *transparent REIT with a vote*.

**vs. GP/LP Syndications (e.g., typical Reg D offerings):**
Syndications offer asset specificity but concentrate power in the General Partner, who controls operations, distributions, and exit timing. Fee structures (2/20) systematically misalign incentives. Hearth eliminates the GP entirely — the protocol operates the asset, and token holders govern through binding on-chain votes. *There is no GP to misalign with.*

**vs. Fractional Ownership Platforms (e.g., Pacaso, Arrived, Lofty):**
These platforms fractionally sell either equity or debt positions in real estate, but they remain operationally centralized — a human team manages every property, and investors have limited-to-no governance. Hearth's differentiator is the **autonomous operational layer**: the AI Operator is not a feature enhancement to a human management team; it is the management team.

### Technical Readiness

We are not presenting a concept. The following contracts are deployed and verified on Base mainnet:

- **HearthToken (HRTH):** `0x27cfe8EdF0B8D2Af78F9668fD35aA96b612FEEDe` — 10M supply, ERC20Votes enabled
- **HearthGovernor:** `0x69B56F01098e800b836e6e8ebC1538c8E7808B47` — Full OZ Governor with 4% quorum, 1-day delay, 1-week voting
- **HearthTimelock:** `0xc13E5FFaE89324fA5bb2eb7cB2a021aB15d71d6F` — 24-hour execution buffer
- **HearthCrowdsale:** `0xef990083409741011b6ed280a1519D75De8F8012` — USDC-denominated, rate-configurable

The protocol is built. The legal entity is formed. The governance stack is live. This raise capitalizes the first property acquisition — the Genesis Property — to prove the zero-touch model in production.

---

## Summary

Hearth DAO represents a category-creating opportunity: the first **Autonomous Real Estate Investment Trust** with a live governance protocol, a legally recognized DAO LLC, and an AI-driven operational layer that eliminates the property manager entirely.

We are raising $500,000 under Reg D 506(c) to acquire the Genesis Property and demonstrate that **Code is the Manager** is not a slogan — it is an operational reality deployed on Base at `0x69B...8B47`.

---

*Prepared for Republic Platform Application — February 2026*
*Hearth Protocol DAO LLC — Wyoming*
