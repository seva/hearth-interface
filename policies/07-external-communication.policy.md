# External Communication Policy

**Purpose:** Govern all external communications to prevent privacy breaches and ensure audit trails.

**Related:** Policy #05 (Agent Workflow), Adaptive Immunity Phase 5 (#127)

---

## DO: Obtain Approval Before External Communication [ENFORCED]

**Rule:** No external communications without explicit user approval.

**Applies to:**
- Bug reports to tool maintainers (OpenClaw, plugins, etc.)
- Feature requests
- Public discussions (Discord, forums, social media)
- Documentation contributions
- Any communication leaving the local workspace

**Enforcement:** Protocol Enforcer blocks `exec` tool calls for external commands without prior approval flag.

**Recovery:** Request user approval before proceeding.

---

## DO: Sanitize Content Before External Posting [ENFORCED]

**Rule:** Remove all sensitive information before any external communication.

**Checklist:**
- [ ] No workspace paths (e.g., `~/.openclaw/`, `C:\Users\...`)
- [ ] No project names (e.g., "Hearth DAO", "Hearth Protocol")
- [ ] No internal issue references (e.g., "#51", "Wyoming Amendment")
- [ ] No operational timelines (e.g., "decision day", "deadline March 14")
- [ ] No configuration details (e.g., gateway config, auth profiles)
- [ ] No governance schemas (e.g., violation types, enforcement rules)
- [ ] No session log formats or internal data structures

**Enforcement:** Protocol Enforcer scans outbound content for sensitive patterns.

**Recovery:** Redact sensitive content before posting.

---

## DO: Archive Verbatim Copies of External Communications [ENFORCED]

**Rule:** Store verbatim copies of ALL external communications.

**Storage Hierarchy:**
| Priority | Location | When |
|----------|----------|------|
| **PRIMARY** | GitHub issue comment | ALWAYS — all external communications |
| **SECONDARY** | Public URL | When communication is publicly accessible |
| **TERTIARY** | Memory log | Backup copy for local reference |

**Applies to:**
| Type | GitHub | Public Link | Memory Log |
|------|--------|-------------|------------|
| Emails sent/received | ✅ Required | N/A (private) | ✅ Copy |
| IM message threads | ✅ Required | N/A (private) | ✅ Copy |
| Call transcripts | ✅ Required | N/A (private) | ✅ Summary |
| Public posts | ✅ Required | ✅ URL | ✅ Copy |
| External bug reports | ✅ Required | ✅ URL | ✅ Copy |

**Enforcement:** Protocol Enforcer checks for GitHub comment after external communication detected.

**Recovery:** Create GitHub comment with verbatim copy.

---

## DO: Use Minimal Reproduction for Bug Reports [AUDITED]

**Rule:** Bug reports use generic, sanitized reproduction steps.

**Requirements:**
- No real timestamps (use relative: "after 3 hours" not "at 00:49 UTC")
- No real entity names (use "ExampleCorp LLC" not real entities)
- Logs redacted (paths, IDs, names removed)

**Enforcement:** Weekly audit checks external bug reports for sensitive data.

---

## DONT: File External Issues Without Approval [ENFORCED]

**Rule:** Never file external bug reports, feature requests, or public posts without explicit user approval.

**Enforcement:** Protocol Enforcer blocks `gh issue create` for external repos without approval flag.

**Recovery:** Request user approval before filing.

---

## DONT: Include Sensitive Data in External Communications [ENFORCED]

**Rule:** Never include internal paths, governance schemas, project names, or operational details in external communications.

**Enforcement:** Protocol Enforcer scans for sensitive patterns in outbound content.

**Recovery:** Edit/delete external content, log violation, remediate per incident response.

---

## Incident Response (If Violation Occurs) [AUDITED]

**Steps:**
1. **Immediate:** Edit/delete the external content
2. **Log:** Add to `governance/violations.jsonl` with full details
3. **Document:** Write full account in daily memory log
4. **Remediate:** User decides (apology, contact maintainers, etc.)
5. **Prevent:** Add new preventive measure to this policy

**Enforcement:** Weekly audit checks for unlogged violations.

---

## Enforcement Matrix

| Rule # | Rule | Tag | Plugin Hook |
|--------|------|-----|-------------|
| 1 | Obtain approval before external communication | ENFORCED | `before_tool_call` (exec) |
| 2 | Sanitize content before external posting | ENFORCED | `message_sending` |
| 3 | Archive verbatim copies | ENFORCED | `after_tool_call` (external) |
| 4 | Use minimal reproduction for bug reports | AUDITED | Weekly audit |
| 5 | Don't file external issues without approval | ENFORCED | `before_tool_call` (gh issue create) |
| 6 | Don't include sensitive data | ENFORCED | `message_sending` |
| 7 | Incident response procedure | AUDITED | Weekly audit |

---

## Revision History

| Version | Date | Change | Related Issue |
|---------|------|--------|---------------|
| 1.0 | 2026-03-10 | Initial policy (privacy breach incident) | N/A |
| 1.1 | 2026-03-10 | Added verbatim archive policy | N/A |
| 1.2 | 2026-03-10 | Clarified GitHub ALWAYS primary | N/A |
| 2.0 | 2026-03-10 | Refactored to DO/DONT format with enforcement tags | #119 |

---

*This policy is part of Policy #05 (Agent Workflow). Violations logged to `governance/violations.jsonl`.*
