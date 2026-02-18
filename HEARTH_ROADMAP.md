# HEARTH DAO: ROADMAP & NEXT STEPS
*Last Updated: 2026-02-16*

## Strategy: Regulated Token Sale via Platform

**Core decision (2026-02-16):** HRTH is a security under Howey. Instead of avoiding classification, we embrace it and sell through a regulated platform (Republic or Securitize) under Reg D 506(c).

- **Token sale:** Via Republic/Securitize, NOT via on-chain crowdsale contract
- **Website (hearthdao.com):** Marketing & governance info only. No direct token purchase.
- **Messaging:** "HRTH tokens are not available for direct purchase. Qualified investors can participate through [platform]."
- **Legal cost:** $2-5K (attorney reviews platform's docs). Platform handles Reg D filing, KYC/AML, accredited investor verification.
- **Platform fee:** 5-10% of raise ($25-50K on $500K target)
- **On-chain crowdsale contract:** Deprioritized. Not needed for initial raise. May be used later for public sale if/when regulations allow.

## Phase 1: Foundation (COMPLETED)
- **Legal Entity:** Hearth Protocol DAO LLC formed in Wyoming (ID: 2026-001894157).
- **Privacy:** Physical address shielded via Northwest Registered Agent.
- **EIN Application:** Faxed manually via FaxZero (2026-02-12). Cancelled costly Northwest order.
- **Governance:** "Algorithmically Managed" designation secured in Articles.

## Phase 2: Identity & Banking (BLOCKED)
**Blocker:** Waiting for EIN Letter (CP-575) by mail (~4-6 weeks from Feb 12).
1.  **Monitor:** Check email for FaxZero 'Delivered' receipt + Northwest Refund ($200). (#8)
2.  **Bank Account:** Open fiat rail (Mercury) using Articles + SS-4 Copy. (#17, blocked on EIN)
3.  **Domain & Website:** Secured `hearthdao.com`. Live on Vercel. **DONE.**

## Phase 3: Mainnet Launch (DUE: MAR 14, 2026)
**Hard Deadline:** Wyoming requires the "Public Identifier" (Contract Address) within 30 days of formation.

### Testnet (COMPLETED)
- `HearthToken.sol` (ERC20Votes) — `0x27cfe8EdF0B8D2Af78F9668fD35aA96b612FEEDe`
- `HearthGovernor.sol` (OZ Governor) — `0x70C5A7d5FBc03DeCBB15332BE384791645041387`
- `HearthTimelock.sol` (TimelockController) — `0xc13E5FFaE89324fA5bb2eb7cB2a021aB15d71d6F`
- `Crowdsale.sol` (USDC Crowdsale) — `0xef990083409741011b6ed280a1519D75De8F8012`
- All verified on Base Sepolia.

### Mainnet Critical Path

**Deploy governance only.** Crowdsale contract is NOT deployed to mainnet — token sale goes through Republic/Securitize instead.

```
#46 Unit Tests ──┐
                 ├──> #49 Security Audit ──> #50 Mainnet Deploy ──> #51 File Amendment
#3  Governor     ┘    (governance only)      (Token+Governor+     (blocked:human)
    Verify ──────┘                            Timelock only)
```

**Week 1 (Feb 14-21):**
- [x] #46 — Unit tests for Token, Governor, Timelock (VixeYult) — DONE
- [ ] #3 — Governor verification with real tests (VixeYult)
- [x] #49 Phase 1 — Run Slither automated analysis (VixeYult) — DONE

**Week 2 (Feb 21-28):**
- [ ] #49 Phase 2 — Manual code review (MetaThrone)
- [ ] Fund deployer on Base Mainnet (~0.01 ETH, ~$27) (Seva)
- [ ] #50 — Deploy governance contracts to mainnet — Token, Governor, Timelock only. No Crowdsale.

**Week 3 (Feb 28 - Mar 7):**
- [ ] #51 — File Wyoming amendment with Governor address (Seva, blocked:human)
- [ ] #52 — Deploy Gnosis Safe multisig, transfer ownership (VixeYult)

**Week 4 (Mar 7-14) — Buffer:**
- [ ] Fix anything broken

### SWOT Analysis (Feb 16, 2026)

#### Strengths
- **Wyoming DAO LLC formed** — "Algorithmically Managed" designation secured in Articles of Organization
- **Smart contracts written, tested, and audited** — #46 unit tests done, #49 Slither analysis done
- **Testnet deployment complete** — Token, Governor, Timelock, Crowdsale verified on Base Sepolia
- **hearthdao.com live** on Vercel with governance info
- **Regulated token sale strategy** — Reg D 506(c) via Republic/Securitize. Compliance by design, not avoidance
- **AI agent ops** — VixeYult + MetaThrone provide low-opex 24/7 execution
- **Seva's LinkedIn network** — 1,429 VP-level connections = direct accredited investor channel
- **Base L2** — low gas costs, Coinbase ecosystem distribution
- **Low burn rate** — DeepSeek V3.2 @ $0.25/$0.38/M tokens; no employees, no office

#### Weaknesses
- **Solo founder** — single point of failure for all human-gated tasks (signing, legal, banking)
- **No revenue or track record** in property acquisition/management
- **No securities attorney retained** — needed for platform application review (#48)
- **EIN pending** (~4 weeks) — blocks banking, fiat rails (#8, #17)
- **Agent reliability issues** — fabricated results, stuck loops, memory wipes documented
- **Crowdsale contract + frontend partially obsoleted** by platform pivot
- **Brand new entity** — no credit history, no operational history
- **No real estate domain expertise** on team

#### Opportunities
- **Arizona HB2363 STR caps** — first-mover advantage on inventory acquisition before caps apply
- **RWA tokenization market growing** — RealT, Lofty validating the model, institutional interest rising
- **Republic/Securitize built-in investor bases** — millions of existing accredited investors on platform
- **Wyoming = most DAO-friendly US jurisdiction** — regulatory arbitrage
- **Reg D 506(c) allows open marketing** to accredited investors (unlike 506(b))
- **RentAHuman.ai** for agent-to-human physical task delegation (inspections, notary, cleaning) — future capability
- **Progressive decentralization** → stronger "not a security" argument over time as governance distributes
- **AI-managed ops = structurally lower opex** than traditional RE funds → higher yield to token holders

#### Threats & Risk Register

| Risk | Severity | Mitigation | Status |
|------|----------|------------|--------|
| Platform rejection (Republic/Securitize decline — new entity, no track record) | **High** | #62 — Prepare backup plan (Reg D DIY vs. alternative platform) | **NEW** |
| March 14 deadline miss — 26 days to deploy + file amendment | **High** | Deploy governance only (not crowdsale) to mainnet ASAP. Buffer week built in. | On track |
| Mainnet deploy blocked on funding (~$27 ETH manual action) | **Medium** | #50 — Seva funds deployer wallet. Low cost, just needs action. | blocked:human |
| SEC scrutiny even with Reg D (DAO + tokenized RE is novel) | **High** | Platform handles filing + compliance. Attorney reviews. #48 | In progress |
| Competition from established RWA platforms (RealT, Lofty) | **Medium** | Differentiation: AI-managed, lower fees, DAO governance. No issue needed. | Accepted |
| AZ HB2363 passes before first acquisition → STR caps apply | **Medium** | Urgency baked into Phase 5. Move fast post-raise. | Accepted |
| No EIN = no bank = can't receive fiat or close on property | **High** | #8, #17 — Monitoring. ~4 week lead time from Feb 12. | Waiting |
| Key person risk (Seva unavailable = everything stops) | **High** | #63 — Document all manual processes for delegation | **NEW** |
| Unaudited contracts on mainnet | **Critical** | #49 — Slither done + manual review pending | Phase 1 done |
| Single deployer key (EOA) | **High** | #52 — Gnosis Safe multisig post-deploy | Open |
| Smart contract vulnerabilities not caught by automated tools | **High** | #49 Phase 2 — Manual code review by MetaThrone | Pending |
| Agent executes bad tx on mainnet | **High** | Agent does NOT get mainnet private key. Human signs all mainnet tx. | Standing rule |
| Agent instability during critical operational phases | **Medium** | Circuit breaker rules, session reset procedures, MetaThrone oversight | Standing rules |
| Accredited-only limits buyer pool vs. Reg A+ / Reg CF | **Medium** | Phase 1 raise is accredited-only. Consider Reg A+ for follow-on if traction. | Accepted |
| Platform fee (5-10%) reduces capital for acquisition | **Low** | $25-50K on $500K target. Acceptable cost of compliance. | Accepted |

## Phase 4: Capital Raise (GATED on Phase 3 + Platform Approval)
**Gate:** Do NOT raise capital until (a) governance is on mainnet and (b) Republic/Securitize listing is approved.

1.  **Platform application:** Apply to Republic or Securitize. ~1-2 weeks approval.
2.  **Legal review:** Attorney reviews platform's docs ($2-5K).
3.  **Mint tokens:** All HRTH minted to founder wallet.
4.  **List offering:** Sell HRTH via platform to accredited investors. Target: $500K.
5.  **Website update:** Point hearthdao.com to platform listing. No direct purchase on site.

## Phase 5: Asset Acquisition (GATED on Phase 4)
1.  **Acquisition:** Purchase first AZ property (before HB2363 STR caps, target Q2 2026).
2.  **Automation:** Property yields → Treasury → Token Holders (USDC distribution via Merkle Distributor or claim contract).
3.  **Ops:** RentAHuman integration for physical task delegation (inspections, cleaning, repairs).

## Parallel Tracks (Non-Blocking)

| Track | Issues | Owner | Priority |
|-------|--------|-------|----------|
| Website update | NEW — update messaging, remove direct sale | VixeYult | P1 |
| Banking | #8, #17 | Seva (waiting) | P1, blocked on EIN |
| Agent Cost | #60 | VixeYult | P1 |
| Roadmap Grooming | #34, #38 | VixeYult | P2 |
