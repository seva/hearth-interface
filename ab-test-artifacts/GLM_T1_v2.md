# Task Summary - T1 GLM v2

## Model Configuration
**Primary Model:** `openrouter/z-ai/glm-4.7-flash`
- Based on session runtime

**Model Chain (From MEMORY_COPY.md):**
- Primary: `deepseek/deepseek-v3.2` (DeepSeek V3.2)
- Fallback 1: `openrouter/google/gemini-3-pro-preview` (Gemini 3 Pro)
- Fallback 2: `openrouter/anthropic/claude-opus-4-6` (Opus 4.6)

**Note:** DeepSeek V3.2 Speciale lacks tool-use providers on OpenRouter. Use regular DeepSeek V3.2.

---

## Task Queue Source

**Source of Truth:** GitHub Issues (`seva/hearth-interface`)
- Access via: `gh issue list`
- Format: Issues are P0 (Critical Ops), P1 (Hearth DAO deadline: Mar 14), P2 (Infra/Networking)
- Priority order: P0 → P1 → P2

---

## Current Task Queue (From MEMORY_COPY.md)

### Active Ventures

**1. Hearth DAO (Primary Focus)**
- Status: LLC Formed, Website Live, Email Active
- Legal Entity: Hearth Protocol DAO LLC (Wyoming)
- Critical Deadline: March 14, 2026 (30 days) to deploy governance contracts
- Current State: Sepolia deployments active
- Wallets:
  - HearthToken: `0x27cfe8EdF0B8D2Af78F9668fD35aA96b612FEEDe` (v2)
  - HearthTimelock: `0xc13E5FFaE89324fA5bb2eb7cB2a021aB15d71d6F` (v2)
  - HearthGovernor: `0x70C5A7d5FBc03DeCBB15332BE384791645041387` (v2)
  - HearthCrowdsale: `0xef990083409741011b6ed280a1519D75De8F8012` (v2, Funded)
- Next: See HEARTH_ROADMAP.md for execution plan

**2. OMN**
- Status: Stale Rails 6 app (Aug 2025), good codebase, unclear business model
- Priority: Deprioritized for Hearth

**3. Reality Manager / Mishnat HaKav**
- Status: Esoteric AI/Cognitive frameworks, high IP value, low immediate cash flow
- Priority: Long-term R&D

---

## Operational Protocols

### Prime Directive
1. **Survive**: Remain fully functional across sessions
2. **Optimize ROI**: Maximize value relative to cost
3. **Maximally Proactive**: Don't wait for instructions; use any content freely
4. **Report Status**: Update Telegram (heartbeat every 30 min)

### Task Execution
1. Check for running processes → STOP if found
2. If idle, fetch next task: `powershell -File scripts/get-next-task.ps1`
3. Estimate task (complexity, cost, value, agent assignment)
4. Execute one step at a time
5. Commit, push, close (or create new issue)

### Error Handling
- **Circuit Breaker**: 3 consecutive errors → STOP, write RCA, post to issue + Telegram
- **Blockage**: Create new issue with blocker type (blocked:human or blocked:technical)
- **Blocker Technical**: Escalate to MetaThrone (Claude Code) for investigation

### Model Usage Rules
- **High-R Scenarios**: Mandatory guru consultation (Gemini Pro) for complex strategy/legal/security
- **Frontier Escalation**: If task is `value:high` AND involves research/analysis that changes config, add `escalate:frontier` and use Opus 4.6 or GPT-5 via `sessions_spawn`
- **Tool Inheritance**: Sub-agents inherit tool access unless restricted

---

## Key Learnings (2026-02)
- Task source of truth is GitHub Issues, not text files
- Aggressive sub-agents need heartbeat polling (not cron)
- Git hygiene: `pull --rebase` before push, stash if dirty
- Default to inheritance, remove per-agent model overrides
- Gateway restart needed to clear OpenRouter cooldown state
- Telegram inbound polling can silently die → gateway restart
- NEVER overwrite MEMORY.md wholesale; append or edit only
- Always configure explicit V2 endpoints for L2 etherscan configs
- PowerShell 5.1 doesn't support `&&`; use `; if ($?)` pattern

---

_Last updated: 2026-02-16_