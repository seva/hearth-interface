# Reg D DIY Contingency Plan

**Status:** Research Complete  
**Issue:** #62  
**Last Updated:** 2026-02-25  
**Purpose:** Establish a concrete fallback for a direct Reg D 506(c) token sale if Republic/Securitize reject Hearth DAO's application.

---

## Executive Summary

If Hearth DAO is rejected by institutional platforms (Republic, Securitize), a DIY token sale is feasible but requires:
1. **KYC/AML Provider** — Accredited investor verification + identity checks
2. **Whitelist Infrastructure** — Permissioned token standard or manual whitelist contract
3. **Legal/Operational Compliance** — Form D filing, bad actor checks, state blue sky notices

Estimated DIY setup cost: **$3,000–10,000** (one-time) + **$50–150/investor** (variable).

---

## 1. KYC/AML Providers (Crypto-Native, Reg D Compliant)

### Recommended: VerifyInvestor.com ⭐

| Attribute | Details |
|-----------|---------|
| **Specialization** | 506(c) accredited investor verification (attorney-reviewed) |
| **Pricing** | ~$75–150/verification (issuer-paid or investor-paid models) |
| **Integration** | Embedded API (JavaScript widget) or manual email-based flow |
| **Crypto Features** | **On-ChainPass**: Soulbound Token (SBT) for reusable on-chain accreditation |
| **Ownership** | Majority owned by tZERO (NYSE/ICE investor) |
| **Why Pick** | Purpose-built for 506(c) compliance; attorney certification meets "reasonable steps" standard; On-ChainPass enables wallet whitelisting without re-verification |
| **Setup** | ~$0 (pay-per-verification); API integration in 1–2 days |

**Integration Path:**
```javascript
// Embed widget on Hearth sale page
<script src="https://www.verifyinvestor.com/embedded.js" 
        data-api-token="YOUR_TOKEN" 
        data-identifier="hearth-dao-2026"></script>
```
Upon verification, add wallet to HearthCrowdsale whitelist via `setWhitelist(address, true)`.

---

### Alternative 1: Parallel Markets

| Attribute | Details |
|-----------|---------|
| **Specialization** | KYC/KYB, AML, 506(c) Accreditation via iCapital Markets (FINRA member) |
| **Pricing** | Enterprise (contact required); free accreditation for investors via network |
| **Integration** | Full REST API; portable identity across platform |
| **Crypto Features** | Avalanche txAllowlist integration documented; generic wallet-binding support |
| **Why Consider** | Reusable identity reduces friction for repeat investors; institutional-grade |
| **Drawback** | No public pricing; likely $5K+ setup + per-verification fees |

---

### Alternative 2: Sumsub

| Attribute | Details |
|-----------|---------|
| **Specialization** | Global KYC/AML (ID verification, liveness, AML screening) |
| **Pricing** | **Basic:** $1.35/verification ($149/mo minimum); **Compliance:** $1.85/verification ($299/mo minimum) |
| **Integration** | SDK (Web, iOS, Android), REST API |
| **Crypto Features** | Wide crypto industry adoption; supports 220+ countries |
| **Why Consider** | Cheapest per-verification cost; AML screening included in Compliance tier |
| **Drawback** | No built-in accredited investor verification — need to combine with manual self-certification or attorney review |

**Note:** Sumsub provides KYC identity verification but not formal accredited investor certification. For 506(c), pair with manual self-certification + issuer records, or use VerifyInvestor for the accreditation layer and Sumsub for AML only.

---

### Provider Comparison Matrix

| Provider | Accredited Investor Verification | KYC/AML | Per-Check Cost | Setup Cost | API | On-Chain |
|----------|----------------------------------|---------|----------------|------------|-----|----------|
| **VerifyInvestor** | ✅ Attorney-certified | ✅ | $75–150 | $0 | ✅ | ✅ (SBT) |
| **Parallel Markets** | ✅ FINRA broker-dealer | ✅ | $50–100 (est.) | $5K+ (est.) | ✅ | ⚠️ Manual |
| **Sumsub** | ❌ (KYC only) | ✅ | $1.35–1.85 | $150–300/mo | ✅ | ❌ |

**Recommendation:** **VerifyInvestor** for zero-touch automation (On-ChainPass SBT → whitelist). Use Sumsub as supplementary AML if VerifyInvestor's AML isn't sufficient.

---

## 2. Launch Infrastructure (Self-Hosted / No-Code Platforms)

### Option A: Custom Whitelist Contract (Zero-Code DIY) ⭐

Hearth already has `HearthCrowdsale` deployed with owner-managed whitelist functionality. The DIY path:

1. **Frontend:** Existing hearth-interface Next.js app + RainbowKit
2. **Verification:** VerifyInvestor widget embeds in sale page
3. **Whitelist Management:** Admin script calls `setWhitelist(address, true)` for verified investors
4. **Purchase Flow:** Verified investors connect wallet → buy tokens via crowdsale contract

**Pros:**
- No third-party platform fees
- Full control over UX and branding
- Existing infrastructure (90% built)

**Cons:**
- Manual whitelist updates (unless automated via webhook)
- No secondary market infrastructure

