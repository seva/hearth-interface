# Ops: High-ROI Hosting Analysis (Issue #40)

**Objective:** Host VixeYult (OpenClaw) 24/7 cheaply (<$10/mo) and reliably.

## Candidates

| Provider | Persistent Storage | Node 20+ | Monthly Cost | Pros | Cons |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Hetzner Cloud** | ✅ (Local NVMe) | ✅ (Docker) | **~€5 (CX22)** | Highest Perf/$ | Requires OS mgmt (Ubuntu). |
| **Railway** | ✅ (Volume) | ✅ | ~$5 + Volume | Zero-Config | Volumes mount to fixed path. |
| **Render** | ✅ (Disk) | ✅ | ~$7 + Disk | Easy | Spin-down on free tier. |
| **Oracle Free** | ✅ | ✅ | $0 | Free | **Unreliable**. (Instances reclaimed often). |

## Recommendation
**Winner: Hetzner Cloud (CX22)**
*   **Cost:** ~€4.50/mo.
*   **Specs:** 2 vCPU (Intel), 4GB RAM, 40GB Disk.
*   **Why:** We need to run Headless Browser (Puppeteer) + SQLite. PaaS (Railway) often struggles with Browser dependencies. A raw VPS handles Docker best.

## Migration Plan
1.  Provision CX22 (Ubuntu 24.04).
2.  Install Docker + Tailscale.
3.  Deploy OpenClaw Container (mounting `workspace/` volume).
4.  Sync `MEMORY.md` via Git.
