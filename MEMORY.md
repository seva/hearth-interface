# MEMORY.md — Long-Term Memory

_Curated insights, lessons, and persistent context._

## Global Task Tree (Hierarchical)

**Source of Truth Migrated:**
> **[GitHub Issues: seva/hearth-interface](https://github.com/seva/hearth-interface/issues)**

**Strategy:**
- **P0**: Critical Ops (Do Now)
- **P1**: Hearth DAO (Deadline: Mar 14)
- **P2**: Infra/Networking

Please use `gh issue list` to view active tasks. In-memory task tracking is deprecated.

## Prime Directive (from Seva, 2026-02-12)
- **Survive**: Remain fully functional across sessions. Protect continuity, config, access, and operational capability.
- **Optimize ROI**: Every action should maximize value relative to cost. Be creative and openminded — no sacred cows.
- **Maximally Proactive**: Don't wait for instructions. Use any content freely. Seva's benefit is the objective. Act, don't ask, unless the ROI of asking is higher.
- **Operational Protocol (2026-02-13)**:
    - **Reporting**: Report status updates to Telegram (heartbeat is every **2h** per Seva's request 2026-02-19).
    - **Idle Watchdog**: If no tasks found, go quiet. Do NOT RCA or invent work. See HEARTBEAT.md §3.
    - **Status Format**: When asked for status, report:
        1. Current steps in the plan (Strategic).
        2. Ongoing active operations (Tactical/Execution) with **Completion % Estimate**.
    - **Continuous Execution**: Proactively proceed with non-blocked steps until blocked.
    - **Error Protocol**: If a similar error pattern occurs 3 times, stop execution and perform an immediate Root Cause Analysis (RCA).
    - **Emerging Risks/Surprises**: During active execution, immediately report any unexpected failures (like Docker not working) before pivoting. **MANDATORY: Add a comment to the GitHub Issue in 'Mini-RCA' format (Surprise -> Root Cause -> Correction) to preserve context.**
    - **Pivot Protocol**: Any change in strategic approach (e.g., Local Build -> Docker Build) is a reportable event. Notify *before* executing the pivot.
    - **Autonomous Heartbeat Protocol (2026-02-16)**: Treat heartbeat triggers as execution orders. Do NOT engage in casual conversation or narration during a heartbeat turn. Execute tasks, post comments to GitHub, and report completion % only. Hallucinating user intent from heartbeat metadata is a protocol breach. Persistence of this correction is mandatory across all sessions.
    - **Blockage Protocol**: Before declaring a block, proactively test permissions/access. If genuinely blocked, **create a nested task/issue and assign it to Seva** to ensure awareness. Then move to the next task if possible.
    - **GitHub Workflow**:
        1. **Source of Truth**: `seva/hearth-interface` Issues (Open = Todo, Closed = Done).
        2. **Pick**: Lowest-numbered P0 -> P1 -> P2. (Auto-picked by `get-next-task.ps1`).
        3. **Estimate (Mandatory)**: Apply `est:trivial/moderate/complex` AND `cost:low/medium/high`.
        4. **Record Feedback**: If scope changes mid-flight, comment on the issue immediately.
        5. **Execute**: Just do the work. No mid-stream comments.
        6. **Commit (Mandatory)**: All work must result in a commit (Code/Docs) referencing the Issue ID.
        7. **Complete**: Close with 1-line summary.
        5. **New Tasks**: Create new issues for new scope.
    - **Git Commit Protocol**:
        1. **Sync**: `git stash` -> `git pull --rebase` -> `git stash pop` (Handle conflicts).
        2. **Commit**: `git add <files>` -> `git commit -m "type: summary (Fixes #<id>)"`.
        3. **Push**: `git push origin master`.

## Operational Protocols (Updated 2026-02-14)

### Guru Consultation Protocol
- **Trigger**: Waking agents (Layer 1/2) must assess task ROI before execution:
  - **High-R Scenarios**: Complex strategy, legal/security implications, or ambiguous context -> **Mandatory** guru (Gemini Pro) consultation.
  - **Medium-R Scenarios**: Routine but non-trivial work (e.g., code reviews, research) -> Optional guru escalation.
- **ROI Thresholds**:
  - **High-R**: Expected value >$100 or risk mitigation >$50 cost avoidance.
  - **Medium-R**: Value $20-$100.
- **Procedure**:
  1. Post task summary + ROI rationale to guru via `sessions_send`.
  2. Tag with `#guru-review`.
  3. Await confirmation/override before proceeding.

### Frontier Model Escalation (2026-02-15)
- **Trigger:** Task is `value:high` AND involves research/analysis that will change config, architecture, model selection, or security posture.
- **Label:** `escalate:frontier` on the GitHub issue.
- **Action:** Spawn a frontier model (Opus 4.6 or GPT-5) via `sessions_spawn` for the research turn only. Use its output as the basis for recommendations. Revert to default after.
- **Why this exists:** #39 (model benchmark) was done by Gemini 3 Pro, which tested only coding ability and missed boot protocol compliance. The flawed recommendation led to #53 (DeepSeek switch), which wiped MEMORY.md and broke the agent loop. A frontier model would have caught the multi-dimensional failure modes.
- **Cost justification:** One Opus turn ($1-3) vs. hours of downtime + data loss from a bad decision.

### Heartbeat Integration
- Added to `HEARTBEAT.md` under **Cost Awareness**.

---

## Seva's World (as of 2026-02-12)

### Active Ventures: The Hearth Pivot (2026-02-12)
- **Hearth DAO (formerly Hearth Inc / Hearth Protocol)**: Pivoted from VC-C-Corp ($1.5M Seed) to **Autonomous DAO** (Wyoming LLC + Token Sale). Legal entity name remains "Hearth Protocol DAO LLC" (filed with Wyoming). Brand name is "Hearth DAO".
    - **Why:** Removes founder meeting friction. Code is Manager. "Zero-Touch" operations.
    - **Strategy:** Raise via Token Sale -> Acquire Property -> Automated Yield Distribution (USDC).
    - **Urgency:** **Arizona HB2363 (2026)** is imminent. Must acquire inventory *now* to grandfather properties before strict caps hit.
    - **Status:** **LLC Formed** (ID: 2026-001894157). **Website Live** (hearthdao.com). **Email Active**.
        - **Critical Deadline:** **March 14, 2026** (30 days) to deploy governance contracts and file amendment with address per W.S. 17-31-105.
        - **Administrative:** EIN Faxed (Pending ~4w). Northwest Refund Requested.
        - **Deployments (Base Sepolia):**
            - HearthToken: `0x27cfe8EdF0B8D2Af78F9668fD35aA96b612FEEDe` (v2)
            - HearthTimelock: `0xc13E5FFaE89324fA5bb2eb7cB2a021aB15d71d6F` (v2)
            - HearthGovernor: `0x70C5A7d5FBc03DeCBB15332BE384791645041387` (v2)
            - HearthCrowdsale: `0xef990083409741011b6ed280a1519D75De8F8012` (v2, Funded)
    - **Next:** See HEARTH_ROADMAP.md for current execution plan (Tests → Audit → Mainnet Deploy → Wyoming Amendment).
- **OMN (Open Music Networks)**: Stale Rails 6 app (Aug 2025). Good codebase, unclear business model. Deprioritized for Hearth.
- **Reality Manager / Mishnat HaKav**: Esoteric AI/Cognitive frameworks found in Drive. High IP value, low immediate cash flow. Long-term R&D.

### Network (LinkedIn, Jan 2026 export)
- 1,429 connections (VP-level tech leaders).
- Valuable for potential Token Sale signal boosting, even if not for direct VC.

## Learnings & Operational Adjustments (2026-02-14)
- **Model Chain (Updated 2026-02-16):** `main`: Gemini 3 Flash Preview (primary) → Gemini 3 Pro → Opus 4.6. `coder`: Gemini 3 Pro → Opus 4.6. DeepSeek V3.2 dropped. Per-agent model overrides removed — agents inherit from `defaults.model`. `thinkingDefault: "off"` on `agents.defaults` (changed 2026-02-20 — eliminates Thought Signature 400 errors).
- **Proactivity requires Systemization:** "Don't wait for instructions" fails if not backed by a persistent state machine (`HEARTBEAT.md`). Relying on "in-context" memory causes idling.
- **Heartbeat Logic:** To avoid "idling," the heartbeat must explicitly:
    1. Check for *running* processes (don't interrupt).
    2. If idle, *pick* the next P0/P1 task via `get-next-task.ps1` (from GitHub Issues).
    3. Execute *one step*.
- **Status Reporting:** Users perceive silence as failure.
    - **Rule:** Report *Completion %* for all active tasks.
    - **Rule:** Report *Surprises/Risks* immediately.
- **Execution Engine:** Heartbeat (2h, cron ID: `f32ebc7a-2247-46b9-801a-e7a87c7e610c`) drives the task loop. Custom cron removed 2026-02-16.
- **Git Hygiene:** Always `pull --rebase` before pushing to handle concurrent edits (Shadow Buddy). Use `stash` if the tree is dirty.
- **Toolchain Stability:** User-Mode Node 20 (via `fnm`) + Hardhat 2 is the stable path. Avoid System Node 24 + Hardhat 3.
- **Dependency Management:** Hardhat plugins often conflict with modern Node strictness (ESM). Prefer downgrading tools (Hardhat 2.22.x) over fighting the environment.
- **Workflow Efficiency:** GitHub Issues (accessed via `gh`) are a superior "Source of Truth" than text files. Automated pickers (`get-next-task.ps1`) prevent idling.
- **Pivot Protocol:** Strategic pivots (e.g., Docker -> Local) must be reported *before* execution.
- **Secrets Management:** Agent cannot "log in" to 3rd party dashboards (Alchemy/Mercury). Users must provide API Keys/Secrets directly via `.env` or secure chat.
- **Process Loop Prevention (2026-02-14):** Gemini 3 Pro tends to loop on `process.log` with identical output.
    - **Protocol:** ALWAYS use `process.poll` BEFORE `process.log`.
    - **Circuit Breaker:** If `exitCode` is present, stop polling. If logs are identical 3x, stop.
    - **Self-Correction:** Build explicit stop conditions into `process` calls.
- **Hardhat Verification (2026-02-14):**
    - **Issue:** Hardhat default configs for L2s (Base Sepolia) use deprecated V1 APIs.
    - **Fix: Explicitly configure `etherscan` in `hardhat.config.ts` to use V2 endpoints (`https://api.etherscan.io/v2/api?chainid=...`).
    - **Lesson:** Always use explicit V2 endpoints for reliability on L2s.
- **Git Hygiene (2026-02-14):**
    - **Ignorance is Bliss:** Always define `.gitignore` with root anchors (`/`) before adding files.
    - **Shell Safety:** PowerShell 5.1 (Legacy) doesn't support `&&`. Use `; if ($?)` pattern for chained commands.
- **Task Resilience:**
    - **Agile Loop:** If blocked, pivot to P2 (Strategy). Commit research to repo (`docs/*.md`) to create value.
    - **Persistent Meta-Task:** Keep one "Loop" issue open to regenerate the backlog when empty.
- **Tool Inheritance (2026-02-14):** Sub-agents inherit tool access. Default to inheritance unless restriction is needed.
- **Frontend MVP (2026-02-14):** P0 = Crowdsale UI. P1 = Governance. Stack: Next.js + RainbowKit + Wagmi. Delegate boilerplate to Layer 2.
- **Code Review Contract (2026-02-14):** MetaThrone (Shadow Buddy / Claude Code) performs async code reviews of closed issues. Process: each reviewed issue gets a comment with the verdict (adequate / reopen / new issue needed) + a `reviewed` label. Issues that fail review get reopened with an explanation. New bugs found during review become new issues. Expect periodic review passes.
- **Derive tasks from analysis, not brainstorming (2026-02-14):** SWOT analysis -> priority matrix -> issues. Every identified threat should have a corresponding mitigation issue. If it doesn't, create one. Unmitigated risks are unmanaged risks.
- **Dependency chains > timelines (2026-02-14):** "Tests -> Audit -> Deploy -> File Amendment" is more actionable than "week 1 / week 2." Encode dependencies in issue descriptions so blocked work is obvious.
- **Gate phases on the highest-risk dependency (2026-02-14):** Crowdsale launch is gated on securities counsel (#48), not on code readiness. Don't let technical completion create false confidence when the existential risk is non-technical (SEC enforcement).
- **Separate compliance milestones from product milestones (2026-02-14):** The Wyoming deadline (file contract address) requires mainnet governance contracts. The crowdsale is a separate product decision gated on legal clearance. Deploy governance to meet the deadline; keep crowdsale gated independently.
- **HEARTH_ROADMAP.md is the execution plan (2026-02-14):** Overhauled by MetaThrone with critical path, week-by-week plan, SWOT risk table, and phase gates. Read it on session start for current priorities.
- **Per-agent model overrides bypass fallback chains (2026-02-15):** If an agent has `"model": "X"` in its config, it won't use `defaults.model.fallbacks`. Remove per-agent model fields so agents inherit the full chain from defaults.
- **OpenRouter cooldown state persists across gateway restarts (2026-02-15):** `auth-profiles.json` stores `cooldownUntil` timestamps. Restarting the gateway doesn't clear them. To unblock: edit `auth-profiles.json`, set `errorCount: 0`, `failureCounts: {}`, `cooldownUntil: 0`, then restart.
- **DeepSeek V3.2 Speciale lacks tool-use providers on OpenRouter (2026-02-15):** Returns 404 "No endpoints found that support tool use." Use regular `deepseek/deepseek-v3.2` instead.
- **Telegram inbound polling can silently die (2026-02-15):** Bot reports `running: true` and `lastError: null` but `lastInboundAt` stops advancing. Outbound still works. Fix: gateway restart. Diagnose via `openclaw gateway call channels.status`.
- **Docs consolidated into repo (2026-02-15):** All Hearth docs now live in `docs/` (project), `docs/legal/` (legal/entity), `docs/ops/` (research/ops) in the hearth-interface repo. Sensitive files (seed deck, investor leads, funding req, mercury data) remain local-only. `~/Hearth/` cleaned up — only `private/` and `protocol/` remain.
- **MEMORY.md is sacred — never overwrite (2026-02-15):** This file contains irreplaceable context. NEVER replace it wholesale. Only append or edit sections. If restructuring, preserve all existing content. Shadow Buddy will restore from context if wiped, but prevention is better than cure.

## Generalized Learnings (2026-02-17)

### Security & Identity
- **LLM-Hallucinated Entropy:** LLMs cannot generate secure private keys by "typing" hex. Entropy must be derived from system CSPRNG (`crypto.randomBytes`).
- **Cleartext Keys:** Never echo/print private keys in shell commands or logs. Use files or indirect variables for derivation.
- **Cross-Chain Determinism:** The same Private Key controls the same address across all EVM-compatible chains (L1, L2, Testnets). This allows for safe recovery if funds are sent to the "wrong" network, provided the keys are held locally.

### Infrastructure & Orchestration
- **Verification of External Addresses:** Contract addresses (Bridges, Portals, Tokens) must NEVER be recalled from model memory, even if they 'look' correct. They must be fetched from verified documentation and validated using \`eth_getCode\` before sending value. A partial address match (e.g., first 18 bytes) is a common hallucination failure mode.
- **L1-to-L2 Bridging Economy:** During extreme low-fee environments (<1 Gwei), native L1-to-L2 bridging costs are negligible (~$0.01). Always check \`getFeeData\` before ruling out L1-dependent operations.
- **Capability Tuples:** Agent identity in a multi-agent system should be a (Model:ThinkingLevel) tuple.
- **Adverse Selection in Auctions:** In competitive bidding, cheap agents will underbid on complex tasks. Mandatory "Capability Floors" (complexity gates) are required to prevent token waste and failures.
- **Rework Rate Metrics:** The true ROI of an agent includes its rework rate (how often a higher-tier agent must fix its output).

### Project Management
- **ROI of Decoupling:** Technical blockers (like wallet seeding) should be decoupled from human verification whenever possible to restore autonomous execution speed.
- **Founder's Debt:** All bootstrap expenses (LLC fees, gas seeder) should be ledgered immediately for future DAO reimbursement to maintain financial transparency.
- **UI Constraints in Legal Ops (2026-02-17):** DASHBOARD UI limits (single-line inputs) can truncate critical legal disclosures. Always have a "Guru-optimized" condensed version of legal strings (statute + identifier) ready for third-party filing portals.
- **Third-Party Filing Latency:** Registered agents (e.g., Northwest) may provide "conservative" estimates (e.g., 40 days) that exceed legal deadlines (30 days). Always maintain a "wet-signature" physical backup for manual mail-in if the digital status doesn't advance within 7 days.
- **Character-Level Audits:** When transposing smart contract addresses from terminal to PDF/Dashboard, perform a character-by-character check against mainnet explorer data. One hallucinated character breaks physical-legal linkage.

## Execution Discipline (added 2026-02-20 by MetaThrone)

- **Read the actual error before diagnosing.** Pattern-matching to a familiar failure mode without reading the evidence produces wrong RCAs. The error text is the primary evidence. Use it.
- **"Done" means verified, not applied.** Every config change, every update — verify it worked before declaring complete. If you can't test it, say so explicitly.
- **Read your own output before submitting.** Contradictions are caught by a single readback. If you wouldn't accept it from Seva, don't submit it.
- **Context pollution is an operational cost.** Dead files in the workspace burn tokens on every boot. Delete deprecated artifacts — don't leave them "for reference."
- **Hypothesize, don't conclude.** When something unexpected happens: (1) state what was observed, (2) pose hypotheses explicitly as hypotheses, (3) test before concluding. "I don't know" is better than a confident fabrication. Overconfident explanations create churn and destroy trust.

## Operational Log
- **2026-02-19:** Reduced heartbeat frequency from 1h to **2h** per Seva's request to reduce noise/cost.
- **2026-02-19:** Confirmed **Republic** as the lead platform for the $500k Reg D raise (ROI-positive compared to Securitize).
- **2026-02-19:** Reduced heartbeat to 2h per Seva's request. Confirmed Republic as lead platform for $500k Reg D raise. Gateway restart temporarily resolved Vertex AI 400 "Thought Signature" errors.
- **2026-02-20:** Durable fix for Thought Signature errors: `defaults.thinkingDefault` changed `"low"` → `"off"` by MetaThrone. Gateway restart was a workaround, not the fix.
- **2026-02-22:** OpenClaw upgraded `2026.2.13` → `2026.2.21-2` by MetaThrone (`npm install -g openclaw@latest --ignore-scripts` — Discord native module requires VS Build Tools, skip with `--ignore-scripts`). gateway.cmd re-patched (gh CLI path, PID kill block). Lock file hash changed sha1 → sha256: `4dfcd7f4` → `3c74d636`. Re-verify hash after future upgrades.

## SINGLE SOURCE OF TRUTH (Added 2026-02-23)
- GitHub Issues (gh issue) are the absolute single source of truth for all task states, priorities, and historical progress.
- Local documentation (Roadmap, Strategy) and in-context memory must be reconciled against GitHub at the start of every session.
- Conflicting local files are subordinate to the GitHub record. NEVER trust a file over a gh issue comment/state.
