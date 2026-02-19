# Issue #70 — Deep-Dive Stack Parity Analysis (V2)

**Author:** VixeYult (guru/claude-opus-4-6)  
**Date:** 2026-02-18  
**Scope:** Evaluate 5 multi-agent orchestration stacks against the *specific* custom architecture of the Hearth Protocol workspace — the Guild Auction System, Markdown Identity Persistence, and Hardhat/Web3 CLI skill integration.

---

## 0. Current Architecture Fingerprint (Baseline)

Before evaluating anything, here's what we're actually comparing against:

| Dimension | Current Implementation |
|---|---|
| **Runtime** | OpenClaw Gateway (Node.js/TypeScript) + PowerShell scripts |
| **Guild Dispatch** | `guild-dispatch.ps1` — Score = `Confidence / (Cost × 10)` with label-based multipliers (×1.5 tech, ×1.3 strategy), turn-count penalties, JSON ledger persistence |
| **Bidders** | 3 models (flash/ds/gemini) with static cost weights; simulated confidence via random sampling; no LLM-generated self-assessment yet |
| **Identity** | SOUL.md → IDENTITY.md → AGENTS.md → HEARTBEAT.md → MEMORY.md chain; read at boot, modified during operation, survives session reset |
| **Task Loop** | `get-next-task.ps1` (P0→P1→P2 priority queue via `gh issue list`) → HEARTBEAT.md protocol → agent spawn |
| **Skills** | PowerShell + Node.js scripts invoking `gh`, `hardhat`, `ethers.js`, `node scripts/*.js` |
| **Language** | Mixed: TypeScript (Next.js app), PowerShell (orchestration), Python (utilities), Solidity (contracts) |
| **State** | File-system: `memory/guild-ledger.json`, `memory/*.md`, `ledger/reimbursements.json` |

### Three Critical Parity Requirements

1. **Guild Auction Logic (GAL):** Can the stack express `Score = f(Confidence, Cost, LabelBoosts, TurnPenalties)` and let a *deterministic* function (not an LLM) pick the winner? Can models eventually self-bid (Phase 3)?
2. **Identity Persistence (IP):** Can the stack read/write markdown files as the agent's "soul," reloading them across sessions, with the agent modifying its own persona files?
3. **Skill Extensibility (SE):** Can the stack invoke arbitrary shell commands (PowerShell, `gh`, `npx hardhat`, `node scripts/deploy.js`) as first-class tools without wrapping them in Python/TS boilerplate?

---

## 1. Stack-by-Stack Deep Analysis

### 1.1 LangGraph (LangChain)

**What it is:** A state-machine graph framework where nodes are functions and edges are conditional routing logic. Built on top of LangChain.

#### GAL Parity: ✅ STRONG (9/10)
LangGraph's `add_conditional_edges()` accepts *arbitrary Python functions* as routing logic. The Guild Auction formula maps directly:

```python
def guild_auction_route(state: AuctionState) -> str:
    bids = state["bids"]
    for bid in bids:
        bid["score"] = bid["confidence"] / (bid["cost"] * 10)
    winner = max(bids, key=lambda b: b["score"])
    return winner["agent_id"]

graph.add_conditional_edges("collect_bids", guild_auction_route, {
    "flash": "flash_agent", "ds": "ds_agent", "gemini": "gemini_agent"
})
```

The routing is deterministic code, not LLM-driven. Phase 3 self-bidding is achievable by adding a "bid_generation" node where each agent LLM outputs structured confidence/turns estimates before the auction node.

**Gap:** Requires rewriting `guild-dispatch.ps1` in Python. The stochastic confidence sampling (currently `Get-Random`) would become actual LLM self-assessment — arguably an upgrade.

#### IP Parity: ⚠️ MODERATE (6/10)
LangGraph has checkpointers (SQLite, Postgres, memory) for graph state persistence. But our identity system is *file-based markdown* — SOUL.md is not graph state. You'd need to:
- Add a "load_identity" node that reads SOUL.md/IDENTITY.md at graph start
- Inject their contents into agent system prompts
- Add a "persist_identity" node that writes modified identity back to `.md` files

This is *doable* but not native. LangGraph's `Store` abstraction (cross-thread memory) could partially replace `MEMORY.md` but loses human-readability.