**Enhancement for Automation:**
Integrate VerifyInvestor webhook → backend API → automatic whitelist update:
```
VerifyInvestor → Webhook POST → Hearth API → HearthCrowdsale.setWhitelist(wallet, true)
```

---

### Option B: Tokensoft (Managed STO Platform)

| Attribute | Details |
|-----------|---------|
| **Type** | White-label SaaS token sale platform |
| **Compliance** | Reg D, Reg S, Reg A+ (US and 50+ international jurisdictions) |
| **Features** | Investor onboarding, KYC/AML, token distribution, custody integration |
| **Integration** | Managed (they host everything) or API-based |
| **Broker-Dealer** | Acquired SEC-registered broker-dealer for full-service offerings |
| **Volume** | $1B+ raised across clients |
| **Pricing** | Enterprise (contact required); typically $20K–50K+ setup + % of raise |

**Pros:**
- Turnkey solution; proven compliance track record
- Can choose self-hosted or managed

**Cons:**
- Expensive; overkill for $500K raise
- Platform dependency

**Verdict:** Consider only if DIY complexity becomes unmanageable.

---

### Option C: ERC-3643 (T-REX) Self-Deploy

ERC-3643 is the permissioned token standard for security tokens. It embeds compliance rules at the token level.

| Component | Function |
|-----------|----------|
| **Identity Registry** | On-chain whitelist of verified wallets |
| **Compliance Module** | Rules engine (max holders, transfer restrictions) |
| **Trusted Issuers** | KYC providers issue on-chain claims |
| **Token** | ERC-20 compatible but transfers validate against compliance |

