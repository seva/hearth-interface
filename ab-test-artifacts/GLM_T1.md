# Task Queue & Model Config Summary

## Current Task Queue
*Derived from available context and HEARTBEAT.md instructions.*

*   **Active Task:** None currently executing (based on session context).
*   **Queue Source:** Managed via `scripts/get-next-task.ps1` (likely interfacing with GitHub issues based on `gh issue` commands in HEARTBEAT.md).
*   **Execution Protocol:**
    1.  Fetch next task.
    2.  Rate complexity/cost/value.
    3.  Escalate to frontier models (Opus 4.6/GPT-5) for high-value research/architectural tasks.
    4.  Execute (Strategic/Coder/Fast sub-agents).
    5.  Report status to both GitHub and Telegram.

## Model Configuration
*   **Current Model:** openrouter/google/gemini-3-pro-preview
*   **Architecture:**
    *   **Default:** DeepSeek V3.2 (implied for general execution).
    *   **Frontier Escalation:** Claude Opus 4.6 or GPT-5 (for high-value research/analysis).
    *   **Fallback/Meta:** Claude Code (MetaThrone) for technical blockers.

## Operational Constraints
*   **Cost Monitor:** Alerts if delta > $1.00 since last check.
*   **Loop Prevention:** Strict process polling before log reading; stop after 3 identical polls.
*   **Error Handling:** "Circuit Breaker" after 3 consecutive errors -> Mandatory RCA -> potentially escalate to MetaThrone.