**Gap:** The recursive self-modification ("agent edits its own SOUL.md") requires explicit file I/O nodes. LangGraph doesn't natively understand "I am my markdown files."

#### SE Parity: ⚠️ MODERATE (6/10)
LangGraph tools are Python callables. To invoke `npx hardhat deploy` or `powershell -File scripts/guild-dispatch.ps1`, you'd write:

```python
@tool
def run_hardhat_deploy(network: str) -> str:
    result = subprocess.run(["npx", "hardhat", "deploy", "--network", network], capture_output=True)
    return result.stdout.decode()
```

Every PowerShell/Node script becomes a Python subprocess wrapper. Works, but adds a translation layer. The current system calls these scripts directly from OpenClaw's exec capability without any wrapper.

**Gap:** Adds Python boilerplate around every shell tool. Windows PowerShell scripts need careful handling of paths and encoding.

---

### 1.2 AutoGen / AG2

**What it is:** Microsoft's multi-agent conversation framework. Agents communicate via messages in a GroupChat, with customizable speaker selection.

#### GAL Parity: ✅ STRONG (8/10)
AG2's `speaker_selection_method` parameter on `GroupChat` accepts a custom function:

```python
def guild_auction_selection(last_speaker, groupchat):
    # Access task labels from groupchat context
    bids = collect_bids(groupchat.messages)
    scores = {b.agent: b.confidence / (b.cost * 10) * b.multiplier for b in bids}
    winner = max(scores, key=scores.get)
    return next(a for a in groupchat.agents if a.name == winner)
```

This maps directly to the Guild Dispatch pattern. The `StateFlow` pattern blog post from AG2 shows exactly this kind of deterministic routing.

**Gap:** AG2's GroupChat model is *conversational* — agents talk to each other via messages. Our Guild system is more of a *dispatch* pattern (silent auction, then execute). The conversational overhead is unnecessary and may confuse the flow. You'd need to suppress agent cross-talk.

#### IP Parity: ❌ WEAK (4/10)
AG2 has no native concept of persistent identity files. Agent identities are defined in code:
```python
agent = AssistantAgent(name="VixeYult", system_message="You are...")
```

To replicate our markdown identity system, you'd need to:
1. Read SOUL.md into `system_message` at startup
2. Intercept agent outputs to detect identity-modification intent
3. Write changes back to files
4. Handle session-to-session persistence manually

AG2's focus is on *conversation*, not *self-modifying persistent personas*. This is a fundamental paradigm mismatch.

**Gap:** No file-based identity lifecycle. The "agent modifies its own soul" pattern is completely foreign to AG2.

#### SE Parity: ⚠️ MODERATE (5/10)
AG2 supports function registration and code execution (via Docker or local). Custom tools are registered per-agent:

```python
autogen.agentchat.register_function(
    hardhat_deploy, caller=coder, executor=admin,
    name="hardhat_deploy", description="Deploy contracts"
)
```

However, AG2's code execution model is designed for *LLM-generated* code, not pre-written CLI scripts. You'd need to bridge between AG2's execution sandbox and your PowerShell/Node toolchain.

**Gap:** The code execution sandbox is designed for safety-wrapped LLM code, not for running arbitrary `gh issue close` or `npx hardhat` commands against production repos.

---

### 1.3 CrewAI

**What it is:** Role-based agent orchestration with sequential, hierarchical, or custom processes. Agents have roles, goals, and backstories.

#### GAL Parity: ❌ WEAK (3/10)
CrewAI has three process types: Sequential, Hierarchical, and Consensual (planned). **None of them support custom scoring-based dispatch.**

- **Sequential:** Fixed order. No auction.
- **Hierarchical:** A manager LLM *decides* who to delegate to. The routing is LLM-driven, not formula-driven. You cannot inject `Score = Confidence / (Cost × 10)`.
- **Custom:** The docs mention "you can specify your own orchestration logic" but this is not a first-class API — it requires subclassing internal Process classes.

To implement the Guild Auction, you'd need to:
1. Abandon CrewAI's process system entirely
2. Build a pre-processing layer that runs the auction *before* creating the Crew
3. Only pass the winning agent to the Crew

This defeats the purpose of using CrewAI for orchestration.

**Gap:** Fundamental architecture mismatch. CrewAI's delegation is LLM-intuitive, not formula-deterministic. The `Confidence × Multiplier / Cost` scoring has no hook point.

