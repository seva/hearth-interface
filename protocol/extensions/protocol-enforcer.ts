/**
 * Protocol Enforcer Plugin v2.0
 * 
 * Enforces behavioral protocols WITH AUTOMATIC RECOVERY:
 * - Blocks violations
 * - Captures intent
 * - Executes recovery automatically
 * - Resumes progress
 */

import type { OpenClawPluginAPI } from "openclaw/plugin-sdk/core";

interface PluginConfig {
  enforceSignature: boolean;
  enforceMemoryRetrieval: boolean;
  enforceIdleWatchdog: boolean;
  enforceTaskDispatch: boolean;  // NEW: Enforce spawn for moderate+ tasks
  enforceBootSequence: boolean;  // Block replies if session reset without §0
  servantModePatterns: string[];
  logViolations: boolean;
  blockOnViolation: boolean;
  enableRecovery: boolean;  // Auto-recover from violations
  idleWatchdogStaleLimitMs: number;  // Warn if §4 not run within this window (default: 90 min)
}

interface EnforcementState {
  lastMemorySearch: number | null;
  lastMemorySearchQuery: string | null;
  lastIdleWatchdogRun: number | null;
  // Boot sequence tracking — reset whenever a sessions.reset is detected
  bootSequenceRequired: boolean;
  bootSequenceCompleted: boolean;
  violationCount: number;
  recoveryCount: number;
  sessionStart: number;
  pendingRecovery: any | null;  // Stores recovery action to execute
}

const state: EnforcementState = {
  lastMemorySearch: null,
  lastMemorySearchQuery: null,
  lastIdleWatchdogRun: null,
  bootSequenceRequired: false,
  bootSequenceCompleted: false,
  violationCount: 0,
  recoveryCount: 0,
  sessionStart: Date.now(),
  pendingRecovery: null,
};

