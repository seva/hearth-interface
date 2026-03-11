# Agent Workflow Policy

## Purpose

Prevent orphaned work and ensure all agent outputs are versioned, traceable, and recoverable.

---

## Policy Rules

### DO: Version Agent Outputs [ENFORCED]

All agent-generated code, scripts, and configurations MUST be committed to git before the session ends.

**Enforcement:** Protocol Enforcer detects `sessions_spawn` completion → checks for uncommitted changes in tracked directories → blocks session close if changes exist without commit.

**Exception:** Files in explicitly gitignored locations (e.g., `~/.openclaw/governance/`, `~/.openclaw/extensions/`) are exempt but should be mirrored to tracked locations for critical infrastructure.

---

### DO: Reference Issues in Commits [ENFORCED]

All commits from agent work MUST reference the parent issue using `(Fixes #N)` or `(Related to #N)` format.

**Enforcement:** Protocol Enforcer scans commit messages during `git commit` → blocks if no issue reference found for agent-spawned work.

---

### DO: Specify Output Location in Spawn Tasks [ENFORCED]

When spawning an agent, the task MUST specify:
1. **Output directory** — Where files should be written (must be git-tracked)
2. **Issue to update** — Which GitHub issue to post progress comments to
3. **Completion signal** — How the agent reports done (issue comment, commit, Telegram)

**Example:**
```
Spawn coder with:
- Output: workspace/protocol/scripts/ (git-tracked)
- Update: #108 (post progress comments)
- Complete: Comment on #108 with summary + commit SHA
```

**Enforcement:** Protocol Enforcer intercepts `sessions_spawn` tool call → validates task includes output directory → blocks if missing.

---

### DO: Mirror Critical Infrastructure to Tracked Locations [AUDITED]

Infrastructure that lives in `~/.openclaw/` (extensions, governance, configs) MUST have a mirrored copy in the workspace for version control.

**Example:**
```
~/.openclaw/extensions/protocol-enforcer.ts
  → mirror to: workspace/protocol/extensions/protocol-enforcer.ts

~/.openclaw/scripts/governance-analyzer.ps1
  → mirror to: workspace/scripts/governance-analyzer.ps1
```

**Enforcement:** Weekly audit (governance-analyzer.ps1) checks for unmirrored critical files → creates issue if drift detected.

---

### DONT: Write Agent Work to Gitignored Directories [CONSTITUTIONAL]

Unless explicitly intended as temporary/cache, agent work should NOT be written to:
- `/scripts/` (gitignored)
- `/tmp/` (gitignored)
- `~/.openclaw/` (external to repo)

**Rationale:** Gitignored work is lost on reset, unreviewable, untraceable.

**Alternative:** Write to tracked location first, then copy to runtime location if needed.

---

### DO: Close the Loop on Spawned Tasks [AUDITED]

When a spawned agent completes:
1. **Verify output exists** — Check files were created
2. **Verify output is committed** — Check git history
3. **Update parent issue** — Post completion comment with:
   - What was done
   - Files created/modified
   - Commit SHA(s)
   - Next steps (if any)
4. **Close issue if complete** — Or leave open with clear remaining work

**Enforcement:** Weekly audit checks for spawned sessions without completion comments → alerts if >7 days old with no update.

---

### DO: Define "Complete" as Success Criteria Met [ENFORCED]

**"Complete" means ALL definition of done (success criteria) are met. By default:**

1. ✅ **GitHub committed** — Code is in the repo, not just local
2. ✅ **Tests passing** — Relevant tests executed and green
3. ✅ **Issue updated** — Parent issue has completion comment with SHA
4. ✅ **Mirrored if external** — Runtime files in `~/.openclaw/` have tracked mirrors

**Task authors MAY extend this default:**
```
Success criteria for #108:
- [ ] Governance directory created (~/.openclaw/governance/)
- [ ] Analyzer script functional (tested with sample data)
- [ ] Proposal engine respects 3/week cap (verified)
- [ ] Policy committed to GitHub (SHA in issue comment)
```

**Enforcement:** Protocol Enforcer blocks `sessions_spawn` completion announcement until success criteria are verified. Issue cannot be closed without all checkboxes marked.

**Rationale:** "Complete" is not a feeling. It's a checklist. "Push pending" is an oxymoron — either it's pushed (done) or it's not (incomplete).

---

### DONT: Modify HEARTBEAT.md Without Approval [ENFORCED]

**NEVER modify, truncate, or delete `HEARTBEAT.md` without explicit user approval.**

**What HEARTBEAT.md is:**
- Persistent protocol definition (read-only by default)
- Survives session restarts
- Contains §0-§5 execution steps

**What HEARTBEAT.md is NOT:**
- Consumable instructions (not a message queue)
- One-time checklist (not "read and discard")
- Editable configuration (not a settings file)

**Standing Rule:**
- ✅ READ `HEARTBEAT.md` and execute §0-§5
- ✅ Leave file unchanged after execution
- ❌ NEVER modify, truncate, or delete **unless Seva explicitly approves**

**Enforcement:** Weekly audit checks `HEARTBEAT.md` for modifications. Any unapproved change triggers violation report.

**Rationale:** Wiping `HEARTBEAT.md` silently disables heartbeat for all future sessions. This is infrastructure, not scratch paper. Legitimate updates require human oversight.

---

### DO: Verify Command Syntax Before Execution [ENFORCED]

**Before running any unfamiliar CLI command:**
1. Run `--help` or consult documentation
2. Verify syntax, flags, and side effects
3. Confirm scope (what will be affected)