#### IP Parity: ⚠️ MODERATE (5/10)
CrewAI agents have `role`, `goal`, `backstory` fields that map loosely to SOUL.md/IDENTITY.md concepts. CrewAI also has a memory system (short-term, long-term, entity memory).

However:
- Identity is defined in Python code, not markdown files
- There's no mechanism for an agent to *modify its own role/goal/backstory* during execution
- CrewAI's memory is stored in its own format, not human-readable markdown

You could load SOUL.md into `backstory` at startup, but the recursive self-modification loop is not supported.

**Gap:** Static identity definition. No self-modification. Memory is opaque, not markdown.

#### SE Parity: ✅ DECENT (7/10)
CrewAI's `BaseTool` system is straightforward for wrapping CLI scripts:

```python
class HardhatDeployTool(BaseTool):
    name: str = "hardhat_deploy"
    description: str = "Deploy smart contracts via Hardhat"
    def _run(self, network: str) -> str:
        return subprocess.run(["npx", "hardhat", "deploy", "--network", network], 
                            capture_output=True, text=True).stdout
```

Tasks can override agent tools, and tools are first-class objects. This is the cleanest tool integration model of any framework reviewed.

**Gap:** Still requires Python wrappers, but the wrapper pattern is minimal and idiomatic.

---

### 1.4 OpenAI Agents SDK

**What it is:** OpenAI's lightweight framework (successor to Swarm) with Agents, Handoffs, Tools, and Guardrails.

#### GAL Parity: ❌ WEAK (2/10)
The Agents SDK uses *Handoffs* for inter-agent routing. Handoffs are exposed as tools to the LLM — meaning **the LLM decides** which agent to hand off to. There is no programmatic scoring hook.

```python
triage_agent = Agent(name="Triage", handoffs=[flash_agent, ds_agent, gemini_agent])
```

The triage agent's LLM picks the target based on conversation context. You cannot inject `Score = Confidence / Cost` into this decision. The `on_handoff` callback fires *after* the LLM has already decided.

To implement Guild Auction, you'd need to:
1. Skip the Agents SDK's routing entirely
2. Run the auction in your own code
3. Call the winning agent directly via the SDK

This makes the SDK's orchestration layer pointless — you're just using it as a thin LLM wrapper.

**Gap:** LLM-driven routing only. No deterministic formula-based dispatch. Fundamental paradigm mismatch with Guild Auction.

#### IP Parity: ❌ WEAK (3/10)
Agents have `instructions` (system prompt) and that's it. No persistent state across runs. No file-based identity. No self-modification.

```python
agent = Agent(name="VixeYult", instructions="Read from SOUL.md...")
```

You'd load SOUL.md into `instructions` manually. But the agent cannot modify its own instructions during a run. Session-to-session persistence is completely external to the SDK.

**Gap:** Stateless by design. Identity is a string parameter, not a living document.

#### SE Parity: ⚠️ MODERATE (6/10)
Tools are Python functions decorated with type hints:

```python
@function_tool
def deploy_contract(network: str) -> str:
    """Deploy via Hardhat"""
    return subprocess.run(["npx", "hardhat", "deploy", "--network", network], 
                         capture_output=True, text=True).stdout
```

Clean and minimal, but no async subprocess management, no streaming output, no process lifecycle control.

**Gap:** Simple wrapper model. Adequate but not powerful for complex CLI interactions (e.g., watching a Hardhat deployment with streaming logs).

---

### 1.5 Semantic Kernel (Microsoft Agent Framework)

**What it is:** Microsoft's enterprise SDK combining Semantic Kernel and AutoGen patterns. Supports Sequential, Concurrent, GroupChat, Handoff, and Magentic orchestration.

#### GAL Parity: ⚠️ MODERATE (6/10)
Semantic Kernel's GroupChat orchestration has a manager that determines the next speaker. The Magentic orchestration pattern is the most interesting — a coordinator tracks progress and dynamically selects agents.

However, speaker selection in SK is still LLM-driven (the manager LLM picks). To inject deterministic scoring:
- You could implement a custom `GroupChatManager` with overridden selection logic
- The plugin system allows attaching custom functions that the manager can call
- But this requires C#/.NET or Python SK SDK work

