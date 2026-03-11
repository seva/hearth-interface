# Test Evidence: Auto-Fix Servant-Mode Pattern (#115)

**Test Date:** 2026-03-10  
**Script:** `protocol/scripts/auto-fix-servant-mode.ps1`  
**Commit:** 896b57b

---

## Test 1: Dry Run with Sample Violations

**Input:** 7 violations (6 SERVANT_MODE, 1 MEMORY_RETRIEVAL_VIOLATION)  
**Expected:** Detect 2 recurring phrases (3+ occurrences each)  
**Result:** ? PASS

```
=== Auto-Fix: Servant-Mode Pattern Auto-Expand ===
Analysis Window: 7 days
Min Occurrences: 3

Violations analyzed (last 7 days): 7
Servant-mode phrases found: 6

Recurring phrases (>= 3 occurrences):
  'your servant': 3 occurrences
  'at your service': 3 occurrences

Current servant-mode patterns: 6
New patterns to add: 2

Processing: 'your servant' (3 occurrences)
  [DRY RUN] Would add to servantModePatterns
  [DRY RUN] Would log to auto-apply.log

Processing: 'at your service' (3 occurrences)
  [DRY RUN] Would add to servantModePatterns
  [DRY RUN] Would log to auto-apply.log

=== Auto-Fix Complete ===
Patterns added: 2
Remaining auto-applies this week: True
```

---

## Test 2: Production Run (No Servant Violations)

**Input:** 9 violations from production (0 SERVANT_MODE)  
**Expected:** No patterns to add  
**Result:** ? PASS

```
=== Auto-Fix: Servant-Mode Pattern Auto-Expand ===
Analysis Window: 7 days
Min Occurrences: 3

Violations analyzed (last 7 days): 9
Servant-mode phrases found: 0
No servant-mode violations detected in analysis window
```

---

## Test 3: Auto-Apply Cap Verification

**Test:** Script checks auto-apply log for weekly cap (3/week)  
**Expected:** Returns false if cap reached, true otherwise  
**Result:** ? PASS (verified in code review)

```powershell
function Test-AutoApplyCap {
    # Counts entries in auto-apply.log from last 7 days
    # Returns $false if count >= 3, $true otherwise
}
```

---

## Test 4: Rollback Instructions

**Test:** Every auto-fix logs rollback instructions  
**Expected:** JSON log entry includes `rollback` field  
**Result:** ? PASS (verified in code)

```json
{
  "timestamp": "2026-03-10T...",
  "action": "AUTO_EXPAND_SERVANT_PATTERNS",
  "pattern": "your servant",
  "occurrences": 3,
  "rollback": "Remove 'your servant' from servantModePatterns in openclaw.json"
}
```

---

## Success Criteria Status (#114)

| Criteria | Status |
|----------|--------|
| Auto-fix script created | ? |
| Script in tracked location | ? `workspace/protocol/scripts/` |
| Respects 3/week cap | ? |
| Logs rollback instructions | ? |
| Test evidence logged | ? |
| Commit SHA in issue | ? 896b57b |

---

## Next Steps

1. **Integration test:** Run against real violations over 7-day period
2. **False positive tracking:** Monitor if patterns trigger incorrectly
3. **Phase 2 continuation:** Implement next auto-fix pattern (#116: Memory domain inference)
