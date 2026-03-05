# Hearth DAO: The Autonomous Cycle

```mermaid
graph TD
    User([Investor]) -->|Buy Token| DAO{Hearth Protocol DAO LLC}
    DAO -->|Acquire Property| Property[Sedona Cabin]
    
    subgraph Ops [The Operator AI]
        API[Airbnb/VRBO] -->|Bookings| Agent[AI Manager]
        Agent -->|Pricing| Dynamic[PriceLabs]
        Agent -->|Maintenance| Vendor[TaskRabbit]
    end
    
    Property -->|Rental Income| Ops
    Ops -->|USDC Yield| Contract[Smart Contract]
    Contract -->|Stream Yield| User
```


## Frontend Tech Stack

**Decision (2026-02-14):** Next.js + RainbowKit + Wagmi

| Priority | Feature | Stack |
|---|---|---|
| P0 | Crowdsale UI | Next.js, RainbowKit, Wagmi |
| P1 | Governance UI | Next.js, RainbowKit, Wagmi |

RainbowKit handles wallet connection UX. Wagmi handles contract reads/writes. Next.js for routing and SSR.