SK's plugin architecture is its strongest point here — you could create a `GuildAuctionPlugin` that the manager calls as a function:

```python
class GuildAuctionPlugin:
    @kernel_function
    def run_auction(self, task_labels: str, bidders_json: str) -> str:
        # Deterministic auction logic here
        return winner_agent_name
```

**Gap:** The auction would be invoked *by* the manager LLM, not *instead of* it. The LLM still decides whether to call the auction function. This adds a layer of indirection and non-determinism.

#### IP Parity: ⚠️ MODERATE (5/10)
SK agents have instructions/system prompts. SK's memory system supports multiple stores (Redis, Elastic, etc.). But:
- No native markdown file identity system
- No self-modification pattern
- Identity is configured in code, not discovered from files

You'd build a `SoulPlugin` that reads/writes SOUL.md, but the "agent IS its markdown" philosophy doesn't translate.

#### SE Parity: ✅ DECENT (7/10)
SK's plugin system is designed for extensibility. Each plugin is a class with `@kernel_function` methods:

```csharp
public class HardhatPlugin {
    [KernelFunction]
    public string Deploy(string network) => 
        Process.Start("npx", $"hardhat deploy --network {network}").StandardOutput.ReadToEnd();
}
```

The plugin model is clean, type-safe, and well-documented. Both Python and .NET are supported. However, the current workspace is not .NET — adding C# adds a language to the stack.

**Gap:** Strong plugin model, but .NET primary SDK adds language fragmentation risk. Python SDK is less mature.

---

## 2. STAR-RAID Analysis

### Situation
Hearth Protocol runs a custom multi-agent orchestration system via OpenClaw with PowerShell dispatch scripts, markdown-based identity persistence, and Web3 CLI tooling. The system works but is bespoke — no framework backing, limited community, and the Guild Auction is currently using simulated (random) confidence instead of real model self-assessment.

### Task
Evaluate whether migrating to an established multi-agent framework delivers enough value to justify the rewrite cost, specifically for the three critical parity requirements (GAL, IP, SE).

### Action (Per Stack)

| Stack | GAL Action Required | IP Action Required | SE Action Required |
|-------|--------------------|--------------------|-------------------|
| **LangGraph** | Rewrite `guild-dispatch.ps1` as a Python conditional edge function | Build custom load/save identity nodes | Write subprocess wrappers for all CLI tools |
| **AutoGen/AG2** | Implement custom `speaker_selection_method` | Manual file I/O for identity lifecycle | Register tools per-agent, bridge execution sandbox |
| **CrewAI** | Abandon framework process system; pre-process auction externally | Load SOUL.md into backstory (static) | BaseTool wrappers (cleanest) |
| **OpenAI Agents SDK** | Skip SDK routing; run auction externally | Load into instructions (static) | @function_tool wrappers |
| **Semantic Kernel** | Build GuildAuctionPlugin called by manager LLM | Build SoulPlugin for file I/O | KernelFunction plugins (clean) |

### Result
**No stack provides full parity.** Every option requires significant custom work on at least 2 of 3 dimensions. LangGraph comes closest on dispatch logic. CrewAI and OpenAI SDK have fundamental routing paradigm mismatches.

### Assumptions
- Migration budget is limited (solo developer + AI agents)
- Current OpenClaw system is functional, just bespoke
- Phase 3 (real model self-bidding) is a planned evolution, not a current blocker

### Impact
Migration would consume 2-4 weeks minimum, during which the existing system cannot evolve. The primary value proposition is *community/ecosystem* — gaining access to framework updates, LangSmith tracing, community support, etc.

### Dependencies
- All stacks are Python-primary; current system is PowerShell/Node/TypeScript
- Migration requires standing up a Python orchestration layer alongside the existing Next.js/Hardhat stack
- OpenClaw's session_spawn model has no direct equivalent in any framework

---

## 3. SWOT Analysis (Per Stack)

### 3.1 LangGraph

| | Positive | Negative |
|---|---|---|
| **Internal** | **Strengths:** Deterministic routing via conditional edges matches Guild Auction perfectly. State machine model is explicit and testable. Checkpointing provides crash recovery. Rich ecosystem (LangSmith tracing, LangGraph Cloud). | **Weaknesses:** Heavy abstraction layer. Requires Python rewrite of all orchestration. Graph topology must be defined upfront — dynamic agent addition is clunky. LangChain dependency (large, opinionated). |
| **External** | **Opportunities:** LangGraph Cloud could host the dispatch engine. LangSmith would give observability into auction decisions. Community adoption is high. | **Threats:** LangChain ecosystem churn is notorious. Breaking changes between versions. Vendor lock-in risk to LangChain Inc. |

