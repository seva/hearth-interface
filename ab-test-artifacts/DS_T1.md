# DS_T1: Task Queue & Model Configuration Summary

## 1. Task Queue Mechanism (from HEARTBEAT.md)
The system operates a **Global Task Execution Engine** with the following workflow:

### A. Task Retrieval & Validation
- **Status Check:** Prioritize existing processes. If running, do not interrupt. If partial, finish.
- **Next Task:** Sourced via `scripts/get-next-task.ps1`.

### B. Estimation & routing
Each task is rated on:
1.  **Complexity:** Trivial / Moderate / Complex.
2.  **Cost:** Low (<$0.50) to High (>$2.00).
3.  **Value:** Hygiene / Feature / Critical.
4.  **Agent:** Dispatch to `agent:main` (Strategic), `agent:coder` (Coding), or `agent:fast` (Reflex).

### C. Execution Policy
-   **Frontier Escalation:** High-value research tasks affecting architecture/security must escalate to **Claude Opus 4.6** or **GPT-5**.
-   **Circuit Breaker:** Stop after 3 consecutive errors. Mandatory RCA (Root Cause Analysis) posted to GitHub & Telegram.
-   **Completion:** Commit -> Push -> Close Issue -> Notify.
-   **Blocking:** Report `blocked:human` or `blocked:technical` (triggers MetaThrone/Claude Code escalation).

### D. Idle State
-   If no tasks: Reply `HEARTBEAT_IDLE` and sleep.

## 2. Model Configuration

### Current Session
-   **Model:** `openrouter/google/gemini-3-pro-preview`
-   **Host:** `LAPTOP-1S7MKKK6`
-   **Agent:** `agent:main` (Subagent)

### Policy Configuration (HEARTBEAT.md)
-   **Default Execution:** DeepSeek V3.2 (implied for standard tasks).
-   **Research/Escalation:** `openrouter/anthropic/claude-opus-4-6` or GPT-5.
-   **Technical Blocker Resolution:** Claude Code (MetaThrone).

## 3. Artifact Status
-   **MEMORY_COPY.md:** File appears empty or inaccessible.
