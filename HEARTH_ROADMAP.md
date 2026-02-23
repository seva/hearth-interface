# HEARTH DAO: ROADMAP & NEXT STEPS
*Last Updated: 2026-02-23*

## Strategy: Regulated Token Sale via Platform

**Core decision (2026-02-16):** HRTH is a security under Howey. Instead of avoiding classification, we embrace it and sell through a regulated platform (Republic or Securitize) under Reg D 506(c).

- **Token sale:** Via Republic (Primary), NOT via on-chain crowdsale contract
- **Website (hearthdao.com):** Marketing & governance info only. No direct token purchase.
- **Messaging:** "HRTH tokens are not available for direct purchase. Qualified investors can participate through [platform]."
- **Legal cost:** $2-5K (attorney reviews platform's docs). Platform handles Reg D filing, KYC/AML, accredited investor verification.
- **On-chain crowdsale contract:** Deprioritized. Not needed for initial raise.

## Phase 1: Foundation (COMPLETED)
- **Legal Entity:** Hearth Protocol DAO LLC formed in Wyoming (ID: 2026-001894157).
- **EIN Application:** Faxed 2026-02-12. **PENDING.**

## Phase 2: Identity & Banking (BLOCKED)
**Blocker:** Waiting for EIN Letter (CP-575) by mail (~4-6 weeks from Feb 12).
1.  **Monitor:** Issue #8. Check for FaxZero receipt & Northwest refund ($200).
2.  **Bank Account:** Issue #17. Open Mercury account (Blocked on EIN).

## Phase 3: Mainnet Launch (DUE: MAR 14, 2026)
**Hard Deadline:** Wyoming requires Public Identifier (Governor Address) within 30 days.

### Mainnet Critical Path
```
#46 Tests ────────┐
                   ├──> #49 Audit (Slither+Manual) ──> #50 Mainnet Deploy ──> #51 NW Amendment
#3  Gov Verify ────┘                                  (COMPLETED)           (In Progress - NW)
```

**Week 1-2 (Feb 14-23):**
- [x] #46 — Tests (Token, Gov, Timelock) — DONE
- [x] #3 — Governor verification with real tests — DONE
- [x] #49 — Security Audit (Slither + Manual) — DONE
- [x] #50 — Deploy governance contracts to Base Mainnet — DONE
- [x] #71 — Guild Auction Reconsideration (Deprecated) — DONE

**Week 2-3 (Feb 23-Mar 7):**
- [ ] #51 — Monitor Northwest Registered Agent for Amendment Filing
- [ ] #52 — Deploy Gnosis Safe multisig, transfer ownership

**Week 3-4 (Mar 7-14):**
- [ ] #51 — Final confirmation of Wyoming SOS identifier update (Hard Deadline: Mar 14)

## Phase 4: Capital Raise (GATED on Phase 3 + Republic Approval)
1.  **Platform application:** Apply to Republic (Responses staged in `docs/REPUBLIC_APPLICATION_RESPONSES.md`).
2.  **Legal review:** Retain counsel for platform docs review (#48).
3.  **Launch Offering:** Target: $500K raise via Republic platform.

## Threats & Risk Register

| Risk | Severity | Mitigation | Status |
|------|----------|------------|--------|
| Platform rejection | **High** | #62 — Prepare backup plan (Reg D DIY) | Triggered if Republic rejects |
| March 14 deadline miss | **High** | #50 — Deploy governance ASAP. | Pending funding |
| No EIN / No bank | **High** | #8, #17 — Routine monitoring. | Pending IRS |
| Unaudited contracts | **Critical** | #49 — Slither + Manual Review. | DONE |
