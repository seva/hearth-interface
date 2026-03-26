# Hearth DAO — Republic Application: Strategic Responses
**Offering:** $500,000 Reg D 506(c) Tokenized Real Estate Raise  
**Entity:** Hearth Protocol DAO LLC (Wyoming)  
**Date Prepared:** March 26, 2026

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
- **Transfer Restrictions.** HRTH tokens issued under this offering are restricted securities subject to a 12-month holding period. Transfer restriction enforcement **shall be** implemented through a dual-layer mechanism (see below).
- **Form D Filing.** A Form D will be filed with the SEC within 15 days of the first sale of securities.
- **Blue Sky.** State-level notice filings will be made as required based on investor residency.

### Rule 506(d) Bad Actor Disqualification

Hearth Protocol DAO LLC and its covered persons are subject to the disqualification provisions of **Rule 506(d)(1)** of Regulation D. The Company has undertaken the following compliance measures:

**Covered Persons Enumeration.** Per Rule 506(d)(1), the following categories are subject to disqualification screening:
- The Company (Hearth Protocol DAO LLC) and any predecessor
- Any director, executive officer, or general partner of the Company
- Any 20% beneficial owner of the Company (calculated by voting power)
- Any promoter connected with the Company
- Any person compensated for soliciting purchasers in connection with the sale
- Any general partner, director, executive officer, or 20% beneficial owner of any such solicitor
- Any placement agent or its associated persons

**Disqualifying Events.** The Company has screened all covered persons against the nine categories of disqualifying events under Rule 506(d)(1)(i)-(vii):
1. SEC registration revocations or suspensions
2. CFTC trading and market suspensions
3. Court injunctions or restraining orders related to securities or commodities
4. Criminal convictions within 10 years (or 5 years for entities) related to securities, commodities, or financial services
5. SEC or CFTC orders within 10 years barring association with regulated entities
6. SEC stop orders or Regulation A exemptions suspensions within 5 years
7. State securities administrator orders within 10 years
8. U.S. Postal Service false representation orders within 5 years
9. Court judgments or final administrative findings for securities/commodities violations

**Pre-Existing Matters Disclosure.** Any disqualifying event that occurred prior to September 23, 2013 (the effective date of Rule 506(d)) does not trigger disqualification but must be disclosed to purchasers. The Company maintains documentation of all pre-existing matters and will provide disclosure as required under Rule 506(e).

**Ongoing Verification Obligation.** The Company will conduct reasonable verification of the status of covered persons:
- Prior to each sale of securities under this offering
- Upon any material change to covered persons (new directors, officers, 20% owners)
- Annually as part of compliance review

**Documentation Maintenance.** All verification records, questionnaires, and screening results will be maintained for the duration of the offering and for three years thereafter, available for regulatory inspection.

**Current Status.** As of the date of this application, no disqualifying events exist with respect to any covered person. The Company's management and all identified covered persons have completed questionnaires and background screenings confirming no disqualifying events under Rule 506(d).

### Transfer Restriction Enforcement Mechanics

HRTH token transfers **shall be enforced** through a dual-layer restriction mechanism ensuring compliance with Reg D transfer limitations:

**Layer 1: Smart Contract Enforcement.** The HRTH token contract implements transfer hooks that verify recipient eligibility prior to any transfer execution:
- **Whitelist Verification:** Recipient addresses must be present on an on-chain whitelist maintained by the transfer agent
- **Hold Period Check:** For U.S. holders, the contract verifies that 12 months have elapsed since token issuance (tracked via per-address timestamp mapping)
- **Automatic Revert:** Any transfer attempt that fails whitelist or hold period verification reverts at the smart contract level, preventing execution

**Layer 2: Transfer Agent Oversight.** Republic's transfer agent infrastructure provides off-chain enforcement:
- **Accreditation Verification:** Recipients must maintain verified accredited investor status in Republic's system
- **Rule 144 Compliance:** Transfers after the 12-month hold period require representation of Rule 144 compliance or other applicable exemption
- **Cap Table Management:** All transfers are recorded on Republic's cap table; unapproved transfers are not recognized for corporate governance purposes (voting, distributions)

