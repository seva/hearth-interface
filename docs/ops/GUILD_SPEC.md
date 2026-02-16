# Guild System Specification (v0.1)
*Projected Date: Feb 16, 2026*

## 1. Objective
Replace static model selection with a multi-agent auction system to optimize task outcomes based on empirical performance data.

## 2. Component Definitions

### A. The Auctioneer (Reflex)
- **Role:** Parse task description from backlog.
- **Model:** `flash` (Gemini Flash).
- **Function:** Enqueue `BidRequest` to candidate models.

### B. Candidate Models (Artisans)
- **Primary:** `ds` (DeepSeek V3).
- **Secondary:** `gemini` (Gemini Pro).
- **Tier 3:** `local` (Ollama/Qwen).
- **Action:** Return a JSON payload `{ approach, confidence, turns_est }`.

### C. The Dispatcher (Execution)
- **Logic:** Winner = `(confidence * weight) / cost_multiplier`.
- **Action:** Spawn winner with the task.

### D. The Reviewer (Post-Mortem)
- **Role:** Compare output vs requirements.
- **Score:** 1-5.
- **Action:** Update model `win_rate` in Ledger.

## 3. Bid Format Specification
```json
{
  "taskId": "issue_id",
  "bidder": "model_alias",
  "plan": "2-3 sentences max strategy.",
  "confidence": 0.0-1.0,
  "cost_est": "dollars",
  "timestamp": "ISO"
}
```

## 4. Federated Progress
- [ ] Ledger creation (SQLite).
- [ ] Dispatcher shell script prototype.
- [ ] First 'live' auction for a P2 task.
