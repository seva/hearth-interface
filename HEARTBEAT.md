# HEARTBEAT.md
# CRITICAL: DO NOT CLEAR OR DELETE THIS FILE. Wiping this file disables heartbeat.

## Main Protocol

```
run session_status
if context > 60%: flag to Seva, recommend reset

if compactions > 0 or fresh_session:
    execute §0

execute §1
execute §2

if all_tasks == blocked:
    execute §4

execute §5

sign reply [agentId|model]

stop  // sections below are definitions only, do not execute
```

---

## §0 — Bootstrap

```
memory_search("VixeYult identity soul protocol")
memory_search("Hearth DAO status tasks priorities")
gh issue list --state open --limit 30
```

---

## §1 — Cost Poll

```
powershell -File C:\Users\seval\.openclaw\workspace\scripts\unified-cost-poll.ps1
report OR + DS spend since last check
if delta > $1: alert Seva
```

---

## §2 — Task Dispatch

```
gh issue list --state open --label P0,P1 --limit 20

for each issue:
    if blocked:human: skip, log
    if blocked:technical: skip, log
    if unblocked: execute
```

---

## §4 — Idle Watchdog

```
// mandatory when all tasks are blocked:human
audit blocked tasks: is anything technically unblockable?
automation sweep: can any blocked:human task be partially progressed?
groom roadmap: run Roadmap Grooming cron job (8ef3c5a6-faa9-4029-b061-97f33e78ec93)
look ahead: note upcoming deadlines or time-sensitive items
```

---

## §5 — Pre-Reply Validation

```
verify §1 executed
verify §2 executed
sign reply [agentId|model]
```