**Enforcement Statement:** No HRTH token transfer shall be effectuated without satisfaction of both layers. The smart contract layer provides technical prevention; the transfer agent layer provides legal and regulatory compliance verification. This dual-layer approach ensures that transfer restrictions are not merely contractual promises but technically enforced constraints.

**Non-U.S. Holders:** Non-U.S. persons remain subject to the 12-month hold period under Reg S but may transfer to other verified non-U.S. persons after such period, subject to transfer agent approval and applicable foreign securities law compliance.

### Investment Company Act 3(c)(5)(C) Exemption Analysis

Hearth Protocol DAO LLC relies on the exclusion from investment company status provided by **Section 3(c)(5)(C)** of the Investment Company Act of 1940. This analysis demonstrates compliance with the statutory requirements:

**Primary Business Activity — Real Estate Operations.** Section 3(c)(5)(C) excludes entities "primarily engaged in the business of purchasing or otherwise acquiring mortgages and other liens on and interests in real estate." The SEC has interpreted this to require that at least 55% of assets be "qualifying interests" in real estate, and at least 80% be qualifying interests plus real estate-related assets.

**Qualifying Interests Standard — Fee Simple Ownership.** Hearth Protocol DAO LLC holds **fee simple title** to real property through its Wyoming DAO LLC structure. Fee simple ownership represents the quintessential "interest in real estate" under SEC no-action guidance and judicial precedent. Unlike mortgage REITs or debt-focused vehicles, Hearth holds direct title to physical real property, satisfying the 55% qualifying interest requirement with substantial margin.

**Operational Real Estate — Active Management.** The Company is not a passive holder of real estate assets. Through "The Operator" (AI management layer), the Company actively manages short-term rental operations including:
- Dynamic pricing and revenue management
- Guest acquisition and communication
- Maintenance coordination and property upkeep
- Regulatory compliance (occupancy taxes, licensing)

This active operational role distinguishes Hearth from passive investment vehicles and reinforces the "primarily engaged in" standard under 3(c)(5)(C).

**No Securities Portfolio.** The Company does not maintain a portfolio of securities for investment purposes. Treasury holdings (USDC, stablecoins) are incidental to operations and held solely for:
- Distribution of rental yield to token holders
- Operating reserves for maintenance and expenses
- Bridge liquidity during property acquisition cycles

Such holdings do not exceed 45% of total assets except during temporary periods between property acquisitions, and are not held for investment return but for operational liquidity.

**Single Asset Class Focus.** The Company's organizational documents restrict asset acquisition to real property and real estate-related assets. The Operating Agreement prohibits diversification into securities, commodities, or other investment assets unrelated to real estate operations. This structural constraint ensures ongoing 3(c)(5)(C) compliance.

**Ongoing Compliance Monitoring.** The Company will conduct quarterly asset composition reviews to verify:
- Qualifying real estate interests ≥55% of total assets
- Real estate-related assets + qualifying interests ≥80% of total assets
- Non-qualifying assets <20% of total assets (excluding temporary acquisition bridges)

**Risk Acknowledgment.** The SEC has not issued specific guidance on tokenized real estate structures or DAO LLCs in the 3(c)(5)(C) context. While the Company's structure is designed to comply with existing interpretations, there is regulatory uncertainty regarding:
- Whether tokenized membership interests constitute "securities" for Investment Company Act purposes
- Whether a DAO LLC qualifies as an "issuer" under the Act
- Whether the SEC may adopt new positions affecting tokenized real estate vehicles

The Company is committed to restructuring or registering under the Investment Company Act if regulatory developments require such action. This risk is disclosed to investors in the Risk Factors section.

### Why This Structure Is Defensible

The combination of (i) a recognized state-law entity, (ii) Reg D exemption compliance, and (iii) on-chain governance with timelock protections means Hearth is not operating in a regulatory gray zone. We are building within the existing legal framework, using blockchain as an execution layer — not as a mechanism to evade securities law.

---

## 3. Use of Proceeds

**Total Raise:** $500,000 USDC

The proceeds from this Reg D 506(c) offering will be allocated as follows:

| Category | Amount | Percentage | Description |
|---|---|---|---|
| **Property Acquisition** | $400,000 | 80% | Down payment and closing costs for Genesis Property (target: $500K–$600K STR property with 20–25% down payment) |
| **Operating Reserve** | $50,000 | 10% | 6-month reserve for mortgage payments, utilities, insurance, maintenance, and property taxes during ramp-up period |
| **Legal & Compliance** | $30,000 | 6% | Securities counsel review, Form D filing, state Blue Sky notices, ongoing compliance monitoring, transfer agent fees |
| **Technology & Infrastructure** | $15,000 | 3% | Smart contract audits, The Operator development, monitoring infrastructure, Base network gas reserves |
| **Platform & Marketing** | $5,000 | 1% | Republic platform fees, marketing materials, investor communications |

**Property Acquisition Details:** The Genesis Property will be acquired through Hearth Protocol DAO LLC as fee simple owner. Target criteria include:
- Purchase price: $500,000–$600,000
- Location: High-STR-demand markets (e.g., Nashville, Austin, Phoenix, Tampa)
- Projected gross yield: 8–12% annually
- Financing: 75–80% LTV mortgage with DAO LLC as borrower

**Operating Reserve Deployment:** The $50,000 reserve will be held in USDC and deployed as needed for:
- Mortgage payments during low-occupancy periods
- Emergency repairs and maintenance
- Property tax and insurance payments
- Utility costs and HOA fees

**Contingency:** If the full $500,000 is not raised, proceeds will be allocated pro-rata across categories, with property acquisition scaled accordingly. Minimum viable raise: $350,000 (sufficient for $450K property acquisition with reserves).

---

## 4. Management Team

**Hearth Protocol DAO LLC — Key Personnel**

### Seva Lapsha — Founder & Technical Architect

**Background:**
- VP Architecture, DTOL (former: Coursera, Amazon, D2L, Nielsen)
- 15+ years in distributed systems, platform architecture, and engineering leadership
- Expertise in blockchain protocols, smart contract systems, and decentralized governance

**Role at Hearth:**
- Technical architecture and smart contract development
- Governance protocol design and implementation
- Strategic direction and protocol roadmap

**Relevant Experience:**
- Deployed Hearth governance stack on Base mainnet (HearthToken, HearthGovernor, HearthTimelock, HearthCrowdsale)
- Led engineering teams at scale (Coursera: 100M+ users; Amazon: distributed infrastructure)
- Deep expertise in Solidity, OpenZeppelin, and L2 deployment patterns

### [Advisory Roles — To Be Confirmed]

**Legal Counsel:** Securities attorney with Reg D and DAO/LLC expertise (to be engaged for ongoing compliance)

**Property Management Advisor:** STR operations expert with 10+ years in short-term rental optimization (to be engaged for The Operator parameter tuning)

**Smart Contract Auditor:** Third-party audit firm for pre-launch security review (to be selected; budget allocated in Use of Proceeds)

**Note:** Hearth DAO operates as an algorithmically managed entity under Wyoming law. While key personnel provide strategic direction and technical development, day-to-day operations are executed by The Operator (AI management layer) under governance-approved parameters. This structure minimizes key-person risk and ensures protocol continuity regardless of individual availability.

---

## 5. Conflicts of Interest

**Disclosure of Potential Conflicts — Hearth Protocol DAO LLC**

The following potential conflicts of interest are disclosed to investors:

### Founder Compensation

Seva Lapsha, as Founder, does not receive salary, compensation, or token allocations from Hearth Protocol DAO LLC. All HRTH tokens are acquired through the same crowdsale mechanism available to all investors, at identical terms. The Founder's economic alignment is through token ownership acquired at market terms, not through preferential allocations or compensation.

### Related-Party Transactions

The Company has not entered into and does not anticipate any related-party transactions with:
- Founders, directors, or officers
- 20% beneficial owners
- Affiliates or family members of the above

Any future related-party transactions exceeding $10,000 will require:
- Disclosure to token holders
- Approval through governance proposal (majority vote)
- Documentation in Company records

### Dual Roles