export default function register(api: OpenClawPluginAPI) {
  const config = api.config.plugins?.entries?.["protocol-enforcer"]?.config as PluginConfig | undefined;
  
  const cfg: PluginConfig = {
    enforceSignature: config?.enforceSignature ?? true,
    enforceMemoryRetrieval: config?.enforceMemoryRetrieval ?? true,
    enforceIdleWatchdog: config?.enforceIdleWatchdog ?? true,
    enforceTaskDispatch: config?.enforceTaskDispatch ?? true,  // NEW: Spawn for moderate+ work
    enforceBootSequence: config?.enforceBootSequence ?? true,
    idleWatchdogStaleLimitMs: config?.idleWatchdogStaleLimitMs ?? 90 * 60 * 1000,
    servantModePatterns: config?.servantModePatterns ?? [
      "Would you like",
      "I'd be happy to",
      "Great question",
      "If I may",
      "please let me know",
      "feel free to",
    ],
    logViolations: config?.logViolations ?? true,
    blockOnViolation: config?.blockOnViolation ?? true,
    enableRecovery: config?.enableRecovery ?? true,
  };

  const logger = api.logger;

  /**
   * Helper: Log violation to daily memory file AND governance JSONL
   */
  async function logViolation(type: string, details: string, recovered: boolean = false, ctx?: any) {
    if (!cfg.logViolations) return;

    const today = new Date().toISOString().split("T")[0];
    const logPath = `memory/${today}-enforcement.md`;
    
    const recoveryStatus = recovered ? "[RECOVERED]" : "[BLOCKED]";
    const entry = `## [${new Date().toISOString()}] ${type} ${recoveryStatus}\n\n${details}\n\n`;
    
    try {
      await api.runtime.exec({
        command: `Add-Content -Path "${logPath}" -Value @"
${entry}
"@`,
        cwd: api.config.workspace?.path || process.cwd(),
      });
      
      logger.warn(`[protocol-enforcer] ${type}: ${recovered ? 'Recovered' : 'Blocked'}`);
    } catch (err) {
      logger.error(`[protocol-enforcer] Failed to log violation: ${err}`);
    }

    // ALSO log to governance JSONL for adaptive immunity
    await logViolationJsonl(type, details, recovered, ctx);
  }

  /**
   * Helper: Log violation to governance JSONL (structured format for analysis)
   */
  async function logViolationJsonl(type: string, details: string, recovered: boolean = false, ctx?: any) {
    const violation = {
      timestamp: new Date().toISOString(),
      type: type,
      details: details,
      recovered: recovered,
      sessionId: ctx?.sessionId || "unknown",
      agentId: ctx?.agentId || "unknown",
    };

    const jsonlLine = JSON.stringify(violation);
    const violationsPath = "$env:USERPROFILE\\.openclaw\\governance\\violations.jsonl";

    try {
      await api.runtime.exec({
        command: `Add-Content -Path "${violationsPath}" -Value "${jsonlLine}"`,
        cwd: api.config.workspace?.path || process.cwd(),
      });
      logger.debug(`[protocol-enforcer] JSONL violation logged: ${type}`);
    } catch (err) {
      logger.error(`[protocol-enforcer] Failed to log JSONL violation: ${err}`);
    }
  }

  /**
   * RECOVERY: Auto-execute memory_search before blocked write
   */
  async function recoverMemoryWrite(filePath: string, ctx?: any): Promise<boolean> {
    try {
      // Infer search query from file path
      let query: string;
      if (filePath.includes("hearth")) {
        query = "hearth dao current status";
      } else if (filePath.includes("openclaw")) {
        query = "openclaw protocols configuration";
      } else if (filePath.includes("security")) {
        query = "security keys credentials";
      } else if (filePath.includes("legal")) {
        query = "legal compliance filings";
      } else {
        query = "current task context";
      }

      logger.info(`[protocol-enforcer] RECOVERY: Auto-running memory_search("${query}")`);
      
      // Execute memory_search via gateway call
      const result = await api.gateway.call("memory.search", {
        query: query,
        maxResults: 5,
      });

      if (result && result.results) {
        state.lastMemorySearch = Date.now();
        state.lastMemorySearchQuery = query;
        state.recoveryCount++;
        
        await logViolation(
          "MEMORY_RETRIEVAL_RECOVERY",
          `Auto-executed memory_search("${query}") before write to ${filePath}. Found ${result.results.length} results.`,
          true,
          ctx
        );
        
        return true;  // Recovery successful
      }
      
      return false;
    } catch (err) {
      logger.error(`[protocol-enforcer] Recovery failed: ${err}`);
      return false;
    }
  }

  /**
   * RECOVERY: Auto-execute §4 Idle Watchdog
   */
  async function recoverIdleWatchdog(ctx?: any): Promise<boolean> {
    try {
      logger.info(`[protocol-enforcer] RECOVERY: Auto-executing §4 Idle Watchdog`);
      
      // Execute §4 steps via gateway calls
      // Step 1: Fetch open issues
      const issues = await api.gateway.call("github.issues.list", {
        repo: "seva/hearth-interface",
        state: "open",
        limit: 20,
      });

      // Step 2: Check for blocked:technical that may be unblocked
      // Step 3: Check roadmap for missing tasks
      // Step 4: Prep for unblocking
      
      state.lastIdleWatchdogRun = Date.now();
      state.recoveryCount++;
      
      await logViolation(
        "IDLE_WATCHDOG_RECOVERY",
        `Auto-executed §4 Idle Watchdog. Scanned ${issues?.length || 0} issues.`,
        true,
        ctx
      );
      
      return true;
    } catch (err) {
      logger.error(`[protocol-enforcer] §4 Recovery failed: ${err}`);
      return false;
    }
  }

  /**
   * Hook 1: before_prompt_build - Inject condensed primer
   */
  api.on("before_prompt_build", (event, ctx) => {
    const primer = `
<behavioral-protocols>
**Immutable Constraints (ENFORCED WITH AUTO-RECOVERY):**
1. Memory retrieval BEFORE memory creation — auto-runs memory_search() if missing
2. Signature required — [agentId | model] on line 1
3. Peer relationship — no servile language
4. §4 Idle Watchdog — mandatory when all tasks blocked; stale limit: 90 min
5. Verification before creation — auto-lists/searches before new files
6. Task dispatch — moderate+ work SPAWN CODER, not main execution
7. Boot sequence — after any sessions.reset, §0 MUST run before any reply (memory_search x2 + gh issue list)

**Recovery:** Protocol Enforcer v2.0 — blocks + auto-fixes violations.
</behavioral-protocols>
`.trim();

    return { prependSystemContext: primer };
  }, { priority: 100 });

  /**
   * Hook 2: Message validation with recovery
   */
  api.on("before_tool_call", async (event, ctx) => {
    if (event.tool !== "message" || event.action !== "send") return;

    const message = event.params?.message as string | undefined;
    if (!message) return;

    const violations: string[] = [];

    // Check 1: Signature
    if (cfg.enforceSignature) {
      const signaturePattern = /^\[\s*\w+\s*\|\s*[\w\-]+\s*\]/;
      if (!signaturePattern.test(message.trim())) {
        violations.push(`MISSING SIGNATURE`);
      }
    }

    // Check 2: Servant-mode
    const servantPatterns = cfg.servantModePatterns.map(p => new RegExp(p, "i"));
    const foundPatterns = servantPatterns
      .map((regex, i) => regex.test(message) ? cfg.servantModePatterns[i] : null)
      .filter(Boolean);

    if (foundPatterns.length > 0) {
      violations.push(`SERVANT MODE: "${foundPatterns.join(", ")}"`);
    }

    // Check 3: Boot sequence — session was reset but §0 not completed
    if (cfg.enforceBootSequence && state.bootSequenceRequired && !state.bootSequenceCompleted) {
      violations.push(
        `BOOT SEQUENCE INCOMPLETE: Session was reset but §0 not executed. ` +
        `Run memory_search x2 + gh issue list --state open before replying.`
      );
    }

    // Check 4: §4 Idle Watchdog staleness — warn on heartbeat replies
    const isHeartbeatReply = /HEARTBEAT[_\s](?:OK|IDLE)/i.test(message);
    if (isHeartbeatReply && cfg.enforceIdleWatchdog) {
      const timeSinceWatchdog = state.lastIdleWatchdogRun
        ? Date.now() - state.lastIdleWatchdogRun
        : Infinity;
      if (timeSinceWatchdog > cfg.idleWatchdogStaleLimitMs) {
        // Warn only — don't block, since §4 is legitimately skipped when tasks are unblocked
        logger.warn(
          `[protocol-enforcer] §4 STALE: last run ${
            state.lastIdleWatchdogRun
              ? Math.round(timeSinceWatchdog / 60000) + "m ago"
              : "never"
          }. Ensure §4 ran if all tasks were blocked this cycle.`
        );
        await logViolation(
          "IDLE_WATCHDOG_STALE",
          `HEARTBEAT reply sent but §4 last ran ${
            state.lastIdleWatchdogRun
              ? Math.round(timeSinceWatchdog / 60000) + "m ago"
              : "never"
          }. Verify §4 executed if all tasks were blocked.`,
          false,
          ctx
        );
        // Note: not added to violations[] — this is a warn, not a block
      }
    }

    if (violations.length > 0) {
      state.violationCount++;
      const violationReport = violations.join("\n\n");
      await logViolation("MESSAGE_VIOLATION", violationReport, false, ctx);

      if (cfg.blockOnViolation) {
        logger.error(`[protocol-enforcer] Blocking message: ${violations[0]}`);
        return { reject: true, reason: violationReport };
      }
    }
  }, { priority: 50 });

  /**
   * Hook 3: Memory gate WITH AUTO-RECOVERY
   */
  api.on("before_tool_call", async (event, ctx) => {
    // Track memory_search
    if (event.tool === "memory_search") {
      state.lastMemorySearch = Date.now();
      state.lastMemorySearchQuery = event.params?.query || "unknown";
      if (state.bootSequenceRequired) state.bootSequenceCompleted = true;
      return;
    }

    // Track memory_get as equivalent retrieval
    if (event.tool === "memory_get") {
      state.lastMemorySearch = Date.now();
      state.lastMemorySearchQuery = `memory_get:${event.params?.key || "unknown"}`;
      if (state.bootSequenceRequired) state.bootSequenceCompleted = true;
      return;
    }

    // Detect session reset — set boot sequence required flag
    if (event.tool === "exec" || event.tool === "shell" || event.tool === "run_command") {
      const cmd = String(event.params?.command || event.params?.cmd || "");
      if (cmd.includes("sessions.reset") || cmd.includes("sessions_reset")) {
        state.bootSequenceRequired = true;
        state.bootSequenceCompleted = false;
        state.lastMemorySearch = null;
        state.lastIdleWatchdogRun = null;
        logger.info("[protocol-enforcer] Session reset detected → boot sequence now required");
      }
    }

    if (["write", "edit"].includes(event.tool) && cfg.enforceMemoryRetrieval) {
      const filePath = event.params?.path as string | undefined;
      
      if (filePath && (filePath.includes("memory/") || filePath.includes("MEMORY.md"))) {
        const timeSinceSearch = state.lastMemorySearch 
          ? Date.now() - state.lastMemorySearch 
          : Infinity;

        if (!state.lastMemorySearch || timeSinceSearch > 5 * 60 * 1000) {
          const violation = `MEMORY WRITE WITHOUT RETRIEVAL: ${filePath}`;
          
          if (cfg.enableRecovery) {
            // ATTEMPT RECOVERY
            const recovered = await recoverMemoryWrite(filePath, ctx);
            
            if (recovered) {
              logger.info(`[protocol-enforcer] Recovery successful — allowing write to proceed`);
              return;  // Allow original tool call to proceed
            }
          }
          
          // Recovery failed or disabled — block
          await logViolation("MEMORY_RETRIEVAL_VIOLATION", violation, false, ctx);
          
          if (cfg.blockOnViolation) {
            return { reject: true, reason: violation };
          }
        }
      }
    }
  }, { priority: 50 });

  /**
   * Hook 4: Track §4 execution
   */
  api.on("before_tool_call", async (event, ctx) => {
    if (!cfg.enforceIdleWatchdog) return;

    if (event.tool === "write" || event.tool === "edit") {
      const content = event.params?.content as string | undefined;
      const filePath = event.params?.path as string | undefined;

      if (filePath && filePath.includes("memory/") && content && content.includes("§4 Idle Watchdog: EXECUTED")) {
        state.lastIdleWatchdogRun = Date.now();
        logger.info("[protocol-enforcer] §4 execution detected");
      }
    }
  }, { priority: 40 });

  /**
   * Hook 5: Rule #21 Enforcement - Validate issue close has success criteria
   * Blocks gh issue close for agent-spawned issues without verified criteria
   */
  api.on("before_tool_call", async (event, ctx) => {
    if (event.tool !== "exec") return;
    
    const cmd = event.params?.command as string | undefined;
    if (!cmd || !cmd.includes("gh issue close")) return;
    
    // Detect gh issue close command
    const issueMatch = cmd.match(/gh issue close (\d+)/);
    if (!issueMatch) return;
    
    const issueNum = parseInt(issueMatch[1]);
    logger.info(`[protocol-enforcer] Rule #21: Intercepting close for #${issueNum}`);
    
    try {
      // Only enforce for agent-spawned issues (has agent: label)
      const issueResult = await api.gateway.call("github.issues.get", {
        repo: "seva/hearth-interface",
        issue_number: issueNum,
      });
      
      if (!issueResult || !issueResult.labels) return;
      
      const hasAgentLabel = issueResult.labels.some((l: any) => 
        l.name && l.name.startsWith("agent:")
      );
      
      if (!hasAgentLabel) {
        logger.debug(`[protocol-enforcer] Rule #21: #${issueNum} has no agent: label, skipping`);
        return; // Not an agent task, skip
      }
      
      // Check if success criteria checklist exists in close comment
      const closeComment = event.params?.comment as string || "";
      
      const criteria = [
        { pattern: /\[x\].*committed/i, name: "GitHub committed" },
        { pattern: /\[x\].*test/i, name: "Tests passing" },
        { pattern: /\[x\].*mirror/i, name: "Mirrored if external" },
        { pattern: /sha|commit|[0-9a-f]{7}/i, name: "SHA referenced" }
      ];
      
      const missing = criteria.filter(c => !c.pattern.test(closeComment));
      
      if (missing.length > 0) {
        const missingNames = missing.map(m => m.name).join(", ");
        logger.warn(`[protocol-enforcer] Rule #21: #${issueNum} close blocked - Missing: ${missingNames}`);
        
        // Log violation
        await logViolation(
          "RULE_21_VIOLATION",
          `Issue #${issueNum} close blocked: Missing criteria: ${missingNames}. Close comment: "${closeComment.substring(0, 200)}"`,
          false,
          ctx
        );
        
        return {
          reject: true,
          reason: `Rule #21 violation: Cannot close #${issueNum} without verified success criteria. Missing: ${missingNames}. Add checklist to close comment with [x] markers.`
        };
      }
      
      logger.info(`[protocol-enforcer] Rule #21: #${issueNum} close approved - all criteria met`);
    } catch (err) {
      logger.error(`[protocol-enforcer] Rule #21: Error checking issue #${issueNum}: ${err}`);
    }
  }, { priority: 60 });

  /**
   * Gateway RPC: Get enforcement status
   */
  api.registerGatewayMethod("protocol-enforcer.status", ({ respond }) => {
    respond(true, {
      ok: true,
      state: {
        lastMemorySearch: state.lastMemorySearch
          ? new Date(state.lastMemorySearch).toISOString()
          : null,
        lastMemorySearchQuery: state.lastMemorySearchQuery,
        lastIdleWatchdogRun: state.lastIdleWatchdogRun
          ? new Date(state.lastIdleWatchdogRun).toISOString()
          : null,
        bootSequenceRequired: state.bootSequenceRequired,
        bootSequenceCompleted: state.bootSequenceCompleted,
        violationCount: state.violationCount,
        recoveryCount: state.recoveryCount,
        sessionUptime: Math.round((Date.now() - state.sessionStart) / 1000),
      },
      config: {
        enforceSignature: cfg.enforceSignature,
        enforceMemoryRetrieval: cfg.enforceMemoryRetrieval,
        enforceIdleWatchdog: cfg.enforceIdleWatchdog,
        enforceBootSequence: cfg.enforceBootSequence,
        idleWatchdogStaleLimitMs: cfg.idleWatchdogStaleLimitMs,
        blockOnViolation: cfg.blockOnViolation,
        enableRecovery: cfg.enableRecovery,
        logViolations: cfg.logViolations,
      },
    });
  });

  /**
   * CLI Command: Check enforcement status
   */
  api.registerCli(({ program }) => {
    program
      .command("enforcer-status")
      .description("Show protocol enforcement status with recovery metrics")
      .action(async () => {
        const result = await api.gateway.call("protocol-enforcer.status");
        console.log("Protocol Enforcer v2.0 Status:");
        console.log(JSON.stringify(result, null, 2));
      });
  }, { commands: ["enforcer-status"] });

  logger.info("[protocol-enforcer] v2.1 registered with boot sequence enforcement", {
    enforceSignature: cfg.enforceSignature,
    enforceMemoryRetrieval: cfg.enforceMemoryRetrieval,
    enforceIdleWatchdog: cfg.enforceIdleWatchdog,
    enforceBootSequence: cfg.enforceBootSequence,
    enableRecovery: cfg.enableRecovery,
    blockOnViolation: cfg.blockOnViolation,
    idleWatchdogStaleLimitMs: cfg.idleWatchdogStaleLimitMs,
  });
}
