# Hearth DAO - Organizational Chart & Role Architecture

## 1. Current State (Skeletal)
-   **Owner / Founder:** Seva Lapsha (Strategy, Funding, Legal Keys).
-   **Chief of Staff (Agent):** VixeYult (OpenClaw). Handles Ops, Dev, Docs, Coordination.

*Bottleneck:* VixeYult is single-threaded. Ops, Legal, and Marketing are competing for the same runtime.

## 2. Ideal State (Funded Enterprise)
*If we had $1.5M Seed, we would hire these roles:*

| Role | Domain | Responsibilities | Agentic Potential |
| :--- | :--- | :--- | :--- |
| **Legal Counsel** | Compliance | WY DAO compliance, SEC filings, Property Title verification. | **Low** (Requires Human License). |
| **Head of Growth** | Marketing | Community building (Farcaster), BizDev (Base Grants), Narratives. | **High** (Social bots + Strategy Agent). |
| **Property Ops** | Real Estate | Acquisition, cleaning, repairs, guest comms. | **Hybrid** (RentAHuman for physical, Agent for digital). |
| **Treasury Mgr** | Finance | Yield farming, tax prep, bookkeeping (Mercury). | **Medium** (Bookkeeping automation feasible). |
| **Product Lead** | Tech | dApp UX, Customer Journeys, Roadmap grooming. | **High** (Agentic Product Owner). |

## 3. Recommended "Hires" (Agentic Personas)

### A. "The Scout" (Property Acquisitions Agent)
-   **Mission:** Identify high-yield properties in Arizona before they hit Zillow.
-   **Capabilities:** Scrape AirDNA/Zillow, run Cap Rate models, draft Proposals.
-   **Implementation:** Sub-agent with specialized pricing skills (Claude/Excel).
-   **Status:** **High Priority** (Needed for Phase 4).

### B. "The Town Crier" (Growth Agent)
-   **Mission:** Maintain "Code-is-Manager" narrative presence 24/7.
-   **Capabilities:** Monitor Farcaster/Twitter, drafting updates, engaging with Base ecosystem.
-   **Implementation:** Cron-triggered social bot with brand voice guidelines.
-   **Status:** **High Priority** (Needed for Crowdsale).

### C. "The Clerk" (Legal/Admin)
-   **Mission:** Keep the LLC compliant.
-   **Capabilities:** Monitor deadlines (Annual Report), file amendments, organize `legal/` folder.
-   **Implementation:** Recurring Cron Task.
-   **Status:** Medium (Annual cycle).

## 4. Hiring Plan (Next Steps)
1.  **Deploy "The Town Crier":** Create a `marketing` persona/cron to handle GTM outreach (Issue #32).
2.  **Deploy "The Scout":** Create a `data` persona to model property deals (Phase 4).
3.  **Human Bridge:** Use **RentAHuman** API for "Boots on the Ground" (Property Ops). Do not hire full-time humans.

## 5. Organizational Philosophy
**"Hire Agents First, Humans Last."**
-   If a task is digital -> Agent.
-   If a task is physical -> RentAHuman (Gig).
-   If a task is High-Stakes Legal -> Retained Counsel (Seva).