Seva Lapsha serves as both Founder and Technical Architect. This dual role creates no conflict as:
- No compensation is received for either role
- Technical decisions are subject to governance approval for material changes
- Code is open-source and auditable by any token holder

### External Commitments

The Founder maintains full-time employment at DTOL. Hearth DAO operations are conducted outside of primary employment hours and do not utilize employer resources, IP, or time. No conflict exists with primary employment as Hearth is a separate legal entity with distinct operations.

### Future Ventures

The Founder may pursue other blockchain or real estate ventures in the future. Any venture that competes directly with Hearth DAO or utilizes Hearth IP will require:
- Disclosure to token holders
- Governance approval if material conflict exists
- Recusal from Hearth governance decisions affecting the competing venture

### No Placement Agent Fees

The Company is not engaging a placement agent for this offering. No fees or commissions will be paid to third parties for investor solicitation. All investor acquisitions are direct through Republic platform or Company direct solicitation.

### Ongoing Disclosure

The Company will disclose any new material conflicts of interest:
- Through Republic platform updates
- Via governance proposals if action is required
- In annual compliance reports to token holders

---

## 6. Risk Factors

**Investment in Hearth Protocol DAO LLC involves substantial risk. Prospective investors should carefully consider the following risk factors before purchasing HRTH tokens.**

### Smart Contract and Technology Risks

**Smart Contract Vulnerabilities.** The HRTH token, governance contracts, and distribution mechanisms are implemented as smart contracts on Base. Despite audits and testing, smart contracts may contain bugs, vulnerabilities, or exploits that could result in loss of funds, governance manipulation, or distribution failures. No insurance or recourse exists for smart contract losses.

**Blockchain Infrastructure Risk.** Hearth depends on Base (Coinbase L2) and Ethereum mainnet for settlement. Network congestion, consensus failures, bridge exploits, or Base infrastructure outages could disrupt token transfers, governance voting, or yield distributions. Hearth has no control over underlying blockchain infrastructure.

**Key Management Risk.** Token holders are responsible for securing their own private keys. Lost keys, phishing attacks, or wallet compromises result in permanent, irreversible loss of tokens and governance rights. The Company cannot recover lost tokens or reverse unauthorized transfers.

### Autonomous Operations and AI Failure Risks

**The Operator Decision Failures.** The AI management layer ("The Operator") makes autonomous decisions on pricing, guest communications, and maintenance dispatch. Erroneous decisions (e.g., severe underpricing, inappropriate guest responses, delayed maintenance) could reduce revenue, damage property reputation, or increase costs. No human oversight exists for routine decisions.

**No Human Property Manager.** Unlike traditional STR operations, Hearth has no on-site property manager or local emergency contact. Emergency situations (guest injuries, property damage, regulatory inspections) require remote coordination, potentially delaying response times and increasing liability exposure.

**Liability and Insurance Gaps.** Insurance policies for AI-managed properties are untested. Insurers may deny claims arising from AI decisions or autonomous operations. The Company may face uninsured liabilities from guest injuries, property damage, or regulatory violations.

**API and Integration Dependencies.** The Operator depends on third-party APIs (PriceLabs, AirDNA, Airbnb/VRBO, TaskRabbit, Thumbtack). API changes, rate limits, service outages, or terminations could disrupt operations. Alternative integrations may not be available or may require costly redevelopment.

### Regulatory and Legal Uncertainty

**DAO LLC Statute Untested.** Wyoming's DAO LLC legislation (2021) has not been tested in court. Legal challenges to DAO LLC liability protections, member rights, or algorithmic management designations could undermine the structural assumptions of this offering.

**SEC Regulatory Position Risk.** The SEC has not issued guidance on tokenized real estate, DAO LLCs, or AI-managed investment vehicles. Future SEC actions could classify HRTH tokens differently, require registration, or impose restrictions that reduce liquidity or increase compliance costs.

**Code-First Hierarchy Enforceability.** The Operating Agreement's "code-first" provision (smart contract prevails over legal text) may not be enforceable in all jurisdictions. Courts may disregard this provision, creating conflicts between on-chain governance and legal obligations.

