# Policy Enforcement Status

**Last updated:** 2026-03-11  
**Source:** `policies/*.policy.md`

---

## Enforcement Matrix

| # | Rule | Policy File | Tag | Status |
|---|------|------------|-----|--------|
| 1 | Message signature required | identity.policy.md | ENFORCED | ✅ Active |
| 2 | No servant-mode language | identity.policy.md | ENFORCED | ✅ Active |
| 3 | Memory retrieval before write | knowledge.policy.md | ENFORCED | ✅ Active |
| 4 | Boot sequence after reset | operations.policy.md | ENFORCED | ✅ Active |
| 5 | Idle watchdog when blocked | operations.policy.md | AUDITED | ✅ Active |
| 6 | Task dispatch tiers | operations.policy.md | AUDITED | ⚠️ Uncalibrated |
| 7-15 | (Various) | knowledge/safety/hearth.policy.md | CONSTITUTIONAL | 📝 Text-only |
| 16 | **Version agent outputs** | 05-agent-workflow.policy.md | **ENFORCED** | ✅ Active |
| 17 | **Reference issues in commits** | 05-agent-workflow.policy.md | **ENFORCED** | ✅ Active |
| 18 | **Specify output location in spawn** | 05-agent-workflow.policy.md | **ENFORCED** | ✅ Active |
| 19 | **Mirror critical infrastructure** | 05-agent-workflow.policy.md | **AUDITED** | ✅ Active |
| 20 | **Close loop on spawned tasks** | 05-agent-workflow.policy.md | **AUDITED** | ✅ Active |
| 21 | **"Complete" = success criteria met** | 05-agent-workflow.policy.md | **ENFORCED** | ✅ Active |
| 22 | **Obtain approval before external communication** | 07-external-communication.policy.md | **ENFORCED** | 🆕 **New** |
| 23 | **Sanitize content before external posting** | 07-external-communication.policy.md | **ENFORCED** | 🆕 **New** |
| 24 | **Archive verbatim copies of external communications** | 07-external-communication.policy.md | **ENFORCED** | 🆕 **New** |
| 25 | **Use minimal reproduction for bug reports** | 07-external-communication.policy.md | **AUDITED** | 🆕 **New** |
| 26 | **Don't file external issues without approval** | 07-external-communication.policy.md | **ENFORCED** | 🆕 **New** |
| 27 | **Don't include sensitive data in external communications** | 07-external-communication.policy.md | **ENFORCED** | 🆕 **New** |
| 28 | **Incident response procedure** | 07-external-communication.policy.md | **AUDITED** | 🆕 **New** |
| 29 | **Verify command syntax before execution** | 05-agent-workflow.policy.md | **ENFORCED** | 🆕 **New** |
| 30 | **Don't present unverified knowledge as authoritative** | 05-agent-workflow.policy.md | **ENFORCED** | 🆕 **New** |
| 31 | **Frame exception proposals as criterion amendments** | 05-agent-workflow.policy.md | **AUDITED** | 🆕 **New** |

---

## Tag Legend

| Tag | Meaning |
|-----|---------|
| **[ENFORCED]** | Protocol Enforcer blocks violations — Hard gate |
| **[AUDITED]** | Protocol Enforcer logs/warns — Soft gate, weekly audit |
| **[CONSTITUTIONAL]** | In boot context only — Model self-enforces |

---

## Policy Files

| File | Purpose |
|------|---------|
| `01-identity.policy.md` | WHO: persona, tone, boundaries, signature |
| `02-operations.policy.md` | HOW: heartbeat, dispatch, cost, sessions |
| `03-knowledge.policy.md` | WHAT: memory arch, retrieval, dedup, routing |
| `04-safety.policy.md` | DONT: security, keys, external actions, data |
| `05-agent-workflow.policy.md` | WORKFLOW: versioning, commits, spawn discipline |
| `06-hearth.policy.md` | PROJECT: legal gates, deploy checklist |
| `07-external-communication.policy.md` | EXTERNAL: approval, sanitization, verbatim archive |

---

*This file is the single source of truth for policy enforcement.*