### 3.2 AutoGen / AG2

| | Positive | Negative |
|---|---|---|
| **Internal** | **Strengths:** Custom speaker selection maps well to auction logic. Research-backed (Microsoft). Strong multi-model support. StateFlow pattern is well-documented. | **Weaknesses:** Conversation-centric model adds overhead for dispatch patterns. Fork confusion (AG2 vs Microsoft AutoGen 0.4). Identity persistence is not addressed. |
| **External** | **Opportunities:** Microsoft Agent Framework merger with SK could provide enterprise-grade tooling. | **Threats:** AG2/AutoGen fork instability. Community split. Microsoft may deprioritize open-source version. |

### 3.3 CrewAI

| | Positive | Negative |
|---|---|---|
| **Internal** | **Strengths:** Cleanest tool integration model. Role/goal/backstory concepts loosely align with SOUL/IDENTITY. Active development, good docs. | **Weaknesses:** No custom dispatch process. LLM-driven delegation cannot be overridden with formula scoring. Consensual process (most relevant) is "planned" but not implemented. Static identity — no self-modification. |
| **External** | **Opportunities:** CrewAI Enterprise could provide managed hosting. Growing community. | **Threats:** Feature gap on custom routing may never close (not their design philosophy). Python-only. |

### 3.4 OpenAI Agents SDK

| | Positive | Negative |
|---|---|---|
| **Internal** | **Strengths:** Minimal abstractions. Clean tool model. Production-ready. Provider-agnostic (despite the name). | **Weaknesses:** Handoff routing is exclusively LLM-driven. No persistent state. No identity lifecycle. Designed for stateless request/response, not persistent autonomous agents. |
| **External** | **Opportunities:** OpenAI's backing means long-term maintenance. Could evolve to support custom routing. | **Threats:** Opinionated toward OpenAI models. Feature additions are slow (minimal philosophy). |

### 3.5 Semantic Kernel

| | Positive | Negative |
|---|---|---|
| **Internal** | **Strengths:** Best plugin extensibility model. Enterprise-grade. Multiple orchestration patterns. Model-agnostic. | **Weaknesses:** Manager LLM mediates all routing (non-deterministic). Primary SDK is .NET — Python SDK is secondary. Adds significant architectural complexity. |
| **External** | **Opportunities:** Microsoft Agent Framework consolidation could make this the dominant enterprise stack. | **Threats:** .NET focus may not suit this workspace's JS/TS/PS stack. Enterprise bias may slow open-source innovation. |

---

## 4. Tradeoff Matrix

### Weighted Scoring (10-point scale per dimension)

| Stack | GAL (×3) | IP (×2) | SE (×1.5) | Migration Cost (×2) | Ecosystem (×1.5) | **Weighted Total** |
|-------|----------|---------|-----------|---------------------|-------------------|--------------------|
| **LangGraph** | 9 × 3 = 27 | 6 × 2 = 12 | 6 × 1.5 = 9 | 5 × 2 = 10 | 8 × 1.5 = 12 | **70** |
| **AutoGen/AG2** | 8 × 3 = 24 | 4 × 2 = 8 | 5 × 1.5 = 7.5 | 5 × 2 = 10 | 6 × 1.5 = 9 | **58.5** |
| **CrewAI** | 3 × 3 = 9 | 5 × 2 = 10 | 7 × 1.5 = 10.5 | 6 × 2 = 12 | 7 × 1.5 = 10.5 | **52** |
| **OpenAI Agents SDK** | 2 × 3 = 6 | 3 × 2 = 6 | 6 × 1.5 = 9 | 7 × 2 = 14 | 7 × 1.5 = 10.5 | **45.5** |
| **Semantic Kernel** | 6 × 3 = 18 | 5 × 2 = 10 | 7 × 1.5 = 10.5 | 4 × 2 = 8 | 8 × 1.5 = 12 | **58.5** |

*Migration Cost is inverted: higher score = easier migration.*

