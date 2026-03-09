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

## Enforcement Matrix

| Rule | Enforcement Level | Plugin Hook | Recovery |
|------|------------------|-------------|----------|
| Version agent outputs | ENFORCED | `after_tool_call` (sessions_spawn) | Block session close, require commit |
| Reference issues in commits | ENFORCED | `before_tool_call` (exec: git commit) | Block commit, require issue ref |
| Specify output location | ENFORCED | `before_tool_call` (sessions_spawn) | Block spawn, require output dir |
| Mirror critical infra | AUDITED | Weekly cron | Create issue, list unmirrored files |
| Close loop on spawns | AUDITED | Weekly cron | Create issue, list orphaned spawns |

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
| 1.0 | 2026-03-08 | Initial policy created after #108 work was orphaned in gitignored directories |

---

*This policy is auto-generated from incident #108. See memory/topics/openclaw-protocols.md §12 for root cause analysis.*
