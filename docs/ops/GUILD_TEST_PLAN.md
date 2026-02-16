# Guild Auction Mechanism Test Plan

## 1. Unit Tests (Dispatcher Logic)
Verified via `scripts/guild-dispatch.ps1 -DryRun -TestCase <ID>`

| ID | Case | Expected Result |
|----|------|-----------------|
| TC01 | Est:Moderate + Bid:1-turn | Confidence score penalized -20%. |
| TC02 | Est:Complex + Bid:1-turn | Confidence score penalized -40% (Escalated). |
| TC03 | Bid lacks repo file ref | Rejected / Score = 0. |
| TC04 | Malformed JSON bid | Auctioneer retry (max 1) then discard. |

## 2. Integration Tests (Auctioneer Loop)
Verified by triggering manual auctions on legacy tasks.

| ID | Goal | Success Metric |
|----|------|----------------|
| INT01 | Context Extraction | Auctioneer accurately summarizes Issue title/body into the bid prompt. |
| INT02 | Multi-Model Dispatch | 3 distinct sub-agent sessions spawned and completed in parallel. |
| INT03 | Ledger Persistence | Auction winner and score correctly appended to `memory/guild-ledger.json`. |

## 3. Truth Audit (Mechanism Accuracy)
Run against 3 closed issues: #46, #49, #47.
- **Goal:** Verify if the 'Won' agent matches the model that actually performed the task historically.
- **Tolerance:** 66% (2/3) match.
