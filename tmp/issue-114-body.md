# Phase 2: Pattern-Specific Auto-Fixes

**Parent:** #113 (Adaptive Immunity — Full Roadmap)  
**Priority:** P1 (blocked by Phase 1: #108/#110/#111)

---

## Goal

Implement automated corrections for common violation patterns. System detects recurring violations and auto-applies fixes without human intervention (for low-risk patterns).

---

## Scope

### Auto-Fix Implementations

| # | Pattern | Auto-Fix | Risk Tier |
|---|---------|----------|-----------|
| #115 | New servant-mode phrase detected 3+ times | Auto-add to `servantModePatterns` config | Low |
| #116 | Memory write without retrieval for specific domain | Auto-infer search query from file path | Low |
| #117 | Threshold violations (e.g., idle watchdog staleness) | Auto-adjust threshold within safe bounds | Low |
| #118 | Compliance rate drops below threshold | Send Telegram alert | Low |

### Out of Scope

- Medium/high-risk auto-fixes (Phase 3)
- Structural policy changes (Phase 5)
- Predictive analytics (Phase 4)

---

## Success Criteria (Policy #05 Rule #21)

- [ ] At least 2 pattern-specific auto-fixes implemented
- [ ] Auto-fixes respect 3/week cap (configurable)
- [ ] All auto-fixes logged to `governance/auto-apply.log` with rollback instructions
- [ ] False positive rate <10% (measured over 14 days)
- [ ] Scripts in tracked location (`workspace/protocol/scripts/`)
- [ ] Test evidence logged to issue comment
- [ ] SHA in completion comment

---

## Implementation Notes

### Auto-Fix Template

```powershell
# Example: Servant-mode pattern auto-expand
$violations = Get-Content ~/.openclaw/governance/violations.jsonl | ConvertFrom-Json
$recent = $violations | Where-Object { $_.type -eq "SERVANT_MODE" -and [datetime]$_.timestamp -gt (Get-Date).AddDays(-7) }

# Group by detected phrase
$phrases = $recent | Group-Object { $_.details -replace ".*detected: ""([^""]+)"".*/", '$1' }
$recurring = $phrases | Where-Object { $_.Count -ge 3 }

foreach ($phrase in $recurring) {
    $phraseText = $phrase.Name
    
    # Check if already in config
    $config = Get-Content ~/.openclaw/openclaw.json | ConvertFrom-Json
    if ($config.plugins.entries."protocol-enforcer".config.servantModePatterns -notcontains $phraseText) {
        # Auto-add (low-risk, additive)
        $config.plugins.entries."protocol-enforcer".config.servantModePatterns += $phraseText
        $config | ConvertTo-Json -Depth 10 | Set-Content ~/.openclaw/openclaw.json
        
        # Log to auto-apply.log
        $logEntry = @{
            timestamp = Get-Date -Format "o"
            action = "AUTO_EXPAND_SERVANT_PATTERNS"
            pattern = $phraseText
            occurrences = $phrase.Count
            rollback = "Remove '$phraseText' from servantModePatterns in openclaw.json"
        } | ConvertTo-Json
        Add-Content ~/.openclaw/governance/auto-apply.log $logEntry
    }
}
```

### Safety Constraints

- Auto-apply ONLY additive changes (never remove rules or relax enforcement)
- Respect 3/week cap (configurable in `governance/config.json`)
- Log every auto-apply with rollback instructions
- False positive tracking — if pattern triggers incorrectly 2+ times, disable auto-fix

---

## Files to Create/Modify

| File | Action | Tracked Location |
|------|--------|------------------|
| `protocol/scripts/auto-fix-servant-mode.ps1` | Create | `workspace/protocol/scripts/` |
| `protocol/scripts/auto-fix-memory-domain.ps1` | Create | `workspace/protocol/scripts/` |
| `protocol/scripts/auto-fix-threshold-tuning.ps1` | Create | `workspace/protocol/scripts/` |
| `governance/config.json` | Modify (add auto-fix config) | Mirror to `workspace/docs/governance-config-schema.json` |
| `~/.openclaw/openclaw.json` | Modify (add patterns) | N/A (runtime config) |

---

## Testing Plan

1. **Unit test:** Run auto-fix script with sample violations.jsonl
2. **Integration test:** Trigger servant-mode violation 3+ times, verify auto-add
3. **Cap test:** Trigger 4+ auto-fixes in one week, verify 4th is blocked
4. **Rollback test:** Manually rollback auto-fix, verify system state restored

---

## Acceptance Criteria

- [ ] All auto-fix scripts committed to `workspace/protocol/scripts/`
- [ ] Test evidence logged (unit + integration test output)
- [ ] 3/week cap verified in test
- [ ] Rollback instructions logged for each auto-fix
- [ ] SHA in completion comment on this issue
- [ ] Parent #113 updated with Phase 2 status

---

*Created per Policy #05 Rule #21. Output: `workspace/protocol/scripts/` (tracked). Tests required before close.*

---

## Progress Log

### 2026-03-10 21:30 — Subagent Started (Phase 2 Implementation)

**Subagent:** agent:coder:subagent:2d3f254e-4cdc-4998-884c-7bca68486675  
**Task:** Read epic, create sub-tasks if needed, implement first auto-fix pattern

**Completed:**
- ? Read epic #114 (Phase 2: Pattern-Specific Auto-Fixes)
- ? Implemented first auto-fix: Servant-mode pattern auto-expand (#115)
- ? Created `protocol/scripts/auto-fix-servant-mode.ps1`
- ? Tested with sample violations (dry-run: detected 2 recurring phrases)
- ? Tested with production violations (0 servant-mode violations found)
- ? Verified auto-apply cap logic (3/week limit)
- ? Verified rollback instruction logging
- ? Committed: 896b57b (script), 8424b89 (test evidence)
- ? Test evidence logged: `tmp/issue-114-test-evidence.md`

**Status:** First auto-fix pattern (#115) COMPLETE. Remaining patterns (#116-118) ready for implementation.

**Next:** Continue with #116 (Memory domain inference) or await human direction.

