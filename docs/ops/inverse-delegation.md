# Inverse Delegation Research (Worker‑First Architecture)

**Issue:** [#54](https://github.com/seva/hearth-interface/issues/54)  
**Date:** 2026-02-15  
**Researcher:** VixeYult (agent:main)

## Objective
Design a cost‑optimized agent orchestration where the cheap model (DeepSeek V3) acts as the default router, escalating only complex/high‑risk tasks to the expensive model (Gemini 3 Pro). This flips the current Coherence Engine v1 (Gemini as router) to v2 (DeepSeek as router).

## Current Architecture (Coherence Engine v1)

- **Strategic Agent:** Gemini 3 Pro (`agent:main`) – always on, routes every heartbeat.
- **Execution Agent:** DeepSeek V3 (`agent:coder`) – spawned for coding/research tasks.
- **Cost Profile:** Gemini token burn on every heartbeat, even for trivial decisions.

## Proposed Architecture (Coherence Engine v2)

- **Default Router:** DeepSeek V3 (`agent:fast` or `agent:coder`) – handles routine tasks (code, config, status, research) without escalation.
- **Escalation Target:** Gemini 3 Pro (`agent:main`) – invoked only when DeepSeek detects:
  1. **Legal/Regulatory complexity** (securities law, compliance, contract review)
  2. **Architectural decisions** that change system config, model selection, security posture
  3. **High‑value strategic planning** (SWOT, roadmap, venture‑level choices)
  4. **Ambiguous context** where DeepSeek’s confidence is low (meta‑cognition threshold)
  5. **Frontier‑escalation triggers** (as defined in HEARTBEAT.md)

## Meta‑Cognition Prompt (Draft)

```markdown
## Inverse Delegation Decision Logic

You are the primary router (DeepSeek V3). Before acting on a task, assess:

### **Escalate to Gemini (`agent:main`) if ANY of the following apply:**

1. **Legal/Regulatory:** Task involves securities law, tax, compliance, contract drafting, or regulatory filings.
2. **Architectural:** Task will change system configuration, model selection, security posture, or infrastructure architecture.
3. **Strategic:** Task is `value:high` and involves venture‑level planning, SWOT analysis, or multi‑dimensional risk assessment.
4. **Frontier Trigger:** Task is `value:high` AND involves research/analysis whose conclusion will change config, architecture, model selection, or security posture (per HEARTBEAT.md frontier escalation).
5. **Ambiguity:** You lack sufficient context or confidence to proceed safely (e.g., unclear requirements, conflicting information).
6. **Human‑Blocked:** Task is labeled `blocked:human` (requires manual action by Seva). Do NOT retry; escalate for human coordination.

### **Handle locally (DeepSeek) if ALL of the following apply:**

- Task is `complexity:trivial` or `complexity:moderate`
- Task is `value:low` or `value:medium`
- No legal/regulatory/architectural/strategic impact
- No frontier‑escalation trigger
- Not blocked:human

### **Default Action:** If uncertain, escalate.

## Implementation Steps

### Phase 1: Prompt Engineering
1. Integrate the meta‑cognition prompt into DeepSeek’s system instructions (SOUL.md or HEARTBEAT.md).
2. Test with a sample of recent tasks to verify escalation accuracy.

### Phase 2: Heartbeat Modification
1. Update `HEARTBEAT.md` to use DeepSeek as the default heartbeat agent.
2. Modify the task‑estimation step to include the escalation check.
3. Adjust `get-next-task.ps1` to run under DeepSeek (agent:fast) instead of Gemini.

### Phase 3: Tooling Adjustments
1. Ensure DeepSeek has access to `sessions_spawn` to call Gemini when needed.
2. Configure session labels for tracking (`agent:main` for Gemini, `agent:coder` for DeepSeek).
3. Update cost‑tracking to attribute expenses to the correct agent.

### Phase 4: Validation & Rollout
1. Run a side‑by‑side comparison (v1 vs v2) for one week, measuring:
   - Token burn per task
   - Task completion rate
   - Escalation frequency
2. Adjust thresholds based on results.
3. Full rollout to production heartbeat.

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Over‑escalation (cost increase) | Set clear thresholds; refine prompt with historical task analysis. |
| Under‑escalation (missed complex tasks) | Include a safety‑net: “If uncertain, escalate.” |
| Tool access parity | Ensure DeepSeek inherits same tool permissions as Gemini. |
| Session‑state fragmentation | Use shared memory (MEMORY.md) for context passing. |

## Next Actions

1. **Review prompt** with Seva/MetaThrone for completeness.
2. **Implement Phase 1** as a prototype in a isolated session.
3. **Measure cost savings** before committing to full architecture change.

## References
- HEARTBEAT.md (current Coherence Engine)
- OpenClaw sessions_spawn documentation
- Token cost data from `poll-cost.ps1`