**Securities Law Evolution.** State and federal securities laws are evolving for digital assets. Changes to Reg D, Reg S, or state Blue Sky requirements could restrict future offerings, transfers, or distributions.

### Illiquidity and Transfer Restrictions

**12-Month Hold Period.** U.S. holders are subject to a 12-month holding period under Reg D. Tokens cannot be transferred during this period except in limited circumstances (death, divorce, etc.). Investors must be prepared to hold for at least 12 months regardless of market conditions.

**Uncertain Secondary Market.** No established secondary market exists for HRTH tokens. Post-hold-period liquidity depends on buyer demand, which may be limited. Investors may be unable to sell tokens at desired prices or at all.

**Transfer Agent Discretion.** Republic's transfer agent approval is required for all transfers. The transfer agent may delay or deny transfers for compliance reasons, creating additional friction beyond smart contract restrictions.

### Real Estate Market and Operational Risks

**STR Regulatory Risk.** Short-term rental regulations are evolving rapidly. Cities and states may impose new restrictions, licensing requirements, occupancy taxes, or outright bans on STRs. Regulatory changes could reduce revenue or render the Genesis Property non-compliant.

**Market Volatility.** Real estate values and rental demand fluctuate with economic conditions, interest rates, tourism trends, and local market dynamics. The Genesis Property may experience vacancy, reduced rates, or declining property values.

**Unproven Operational Model.** Hearth's AI-managed STR model has not been tested at scale. Operational assumptions (occupancy rates, pricing optimization, maintenance costs) may prove inaccurate, resulting in lower yields than projected.

**Property-Specific Risks.** The Genesis Property may have undisclosed defects, environmental issues, title problems, or neighborhood changes that reduce value or rental potential. Due diligence may not identify all risks.

### Loss of Capital

**Speculative Investment.** Investment in Hearth DAO is highly speculative. Investors should be prepared to lose their entire investment. HRTH tokens are not suitable for investors who cannot afford total loss.

**No Dividend Guarantee.** Yield distributions depend on rental revenue, which is not guaranteed. Distributions may be zero, irregular, or less than projected. The Company makes no representations regarding future yield.

**Dilution Risk.** Future token issuances (e.g., for additional property acquisitions, team compensation, or governance grants) may dilute existing holders' ownership percentages and voting power.

---

## 7. AI Fallback/Override Mechanisms

**The Operator — Human Override and Fallback Protocols**

While Hearth DAO is designed for autonomous operations, the following fallback and override mechanisms ensure human intervention capability in exceptional circumstances:

### Governance Emergency Proposals

Token holders can initiate emergency governance proposals to:
- Pause The Operator's decision-making authority
- Override specific Operator decisions (e.g., pricing parameters, vendor selections)
- Appoint temporary human property manager for crisis situations

**Emergency Proposal Threshold:** 10% of circulating HRTH tokens can initiate an emergency proposal with 24-hour voting period (vs. standard 7-day period).

### Multi-Sig Emergency Wallet

A 3-of-5 multi-signature wallet holds emergency override authority:
- **Signers:** Founder (Seva Lapsha), 2 independent community members, 2 technical advisors
- **Capabilities:** Pause distributions, halt Operator API integrations, trigger emergency maintenance mode
- **Activation:** Requires 3 of 5 signers; used only for genuine emergencies (exploit response, regulatory action, catastrophic failure)

### Manual Intervention Triggers

The Operator monitors for conditions requiring human review:
- **Revenue Anomalies:** >50% deviation from projected revenue for 2+ weeks
- **Guest Complaints:** 3+ severe complaints within 7 days
- **Maintenance Emergencies:** Issues exceeding $5,000 or involving safety hazards
- **Regulatory Notices:** Any communication from local authorities regarding STR compliance

When triggered, these conditions generate governance alerts requiring token holder review and manual decision-making.

### Fallback Property Management

In the event of sustained Operator failure (defined as >30 days of sub-60% occupancy or >20% revenue shortfall vs. projections), governance can approve:
- Temporary engagement of traditional property manager (25–30% fee)
- Hybrid model: human manager executes, Operator advises
- Full transition to manual management until Operator issues resolved

