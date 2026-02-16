import Head from 'next/head';
import Link from 'next/link';

export default function Whitepaper() {
  return (
    <div className="min-h-screen bg-neutral-900 text-neutral-100 font-sans px-4 py-12">
      <Head>
        <title>Whitepaper | Hearth DAO</title>
      </Head>

      <div className="max-w-3xl mx-auto">
        <Link href="/" className="text-orange-500 hover:text-orange-400 mb-8 inline-block">
          ← Back to Hearth
        </Link>

        <article className="prose prose-invert prose-orange max-w-none">
          <h1 className="text-4xl font-bold mb-2">Hearth Protocol DAO LLC Whitepaper</h1>
          <div className="text-neutral-500 mb-8 text-sm">
            Status: Draft v0.3 • Date: Feb 14, 2026 • Legal Entity ID: 2026-001894157 (WY)
          </div>

          <h2 className="text-2xl font-bold mt-8 mb-4">Abstract</h2>
          <p className="text-neutral-300 leading-relaxed mb-6">
            Hearth DAO is an <strong>Autonomous Real Estate Investment DAO</strong> structured as a member-managed Wyoming DAO LLC.
          </p>
          <p className="text-neutral-300 leading-relaxed mb-6">
            By delegating operational decisions to smart contracts ("Code-is-Manager") and physical execution to AI agents, Hearth removes the overhead of traditional property management. The DAO acquires properties, collects rental income via on-chain payments, and distributes yield directly to its treasury and members.
          </p>

          <hr className="border-neutral-800 my-8" />

          <h2 className="text-2xl font-bold mt-8 mb-4">1. The Problem: Human Friction</h2>
          <ul className="list-disc pl-6 space-y-2 text-neutral-300 marker:text-orange-500">
            <li><strong>High Overhead:</strong> Standard property managers charge 25-40%, killing ROI.</li>
            <li><strong>Slow Governance:</strong> Traditional REITs or syndicates require board meetings and manual signatures.</li>
            <li><strong>Legal Complexity:</strong> Forming a compliant investment vehicle is expensive and slow.</li>
          </ul>

          <h2 className="text-2xl font-bold mt-8 mb-4">2. The Solution: Code-is-Manager</h2>
          <p className="text-neutral-300 leading-relaxed mb-4">Hearth acts as a "Headless Brand" managed by its members.</p>
          <ul className="list-disc pl-6 space-y-2 text-neutral-300 marker:text-orange-500">
            <li><strong>Wyoming DAO LLC:</strong> The DAO is a recognized legal person (W.S. 17-31-105) capable of holding property titles. Fiduciary duties are waived in favor of algorithmic consensus.</li>
            <li><strong>Unified Token ($HRTH):</strong> A single ERC-20 token represents governance power and economic interest in the entire portfolio, not just one house.</li>
            <li><strong>Automated Ops:</strong> AI Agents (like VixeYult) handle digital tasks, while APIs (e.g., RentAHuman) dispatch physical vendors for inspections and repairs.</li>
          </ul>

          <h2 className="text-2xl font-bold mt-8 mb-4">3. The Architecture (Base Network)</h2>
          <h3 className="text-xl font-semibold text-neutral-200 mt-6 mb-2">On-Chain Governance</h3>
          <ul className="list-disc pl-6 space-y-2 text-neutral-300 marker:text-orange-500 mb-6">
            <li><strong>Treasury (Timelock):</strong> The <code>TimelockController</code> contract holds all funds (USDC, HRTH) and owns the administrative rights to the DAO. No human has a private key.</li>
            <li><strong>Governor:</strong> Proposals to buy property or transfer funds must pass a token-weighted vote via <code>HearthGovernor</code>.</li>
            <li><strong>Crowdsale:</strong> A dedicated contract accepts USDC to mint HRTH at a fixed rate, ensuring instant liquidity allocation to the Treasury.</li>
          </ul>

          <h3 className="text-xl font-semibold text-neutral-200 mt-6 mb-2">Off-Chain Operations</h3>
          <ul className="list-disc pl-6 space-y-2 text-neutral-300 marker:text-orange-500">
            <li><strong>Legal Wrapper:</strong> The Wyoming LLC creates a liability shield and tax identity (EIN) for the DAO.</li>
            <li><strong>Integration:</strong> Stablecoin payments (USDC) from guests flow into the Treasury. Vendors are paid in crypto or fiat via fiat-off-ramps (e.g., Mercury, pending integration).</li>
          </ul>

          <h2 className="text-2xl font-bold mt-8 mb-4">4. Tokenomics ($HRTH)</h2>
          <p className="text-neutral-300 leading-relaxed mb-4">
            <strong>$HRTH</strong> is the governance and utility token of the DAO.
          </p>
          
          <h3 className="text-xl font-semibold text-neutral-200 mt-6 mb-2">Supply & Distribution</h3>
          <p className="text-neutral-300 leading-relaxed mb-4">1,000,000,000 Total Supply.</p>
          <ul className="list-disc pl-6 space-y-2 text-neutral-300 marker:text-orange-500 mb-6">
            <li><strong>40% - Public Crowdsale:</strong> Capital raise for first acquisitions.</li>
            <li><strong>20% - DAO Treasury:</strong> Future growth, maintenance reserves, incentives.</li>
            <li><strong>20% - Founders (Vested):</strong> 4-year linear vesting to align long-term incentives.</li>
            <li><strong>20% - Liquidity:</strong> Initial DEX pools (Aerodrome/Uniswap on Base).</li>
          </ul>

          <h2 className="text-2xl font-bold mt-8 mb-4">5. Roadmap</h2>
          <ul className="list-disc pl-6 space-y-2 text-neutral-300 marker:text-orange-500">
            <li><strong>Phase 1 (Completed):</strong> LLC Formation, Base Sepolia Deployment, Website V1.</li>
            <li><strong>Phase 2 (Active):</strong> EIN/Banking Setup, Code Audits, Whitepaper V2.</li>
            <li><strong>Phase 3 (Mar 2026):</strong> Mainnet Deployment, Governance Amendment Filing (Wyoming).</li>
            <li><strong>Phase 4 (Apr 2026):</strong> First Property Acquisition (Target: Arizona) before HB2363 regulatory shifts.</li>
          </ul>
        </article>

        <div className="mt-12 pt-8 border-t border-neutral-800 text-center text-xs text-neutral-600">
          Disclaimer: This is a technical whitepaper for Hearth Protocol DAO LLC. Not financial advice.
        </div>
      </div>
    </div>
  );
}