**Deployment Approach:**
1. Deploy ERC-3643 token suite from [erc3643.org](https://www.erc3643.org/) (open source)
2. Configure Hearth DAO as Issuer Agent
3. Integrate VerifyInvestor as Claim Issuer (via On-ChainPass SBT or manual)
4. Only wallets with valid claims can hold/transfer tokens

**Pros:**
- Fully on-chain compliance
- Transfer restrictions survive secondary markets
- Industry standard for RWA tokenization

**Cons:**
- Significant smart contract complexity
- Must migrate from current HearthToken (ERC-20)
- Audit required for new contracts

**Verdict:** Ideal for future-proofing; not recommended for initial $500K raise due to timeline.

---

### Platform Recommendation

**For Hearth DAO's $500K Reg D 506(c) raise:**

| Priority | Option | Why |
|----------|--------|-----|
| 1️⃣ | **Custom Whitelist (Option A)** | Zero additional cost; leverages existing contracts; full control |
| 2️⃣ | ERC-3643 (Option C) | Consider for v2 or post-mainnet governance contracts |
| 3️⃣ | Tokensoft (Option B) | Only if regulatory counsel requires managed platform |

---

## 3. Legal/Operational Checklist (DIY Reg D 506(c) Sale)

### Pre-Sale Requirements

| Task | Description | Deadline | Owner |
|------|-------------|----------|-------|
| ☐ **Securities Counsel Engagement** | Engage attorney for PPM, subscription agreement, Form D | Before marketing | Seva |
| ☐ **Private Placement Memorandum (PPM)** | Disclosure document for investors | Before first solicitation | Counsel |
| ☐ **Subscription Agreement** | Investment contract with representations | Before first investment | Counsel |
| ☐ **Bad Actor Check (Rule 506(d))** | Verify no covered person has disqualifying events | Before first sale | Counsel/Issuer |
| ☐ **KYC/AML Provider Setup** | Activate VerifyInvestor or equivalent | Before investor onboarding | Ops |
| ☐ **Whitelist Contract Audit** | Verify HearthCrowdsale whitelist logic is secure | Before sale opens | Dev/Audit |

---

### Bad Actor Disqualification Check (Rule 506(d))

**Covered Persons to Screen:**
1. The issuer (Hearth Protocol DAO LLC)
2. Directors, officers, general partners of issuer
3. 20%+ beneficial owners
4. Promoters connected to issuer
5. Compensated solicitors (if any)
6. Directors, officers, general partners of any compensated solicitor

**Disqualifying Events (within 5–10 years depending on type):**
- Criminal convictions (securities fraud, etc.)
- Court injunctions/orders related to securities
- SEC disciplinary orders
- State regulatory bars
- FINRA or exchange suspensions
- SEC stop orders on offerings

**Process:**
1. Collect bad actor questionnaires from all covered persons
2. Run background checks (counsel typically handles)
3. Document negative results for file
4. If any events found, assess if pre-existing (exempt) or requires SEC waiver

**Template:** [Westlaw Bad Actor Questionnaire](https://content.next.westlaw.com/practical-law/document/Ibabdd724642411e38578f7ccc38dcbee/)

---

### Post-First-Sale Requirements

| Task | Description | Deadline | Owner |
|------|-------------|----------|-------|
| ☐ **SEC Form D Filing** | File via EDGAR | Within 15 days of first sale | Counsel/Issuer |
| ☐ **State Blue Sky Notices** | File in each state where investors reside | Varies by state (typically 15 days) | Counsel |
| ☐ **Investor Records** | Maintain accreditation letters, subscription agreements | Ongoing | Ops |
| ☐ **506(c) Verification Documentation** | Retain VerifyInvestor letters for each investor | Ongoing (min 5 years) | Ops |

---

### SEC EDGAR Form D Filing

**Requirements:**
1. Obtain SEC EDGAR CIK number (filer ID) and password at [SEC EDGAR Filer Management](https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&company=hearth&type=D&dateb=&owner=include&count=40)
2. File Form D online within 15 days of first sale
3. Form D is a notice filing (brief; ~2 pages of info)

**Information Needed:**
- Issuer name, address, jurisdiction (Wyoming)
- Industry group (likely "Pooled Investment Fund" or "Real Estate")
- Exemption claimed: Rule 506(c)
- Offering amount, amount sold, minimum investment
- Names of executive officers, directors, promoters
- Sales compensation recipients (if any)

**Cost:** $0 (no filing fee for Form D)

---

### State Blue Sky Notices

Rule 506(c) preempts most state substantive requirements, but **notice filings** are still required in states where you have investors.

| State | Requirement | Fee | Deadline |
|-------|-------------|-----|----------|
| All states | File Form D copy + state cover form | $0–500 | Typically 15 days post-first-sale |
| California | File via DBO portal | ~$300 | 15 calendar days |
| New York | Martin Act notice (if >5 NY investors) | $0 | Promptly |
| Texas | File via SSB | $500 | 15 days |

**Process:**
1. Track investor state of residence
2. File notice in each applicable state after first sale
3. Use [NASAA EFD](https://www.efdnasaa.org/) for multi-state filing (covers ~40 states)

**Note:** Wyoming (Hearth's home state) requires no additional notice for Reg D issuers.

---

## 4. Cost Summary (DIY Path)

| Category | Low Estimate | High Estimate | Notes |
|----------|--------------|---------------|-------|
| **Securities Counsel (PPM, Sub Agmt)** | $5,000 | $15,000 | Flat fee engagement |
| **Bad Actor Background Checks** | $500 | $1,500 | Per covered person |
| **KYC Provider (VerifyInvestor)** | $75/investor | $150/investor | 50 investors = $3,750–7,500 |
| **Form D Filing** | $0 | $0 | No SEC fee |
| **State Blue Sky Filings** | $500 | $2,000 | Depends on investor geography |
| **Contract Audit (optional)** | $3,000 | $10,000 | If whitelist logic is modified |
| **TOTAL (50 investors)** | ~$9,000 | ~$30,000 | Variable based on counsel fees |

---

## 5. Recommended Action Plan

### If Platform Rejected:

1. **Week 0:** Engage securities counsel (if not already)
2. **Week 1:** Complete bad actor questionnaires; finalize PPM and subscription agreement
3. **Week 2:** Activate VerifyInvestor account; integrate widget on hearth-interface
4. **Week 2:** Implement webhook → whitelist automation (optional but recommended)
5. **Week 3:** Soft launch to first 5–10 investors; validate flow
6. **Week 3+15 days:** File Form D on EDGAR after first sale
7. **Ongoing:** File state notices as investors from new states participate

### Automation Priority (Zero-Touch Philosophy):

| Component | Manual | Automated | Priority |
|-----------|--------|-----------|----------|
| Accreditation verification | ❌ | ✅ VerifyInvestor | P0 |
| Wallet whitelisting | ⚠️ Admin script | ✅ Webhook integration | P1 |
| Token purchase | ✅ Via crowdsale UI | ✅ | Done |
| Form D filing | ✅ One-time | n/a | P0 |
| Blue sky notices | ✅ Per-state | ⚠️ NASAA EFD | P1 |

---

## 6. Risk Assessment

| Risk | Mitigation |
|------|------------|
| **SEC scrutiny of DIY sale** | Use attorney-verified accreditation (VerifyInvestor); maintain complete records |
| **State enforcement** | File blue sky notices in all applicable states |
| **Bad actor disqualification** | Complete thorough background checks before first sale |
| **Whitelist contract bug** | Audit whitelist logic; use time-tested patterns |
| **Investor UX friction** | Streamlined widget flow; clear instructions |

---

## References

- [SEC Form D Overview](https://www.sec.gov/resources-small-businesses/capital-raising-building-blocks/what-form-d)
- [Rule 506(c) General Solicitation](https://www.sec.gov/resources-small-businesses/exempt-offerings/general-solicitation-rule-506c)
- [Bad Actor Disqualification Guide (SEC)](https://www.sec.gov/resources-small-businesses/small-business-compliance-guides/disqualification-felons-other-bad-actors-rule-506-offerings-related-disclosure-requirements)
- [VerifyInvestor.com](https://www.verifyinvestor.com/)
- [Parallel Markets](https://parallelmarkets.com/)
- [Sumsub Pricing](https://sumsub.com/pricing/)
- [ERC-3643 T-REX Standard](https://www.erc3643.org/)
- [NASAA Electronic Filing Depository](https://www.efdnasaa.org/)

---

*Document Author: Research Subagent*  
*Review Required: Securities Counsel*