**Cost Impact:** Fallback property management reduces net yield by 15–20% (additional fee layer) but preserves asset value and revenue continuity.

### Kill Switch

As last resort, governance can activate a "kill switch" that:
- Halts all Operator API integrations
- Freezes distributions pending manual review
- Requires 75% supermajority vote to activate
- Triggers dissolution procedures if not resolved within 90 days

### Documentation and Testing

All fallback mechanisms are:
- Documented in governance procedures
- Tested quarterly via simulation exercises
- Accessible via governance dashboard (no technical expertise required)
- Funded via operating reserve (budget allocated for emergency property manager engagement)

---

## 8. Smart Contract Audit Status

**Security Audit Plan — Hearth Protocol Smart Contracts**

### Current Status

As of March 26, 2026, the Hearth Protocol smart contracts are deployed on Base mainnet but have **not yet undergone third-party professional audit**. This is a disclosed risk for investors.

### Contracts Deployed (Unaudited)

| Contract | Address | Status |
|---|---|---|
| HearthToken (HRTH) | `0x27cfe8EdF0B8D2Af78F9668fD35aA96b612FEEDe` | Deployed, unaudited |
| HearthGovernor | `0x69B56F01098e800b836e6e8ebC1538c8E7808B47` | Deployed, unaudited |
| HearthTimelock | `0xc13E5FFaE89324fA5bb2eb7cB2a021aB15d71d6F` | Deployed, unaudited |
| HearthCrowdsale | `0xef990083409741011b6ed280a1519D75De8F8012` | Deployed, unaudited |

### Audit Commitment

The Company commits to completing third-party smart contract audits **prior to closing** this offering. Audit scope includes:

**Security Audit:**
- Reentrancy vulnerabilities
- Access control weaknesses
- Integer overflow/underflow
- Logic errors in governance flows
- Timelock bypass attempts
- Token transfer restrictions

**Economic Audit:**
- Governance attack vectors (vote buying, flash loan attacks)
- Distribution mechanism fairness
- Crowdsale rate manipulation risks
- Timelock parameter adequacy

### Audit Firm Selection

The Company will engage a top-tier audit firm from the following candidates:
- OpenZeppelin Audits
- Trail of Bits
- Consensys Diligence
- Spearbit
- Halborn

**Budget:** $30,000–$50,000 allocated in Use of Proceeds for comprehensive audit.

### Audit Timeline

- **Week 1–2:** Contract freeze (no further changes before audit)
- **Week 3–6:** Audit engagement and review period
- **Week 7:** Remediation of identified issues
- **Week 8:** Final audit report publication
- **Week 9:** Closing of offering (contingent on clean audit report)

### Post-Audit Commitments

- **Public Report:** Full audit report (including findings and remediations) will be published on Company website and GitHub
- **Bug Bounty:** Post-audit, Company will maintain $50,000 bug bounty program for responsible disclosure of vulnerabilities
- **Ongoing Review:** Annual smart contract reviews for any upgrades or modifications
- **Upgrade Governance:** All contract upgrades require governance approval via timelock proposal

### Interim Risk Mitigation

Until audit completion, the Company has implemented:
- **Timelock Protection:** All governance actions subject to 24-hour timelock, allowing token holders to exit if malicious proposals pass
- **Crowdsale Cap:** Maximum raise capped at $500,000, limiting exposure
- **Owner Controls:** Crowdsale contract owner (Founder) can pause contributions if anomalies detected
- **Transparency:** All contracts are open-source and verified on Base block explorer for community review

### Audit Contingency

If audit reveals critical vulnerabilities that cannot be remediated within 30 days:
- Offering will be delayed until issues resolved
- Investors who contributed will receive full refunds
- Contracts will be redeployed post-remediation and re-audited

**Investor Acknowledgment:** By participating in this offering, investors acknowledge that contracts are currently unaudited and accept the associated risk. Audit completion is a closing condition, not a post-closing commitment.

---

## 9. Competitive Edge

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
Syndications offer asset specificity but concentrate power in the General Partner, who controls operations, distributions, and exit timing. Fee structures (2