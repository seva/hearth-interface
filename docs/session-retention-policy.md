# Session Retention Policy

**Effective:** March 9, 2026  
**Review:** Quarterly (or when storage exceeds 1 GB)

---

## Retention Schedule

| Data Type | Retention Period | Rationale | Storage Location |
|-----------|------------------|-----------|------------------|
| **Main session logs** (direct chat) | **Indefinite** | Training data for policy evolution, behavioral baselines, model comparison | `~/.openclaw/agents/main/sessions/` |
| **Subagent sessions** (coder/guru spawns) | **30 minutes** (current config) | Short-term debugging, auto-archive after completion | `~/.openclaw/agents/coder|guru/sessions/` |
| **Violation logs** (`violations.jsonl`) | **Indefinite** | Compliance audit, trend analysis, adaptive immunity training | `~/.openclaw/governance/violations.jsonl` |
| **Auto-apply logs** (`auto-apply.log`) | **Indefinite** | Rollback reference, accuracy tracking, false positive analysis | `~/.openclaw/governance/auto-apply.log` |
| **Approval logs** (`approvals.jsonl`) | **Indefinite** | Audit trail for medium/high-risk proposals | `~/.openclaw/governance/approvals.jsonl` |
| **Compliance reports** (`compliance.json`) | **90 days** (rolling) | Weekly snapshots, older data aggregated in reports | `~/.openclaw/governance/compliance.json` |
| **Daily memory logs** (`memory/YYYY-MM-DD.md`) | **Indefinite** | Operational history, lesson extraction | `workspace/memory/` |
| **Issue comments** (GitHub) | **Indefinite** | Public audit trail, linked to commits | `github.com/seva/hearth-interface/issues/` |

---

## Rationale for Indefinite Main Session Retention

**Cost:** ~10 MB/month (~120 MB/year) — negligible for modern storage.

**Value:**
1. **Policy training data** — Extract violation patterns, recovery successes, policy gaps
2. **Behavioral baselines** — Establish normal compliance rates, detect anomalies
3. **Model comparison** — Qwen vs. Claude vs. Gemini on enforcement tasks
4. **Spawn effectiveness** — Which task templates deliver vs. thrash
5. **Drift prediction** — Session length + context pressure → compliance degradation
6. **Forensic audit** — Reconstruct what happened if something goes wrong

**Risk:** Minimal (local storage, not cloud-synced, no sensitive data beyond what's already in GitHub issues)

---

## Proposed Changes (Phase 4.5 — #118)

| Change | Current | Proposed | Benefit |
|--------|---------|----------|---------|
| Subagent retention | 30 minutes | 7 days | More time for retrospective analysis |
| Compliance reports | Overwritten weekly | 90-day rolling | Trend analysis, quarter-over-quarter comparison |
| Session parser | Not implemented | Automated extraction | Behavioral baselines, model comparison |

---

## Cleanup Procedures

### Manual Cleanup (When Storage >1 GB)

```powershell
# Delete main sessions older than 1 year (dry run first)
Get-ChildItem ~/.openclaw/agents/main/sessions/*.jsonl |
  Where-Object { $_.LastWriteTime -lt (Get-Date).AddYears(-1) } |
  Remove-Item -WhatIf  # Remove -WhatIf to actually delete

# Delete compliance reports older than 90 days
Get-ChildItem ~/.openclaw/governance/compliance-*.json |
  Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-90) } |
  Remove-Item
```

### Automated Cleanup (Future Cron)

```powershell
# Weekly cleanup (to be implemented in Phase 4.5)
pwsh -File scripts/session-retention-cleanup.ps1
```

---

## Privacy & Security Notes

- **Local storage only** — Sessions not synced to cloud (unless user has OneDrive/Dropbox syncing `~/.openclaw/`)
- **No PII beyond GitHub** — Session logs contain same info as GitHub issue comments
- **Sensitive data** — Avoid logging passwords, API keys, private keys (Protocol Enforcer should block these)
- **Access control** — File permissions should restrict to current user only

---

## Revision History

| Version | Date | Change |
|---------|------|--------|
| 1.0 | 2026-03-09 | Initial policy documented (indefinite main session retention) |

---

*This policy is part of Adaptive Immunity Phase 4.5 (#118). Retention enables session log mining for policy evolution.*
