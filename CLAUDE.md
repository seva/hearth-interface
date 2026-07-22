# Hearth DAO — Session Bootstrap

## Project

**Hearth Protocol DAO LLC** — Wyoming DAO LLC (Entity ID: 2026-001894157)

Fractional vacation homes via tokenized real estate. Reg D offering via Republic.

## Session Start

1. Read `METHODOLOGY.md`
2. Read `ARCHITECTURE.md` — verify component descriptions match current state
3. Scan `IMPLEMENTATION.md` checkboxes — first unchecked task is current state
4. Check open GitHub issues for failures and decisions
5. Search memory for relevant prior knowledge

## Conventions

- **Legal-first.** All actions must comply with Wyoming DAO LLC law, SEC Reg D, and securities regulations. When in doubt, escalate to securities counsel (issue #48).
- **Frozen entity state.** Entity ID, EIN, registered agent, and operating agreement are immutable once filed. Changes require amendment filings.
- **Smart contract integrity.** All contracts on Base mainnet. Deployer keys are cold storage. Never deploy without audit.
- **Governance discipline.** All treasury actions go through Governor contract. Safe multisig is the executor. Cold wallet votes.
- **Operator.** Seva Lapsha (@swearlock). Terse, will probe for fabrication, expects numbered findings with citations.

## Open Issues

| # | Priority | Title | Status |
|---|----------|-------|--------|
| #17 | P0 | Mercury Bank Account | blocked:human |
| #48 | P1 | Reg D Token Sale via Republic | blocked:human |
| #91 | P1 | Launch Reg D Offering via Republic | blocked:human |
| #171 | P0 | Execute Governance Proposal #2 | blocked:human |
| #173 | P2 | WY Annual Report (Feb 1, 2027) | open |

## Key Documents

- `Documents/HEARTH_ENTITY.md` — entity info, EIN, registered agent
- `Documents/HEARTH_ROADMAP.md` — execution plan
- `Documents/legal/` — operating agreement, securities docs
- `protocol/contracts/` — smart contracts (Governor, Timelock, HRTH, Crowdsale)
