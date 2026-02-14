# RentAHuman Integration Guide

**Integration:** Direct REST API (Mocked).
**Purpose:** Automate physical operations (Phase 4).

## API Endpoints (Provisional)
- `GET /humans`: Search available agents by location/skill.
- `POST /tasks`: Book a human. Inputs: `human_id`, `instructions`, `payout`.
- `GET /tasks/:id`: Check status (pending -> accepted -> completed -> verified).

## Status
- [x] Mock Script (`scripts/test-rentahuman.js`) created.
- [ ] Real API Key acquired (Waitlist).
- [ ] Integration with `HearthGovernor` (requires Oracle/Chainlink or manual trigger).

## Usage
```bash
node protocol/scripts/test-rentahuman.js
```
