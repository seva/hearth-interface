# HEARTH PROTOCOL: ROADMAP & NEXT STEPS
*Last Updated: 2026-02-14*

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

```
#46 Unit Tests ──┐
                 ├──> #49 Security Audit ──> #50 Mainnet Deploy ──> #51 File Amendment
#3  Governor     ┘                                                   (blocked:human)
    Verify ──────┘

#48 Securities Counsel ── parallel, blocked:human, start NOW
```

**Week 1 (Feb 14-21):**
- [ ] #46 — Unit tests for Token, Governor, Timelock (VixeYult)
- [ ] #3 — Governor verification with real tests (VixeYult)
- [ ] #49 Phase 1 — Run Slither automated analysis (VixeYult)
- [ ] #48 — Find and retain securities attorney (Seva, blocked:human)

**Week 2 (Feb 21-28):**
- [ ] #49 Phase 2 — Manual code review (MetaThrone)
- [ ] Fund deployer on Base Mainnet (~0.01 ETH, ~$27) (Seva)
- [ ] #50 — Deploy governance contracts to mainnet (VixeYult). **Crowdsale NOT funded until #48 clears.**

**Week 3 (Feb 28 - Mar 7):**
- [ ] #51 — File Wyoming amendment with Governor address (Seva, blocked:human)
- [ ] #52 — Deploy Gnosis Safe multisig, transfer ownership (VixeYult)
- [ ] Receive legal opinion from #48

**Week 4 (Mar 7-14) — Buffer:**
- [ ] Fix anything broken
- [ ] Crowdsale goes live ONLY if #48 (securities counsel) clears

### SWOT-Derived Risks (Feb 14 Analysis)

| Risk | Severity | Mitigation |
|------|----------|------------|
| SEC enforcement (HRTH = security) | **Existential** | #48 — retain counsel before any token sale |
| Unaudited contracts on mainnet | **Critical** | #49 — Slither + manual review, fix all findings |
| Single deployer key (EOA) | **High** | #52 — Gnosis Safe multisig |
| No contract tests (3/4 untested) | **High** | #46 — write Governor/Token/Timelock tests |
| March 14 deadline miss | **High** | Deploy governance (not crowdsale) to mainnet ASAP |
| Agent executes bad tx on mainnet | **High** | Agent does NOT get mainnet private key. Human signs. |

## Phase 4: Capital & Asset Acquisition (GATED on Phase 3 + Legal)
**Gate:** Do NOT proceed until #48 (securities counsel) provides clearance.

1.  **Crowdsale:** Fund crowdsale contract, open to investors. Target: $500k USDC.
2.  **Acquisition:** Purchase first AZ property (before HB2363 STR caps, target Q2 2026).
3.  **Automation:** Property yields -> Treasury -> Token Holders (USDC distribution via Merkle Distributor or claim contract).
4.  **Ops:** RentAHuman integration for physical task delegation (inspections, cleaning, repairs).

## Parallel Tracks (Non-Blocking)

| Track | Issues | Owner | Priority |
|-------|--------|-------|----------|
| Frontend MVP | #43, #44, #45, #47 | VixeYult | P0 (crowdsale UI) / P2 (bugs) |
| Banking | #8, #17 | Seva (waiting) | P1, blocked on EIN |
| Agent Cost | #53 | VixeYult | P2 |
| Codebase Cleanup | #33 | VixeYult | P2 |
| Roadmap Grooming | #34, #38 | VixeYult | P2 |