**Enforcement:** Protocol Enforcer intercepts `exec` tool calls → checks if `--help` was run first for unfamiliar commands → blocks if not.

**Recovery:** Run `--help` before retrying the command.

**Rationale:** Guessing command syntax is dangerous. Could delete production configs, wipe databases, or cause irreversible damage. Tool discovery (`--help`, `which`, docs) is mandatory before execution.

---

### DONT: Present Unverified Knowledge as Authoritative [ENFORCED]

**Never present information as fact without verification:**
1. If unsure, say "I don't know" or "I'm not certain"
2. If speculating, label it as speculation ("My guess is...", "This might be...")
3. If recalling from memory, verify against source documents first
4. Distinguish between: official docs, memory/file content, inference, speculation

**Enforcement:** Protocol Enforcer flags confident assertions that contradict verified sources.

**Recovery:** Acknowledge fabrication, verify against authoritative source, correct the record.

**Rationale:** Confident hallucination is more dangerous than admitted ignorance. Fabricated "knowledge" leads to bad decisions, wasted time, and broken trust. "I don't know" is safer than "I'm sure" when wrong.

---

### DO: Frame Exception Proposals as Criterion Amendments [AUDITED]

**When a success criterion seems wrong, impractical, or outdated:**

1. **Scrutinize the criterion, not the closure**
   - Wrong: "Close #114 at 92% with follow-up issue"
   - Right: "Revisit whether S4 (14-day measurement) is the right criterion"

2. **Present arguments for/against the criterion itself**
   - Why it may be wrong (cost, value, risk tradeoffs)
   - Why it may be right (safety, accountability, learning)
   - Alternative criterion proposal (if applicable)

3. **Require explicit approval**
   - If amendment approved → update criterion, then close when new criterion met
   - If amendment rejected → criterion stands, no exceptions

**Enforcement:** Weekly audit checks for issues closed with unmet criteria → flags if no criterion amendment discussion occurred.

**Recovery:** Reopen issue, amend criterion through proper channel, re-close when met.

**Rationale:** Success criteria are living agreements, not obstacles. Working around them perpetuates gaps. Scrutinizing them improves the system. "Let's close despite failure" undermines policy integrity. "Let's revisit this criterion" evolves it through peer review.

**Example (from #114):**
> "S4 requires 14-day false positive measurement. Before committing:
>
> **Arguments to amend S4:**
> - Auto-fixes are additive-only, reversible, low-risk
> - 14-day gate blocks closure but doesn't improve safety
> - Could measure per 20 auto-fixes instead (faster feedback)
>
> **Arguments to keep S4:**
> - Establishes baseline for auto-fix reliability
> - Forces accountability (can't ship untested automation)
> - Catches systemic issues early
>
> **Proposal:** Change S4 from '14-day measurement' to '20 auto-fixes with 0 false positives'
>
> **If approved:** Update S4, close #114 when new criterion met.
> **If rejected:** S4 stands, #114 stays open until Mar 25."

---

## Enforcement Matrix

| Rule | Enforcement Level | Plugin Hook | Recovery |
|------|------------------|-------------|----------|
| Version agent outputs | ENFORCED | `after_tool_call` (sessions_spawn) | Block session close, require commit |
| Reference issues in commits | ENFORCED | `before_tool_call` (exec: git commit) | Block commit, require issue ref |
| Specify output location | ENFORCED | `before_tool_call` (sessions_spawn) | Block spawn, require output dir |
| Mirror critical infra | AUDITED | Weekly cron | Create issue, list unmirrored files |
| Close loop on spawns | AUDITED | Weekly cron | Create issue, list orphaned spawns |
| Don't modify HEARTBEAT.md without approval | ENFORCED | Weekly audit | Create issue, restore from backup |
| Verify command syntax before execution | ENFORCED | `before_tool_call` (exec) | Block, require --help first |
| **Frame exceptions as criterion amendments** | **AUDITED** | **Weekly audit** | **Reopen issue, amend criterion properly** |

---

## Implementation Notes

### Protocol Enforcer v3.0 Additions

```typescript
// Hook: Validate sessions_spawn has output directory
api.on("before_tool_call", (event, ctx) => {
  if (event.tool === "sessions_spawn") {
    const task = event.params?.task as string;
    if (!task.includes("Output:") && !task.includes("output:")) {
      return {
        reject: true,
        reason: "Spawn task must specify output directory. Add 'Output: workspace/path/' to task."
      };
    }
  }
});

// Hook: Validate git commit has issue reference
api.on("before_tool_call", (event, ctx) => {
  if (event.tool === "exec" && event.params?.command?.includes("git commit")) {
    const cmd = event.params.command as string;
    if (!cmd.match(/(Fixes|Related to|Closes|Resolves)\s*#?\d+/i)) {
      return {
        reject: true,
        reason: "Commit message must reference an issue."
      };
    }
  }
});
```

### Weekly Audit Script

```powershell
# scripts/audit-agent-workflow.ps1
# Run weekly, checks for:
# 1. Unmirrored critical files in ~/.openclaw/
# 2. Spawned sessions without completion comments
# 3. Uncommitted changes in tracked directories
```

---

## Revision History

| Version | Date | Change |
|---------|------|--------|
| 2.0 | 2026-03-11 | Added Rule #31: Frame exception proposals as criterion amendments (from #114 success criteria gap incident) |
| 1.0 | 2026-03-08 | Initial policy created after #108 work was orphaned in gitignored directories |

---

*This policy is auto-generated from incident #108. See memory/topics/openclaw-protocols.md §12 for root cause analysis.*
