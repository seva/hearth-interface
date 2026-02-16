# Key Person Risk Mitigation (SPOF Analysis)
*Status: Initial Audit - Feb 16, 2026*

## 1. Critical Founder Dependencies (The "SPOF" List)
The following operations currently require Seva's direct, manual execution:

| Area | Task/Dependency | Rationale | Backup / Mitigation |
|------|-----------------|-----------|---------------------|
| **Deployment** | Mainnet gas funding (#50) | Agent has no seed/fiat access. | Pre-fund a multisig controller. |
| **Legal** | Wyoming state filings (#51) | Requires officer signature (Wyoming LLC). | Appoint the Registered Agent as signatory for state filings? |
| **Banking** | EIN follow-up / Mercury setup (#17) | IRS/Bank requires human KYC/Officer Identity. | POA for a trusted delegate. |
| **Funding** | Platform KYC (Securitize) (#61) | Platform requires face-match/identity verification. | None (Founder Only). |
| **Compliance** | Securities counsel engagement (#48) | Retainer signing / Reps & Warranties. | Board resolution/multisig? |

## 2. Immediate Procedural Mitigation
### A. The "Digital Inheritance" / Emergency Access Runbook
- [ ] Document location of HW wallets (not keys, just physical location for family/trustee).
- [ ] Document entity documents location (Northwest portal access).
- [ ] Formalize a "Power of Attorney" (POA) plan for a trusted 3rd party delegate to handle physical banking or notary tasks if needed.

### B. Structural Mitigation
- **Registered Agent as Officer:** Consider amending LLC Operating Agreement to allow the Registered Agent (Northwest) or a 3rd party service limited power of signature for state filings.
- **Multisig Governance:** Rapidly move from Deployer EOA towards a Gnosis Safe with Seva + 1 other trusted keyholder.

## 3. Next Actions
1. Seva to review list and identify a 'Delegate' candidate. 
2. Create `docs/ops/signatory-delegation.md` for specific platform instructions.
