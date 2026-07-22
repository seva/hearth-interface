# Architecture

---

## Principles

**Legal compliance first.** All actions must comply with Wyoming DAO LLC law, SEC regulations, and securities laws. When in doubt, escalate to counsel.

**Separation of concerns.** Legal, governance, treasury, and product layers are separate. No cross-cutting logic.

**Isolation of fragility.** External dependencies (Republic platform, Mercury banking, Base network) are isolated. When they change, only the integration layer updates.

**Security.** Private keys never in plaintext on disk or in logs. Secrets never surfaced in tool or API output. Deployer keys are cold storage.

---

## Coding Hygiene

Guard clauses. Graceful degradation. No silent failures. Explicit error types.

Code as documentation — names and structure must be self-explanatory. Comments explain why, not what. Maximize semantic and cognitive ROI.

---

## System Diagram

```
LEGAL LAYER
├── Wyoming DAO LLC (Entity ID: 2026-001894157)
├── Operating Agreement
├── Securities Counsel (#48)
└── Reg D Offering via Republic (#91)

GOVERNANCE LAYER
├── Governor Contract (0x69B56F01098e800b836E6E8EbC1538C8E7808B47)
├── Timelock Contract (0x171e4e986addd4c81ac0f10f96eacb2688e8958a)
├── Safe Multisig (0x89f549a273a14910191b61911101963b44bab681)
└── Cold Wallet (0xb83B4A6cF92408994A29F930fbfb6aE322c3448B)

TREASURY LAYER
├── HRTH Token (9.9M supply)
├── Crowdsale Contract (not deployed — gated on #48)
└── Mercury Bank Account (#17)

PRODUCT LAYER
├── Fractional vacation homes
├── Tokenized real estate
└── Website (website/)
```

---

## Components

| Component | Responsibility | Key interface |
|---|---|---|
| Governor | On-chain governance proposals and voting | `propose()`, `castVote()`, `queue()`, `execute()` |
| Timelock | 24-hour delay between approval and execution | `schedule()`, `execute()`, `cancel()` |
| Safe | Multisig treasury executor | Transaction Builder, contract interactions |
| HRTH | ERC-20 governance token | `transfer()`, `delegate()`, `balanceOf()` |
| Crowdsale | Token sale (not deployed) | `buyTokens()`, `claimTokens()` |

---

## Design Decisions

| Decision | Choice | Rationale |
|---|---|---|
| Jurisdiction | Wyoming DAO LLC | Most mature DAO legal framework, entity recognition |
| Token standard | ERC-20 | Governance compatibility, exchange listings |
| Treasury | Safe multisig | Industry standard, multisig security |
| Offering | Reg D via Republic | Accredited investors, compliance-first |
| Network | Base L2 | Low gas costs, Ethereum security |

---

## Constraints

- **Securities counsel** (#48) gates Reg D offering. No token sales without legal review.
- **Smart contract audit** gates mainnet deployment. No unaudited contracts.
- **Governance process** gates treasury actions. All Safe transactions require proposal + vote.
- **Cold wallet** must vote on all proposals. 9.9M HRTH exceeds 4% quorum.
- **Wyoming annual report** due Feb 1 each year. Late filing triggers administrative dissolution.

---

## Entity Information

- **Entity ID:** 2026-001894157
- **EIN:** Pending (faxed 2026-02-12, awaiting 147C letter)
- **Registered Agent:** Northwest Registered Agent
- **Formation Date:** February 12, 2026
- **State:** Wyoming

---

## Contract Addresses (Base Mainnet)

- **Governor:** `0x69B56F01098e800b836E6E8EbC1538C8E7808B47`
- **Timelock:** `0x171e4e986addd4c81ac0f10f96eacb2688e8958a`
- **Safe:** `0x89f549a273a14910191b61911101963b44bab681`
- **HRTH:** (deployed, address in `protocol/artifacts/`)
- **Cold Wallet:** `0xb83B4A6cF92408994A29F930fbfb6aE322c3448B`

_Last verified: 2026-07-22_
