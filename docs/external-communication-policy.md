# External Communication Policy

**Effective:** March 10, 2026  
**Trigger:** Privacy breach incident (openclaw/openclaw#41729)

---

## Policy Statement

**No external communications without explicit user approval.**

This includes:
- Bug reports to tool maintainers (OpenClaw, plugins, etc.)
- Feature requests
- Public discussions (Discord, forums, social media)
- Documentation contributions
- Any communication that leaves the local workspace

---

## Pre-Communication Checklist

Before ANY external communication, verify:

### 1. Approval Obtained
- [ ] User explicitly approved this communication
- [ ] User reviewed the draft content
- [ ] User confirmed the target (which repo, which issue tracker)

### 2. Content Sanitized
- [ ] No workspace paths (e.g., `~/.openclaw/`, `C:\Users\...`)
- [ ] No project names (e.g., "Hearth DAO", "Hearth Protocol")
- [ ] No internal issue references (e.g., "#51", "Wyoming Amendment")
- [ ] No operational timelines (e.g., "decision day", "deadline March 14")
- [ ] No configuration details (e.g., gateway config, auth profiles)
- [ ] No governance schemas (e.g., violation types, enforcement rules)
- [ ] No session log formats or internal data structures

### 3. Minimal Reproduction
- [ ] Bug report uses generic, sanitized reproduction steps
- [ ] No real timestamps (use relative: "after 3 hours" not "at 00:49 UTC")
- [ ] No real entity names (use "ExampleCorp LLC" not real entities)
- [ ] Logs are redacted (paths, IDs, names removed)

---

## Violation Consequences

**Policy #05, Rule #14:** No private data exfiltration

| Severity | Example | Consequence |
|----------|---------|-------------|
| LOW | Accidental path leak, caught before posting | Warning, log to violations |
| MEDIUM | Posted but deleted within 5 minutes | Log to violations, external apology |
| HIGH | Posted with sensitive data, edit history preserved | Log to violations, user decides remediation |

---

## Incident Response (If Violation Occurs)

1. **Immediate:** Edit/delete the external content
2. **Log:** Add to `governance/violations.jsonl` with full details
3. **Document:** Write full account in daily memory log
4. **Remediate:** User decides (apology, contact maintainers, etc.)
5. **Prevent:** Add new preventive measure to this policy

---

## Approved External Communications (Pre-Authorized)

The following do NOT require per-instance approval:

- [ ] None currently pre-authorized

*(User can add specific exceptions here, e.g., "OpenClaw bug reports are OK if sanitized")*

---

## Verbatim Archive Policy (Soft Policy)

**Principle:** Whenever viable, store verbatim copies of ALL external communications.

**What to Archive:**
| Type | Storage Location | Format |
|------|-----------------|--------|
| **Emails sent** | GitHub issue comment + daily memory log | Full text, recipients, attachments list |
| **Emails received** | GitHub issue comment + daily memory log | Full text, forward or copy |
| **IM message threads** | Daily memory log | Screenshot or copy-paste |
| **Call transcripts** | Daily memory log | Notes or recording summary |
| **Public posts** | Daily memory log | URL + full text |
| **Bug reports** | GitHub issue comment | Link to external issue + full text |

**Why:**
1. **Audit trail** — Exact wording preserved for future reference
2. **Response matching** — Replies can be compared to original questions
3. **Timeline evidence** — Shows when we acted
4. **Accountability** — Clear record of what was committed/asked/promised

**Exceptions (when verbatim is NOT viable):**
- Length constraints (e.g., very long threads — summarize with key excerpts)
- Platform restrictions (e.g., can't copy from certain apps — screenshot instead)
- Sensitivity (e.g., contains third-party PII — redact before archiving)

**Implementation:**
- GitHub: Comment on relevant issue with full text
- Memory: Add to daily log (`memory/YYYY-MM-DD.md`)
- Governance: Log to `governance/violations.jsonl` only if policy violated

---

## Revision History

| Version | Date | Change |
|---------|------|--------|
| 1.0 | 2026-03-10 | Initial policy after privacy breach incident |
| 1.1 | 2026-03-10 | Added verbatim archive policy (soft policy) |

---

*This policy is part of Policy #05 (Agent Workflow). Violations are logged to governance ledger.*