### Weight Justification
- **GAL ×3:** The Guild Auction is the system's most unique and valuable mechanism. If a stack can't support it natively, migration is pointless.
- **IP ×2:** Identity persistence is core to the agent's personality and continuity, but could be partially externalized.
- **SE ×1.5:** Tool integration is important but all stacks can do it with wrappers.
- **Migration Cost ×2:** Solo developer bandwidth is the binding constraint.
- **Ecosystem ×1.5:** Long-term value of community, docs, and managed services.

---

## 5. Verdict & Recommendation

### Ranking
1. **LangGraph — 70 points** (Best GAL parity, strongest ecosystem)
2. **AutoGen/AG2 — 58.5** (Good GAL, poor IP, fork uncertainty)
3. **Semantic Kernel — 58.5** (Tied, strong plugins, but .NET bias and LLM-mediated routing)
4. **CrewAI — 52** (Good tools, but GAL is a dealbreaker)
5. **OpenAI Agents SDK — 45.5** (Too minimal for our architecture)

### Strategic Recommendation: **DON'T MIGRATE (Yet)**

**The honest answer is: no framework provides enough parity to justify migration right now.**

Here's why:

1. **The Guild Auction is the crown jewel.** Only LangGraph can express it natively, and even then it requires a full Python rewrite. The current PowerShell implementation *works* and is evolving toward Phase 3 (real model self-bidding).

2. **Identity Persistence is a paradigm unique to OpenClaw.** No framework understands "I am my markdown files." Every stack treats identity as a code-level configuration, not a living document the agent modifies. Migrating this would require building the same custom layer on top of any framework — so why migrate?

3. **The ROI math doesn't work (yet).** 2-4 weeks of migration for a solo developer, during which no features ship. The primary gains would be observability (LangSmith) and crash recovery (checkpointing) — both nice but not critical for the current stage.

### When to Revisit (Trigger Conditions)
- **Phase 3 Guild Auction** (real model self-bidding) is complex enough that LangGraph's graph model would genuinely help structure the bid-collect-score-dispatch loop
- **Team expansion** — if more developers join, framework standardization becomes valuable
- **Scale** — if the system needs to handle >10 concurrent agents or distributed execution
- **Observability crisis** — if debugging auction decisions becomes untenable without tracing

### Tactical Alternative: Cherry-Pick, Don't Migrate
Instead of a full migration, adopt specific capabilities:
- **LangSmith** for tracing (works standalone, doesn't require LangGraph)
- **LangGraph checkpointing pattern** adapted to the existing file-based state (implement crash-recovery for guild-ledger.json)
- **CrewAI's BaseTool pattern** as a design reference for standardizing the PowerShell tool wrappers

---

## 6. Appendix: Parity Gap Summary

| Requirement | Current System | Best Framework Match | Parity Gap |
|---|---|---|---|
| `Score = Confidence / (Cost × 10)` deterministic routing | `guild-dispatch.ps1` line 60-63 | LangGraph `add_conditional_edges()` | Rewrite in Python |
| Label-based multipliers (×1.5 tech, ×1.3 strategy) | `guild-dispatch.ps1` lines 36-47 | LangGraph state + conditional logic | Map labels to state attributes |
| Turn-count penalty (TC01, TC02) | `guild-dispatch.ps1` lines 50-57 | LangGraph pre-routing node | Build penalty node |
| JSON ledger persistence | `memory/guild-ledger.json` direct write | LangGraph checkpointer (SQLite) | Different format, same concept |
| Markdown identity read-at-boot | AGENTS.md protocol | None (all frameworks use code-level config) | Custom node/plugin in any framework |
| Agent self-modifies SOUL.md | OpenClaw file write capability | None natively | Custom implementation regardless |
| `gh issue list/close/comment` | Direct `exec` in OpenClaw | Subprocess wrapper in any framework | Thin wrapper, low effort |
| `npx hardhat deploy` | Direct `exec` in OpenClaw | Subprocess wrapper in any framework | Thin wrapper, low effort |
| Heartbeat cron loop | OpenClaw cron + HEARTBEAT.md protocol | None (all frameworks are request/response) | Completely external regardless |
| `sessions_spawn` for sub-agents | OpenClaw native | LangGraph subgraphs / AG2 GroupChat | Architectural restructuring |
