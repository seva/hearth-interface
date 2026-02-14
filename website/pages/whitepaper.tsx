import Head from 'next/head';
import Link from 'next/link';

export default function Whitepaper() {
  return (
    <div className="min-h-screen bg-neutral-900 text-neutral-100 font-sans px-4 py-12">
      <Head>
        <title>Whitepaper | Hearth Protocol</title>
      </Head>

      <div className="max-w-3xl mx-auto">
        <Link href="/" className="text-orange-500 hover:text-orange-400 mb-8 inline-block">
          ← Back to Hearth
        </Link>

        <article className="prose prose-invert prose-orange max-w-none">
          <h1 className="text-4xl font-bold mb-2">Hearth Protocol Whitepaper</h1>
          <div className="text-neutral-500 mb-8 text-sm">
            Status: Draft v0.2 • Date: Feb 14, 2026
          </div>

          <h2 className="text-2xl font-bold mt-8 mb-4">Abstract</h2>
          <p className="text-neutral-300 leading-relaxed mb-6">
            Hearth Protocol is the world's first <strong>Autonomous Real Estate Investment Trust</strong>. By combining the legal framework of a Wyoming DAO LLC with AI-driven property management, Hearth removes the human friction from real estate investing.
          </p>
          <p className="text-neutral-300 leading-relaxed mb-6">
            Investors purchase <strong>Hearth Tokens</strong> (HTH) which represent fractional ownership in high-yield vacation properties. An AI Agent (The Operator) autonomously manages bookings, dynamic pricing, guest communication, and maintenance dispatch via APIs. Rental income is automatically converted to stablecoins (USDC) and distributed to token holders instantly.
          </p>

          <hr className="border-neutral-800 my-8" />

          <h2 className="text-2xl font-bold mt-8 mb-4">1. The Problem: Real Estate is Broken</h2>
          <ul className="list-disc pl-6 space-y-2 text-neutral-300 marker:text-orange-500">
            <li><strong>High Barrier:</strong> $500k+ entry price excludes 99% of the population.</li>
            <li><strong>Illiquidity:</strong> Selling a home takes months and costs 6% in fees.</li>
            <li><strong>High Friction:</strong> Property managers charge 25-40% and require constant oversight.</li>
            <li><strong>Human Error:</strong> Missed bookings, bad pricing, delayed maintenance.</li>
          </ul>

          <h2 className="text-2xl font-bold mt-8 mb-4">2. The Solution: Code is the Manager</h2>
          <p className="text-neutral-300 leading-relaxed mb-4">Hearth replaces the property manager with code.</p>
          <ul className="list-disc pl-6 space-y-2 text-neutral-300 marker:text-orange-500">
            <li><strong>Legal Wrapper:</strong> A Wyoming DAO LLC holds the physical deed. The DAO is governed by token holders, but day-to-day operations are algorithmically managed.</li>
            <li><strong>Tokenization:</strong> Each property is tokenized into 1,000 HTH-Series tokens. (1 Token = 0.1% Equity + 0.1% Yield Rights).</li>
            <li><strong>Liquidity:</strong> Tokens trade 24/7 on decentralized exchanges or secondary marketplaces. Exit in seconds, not months.</li>
          </ul>

          <h2 className="text-2xl font-bold mt-8 mb-4">3. The Technology Stack</h2>
          <h3 className="text-xl font-semibold text-neutral-200 mt-6 mb-2">The Operator (AI Agent)</h3>
          <ul className="list-disc pl-6 space-y-2 text-neutral-300 marker:text-orange-500 mb-6">
            <li><strong>Pricing:</strong> Real-time dynamic pricing engine (AirDNA/PriceLabs integration).</li>
            <li><strong>Guest Comms:</strong> LLM-powered chatbot handles 99% of guest inquiries instantly.</li>
            <li><strong>Maintenance:</strong> Automated dispatch of local pros via APIs based on IoT sensor data.</li>
          </ul>

          <h3 className="text-xl font-semibold text-neutral-200 mt-6 mb-2">The Blockchain (Base / Polygon)</h3>
          <ul className="list-disc pl-6 space-y-2 text-neutral-300 marker:text-orange-500">
            <li><strong>Asset Token:</strong> ERC-1155 NFT representing the property deed share.</li>
            <li><strong>Income Token:</strong> USDC rental yield, streamed to holders.</li>
            <li><strong>Governance:</strong> Snapshot voting for major decisions (Sell Property, Upgrade Renovation).</li>
          </ul>

          <h2 className="text-2xl font-bold mt-8 mb-4">4. Legal Framework</h2>
          <p className="text-neutral-300 leading-relaxed mb-4">
            Hearth leverages the West <strong>Wyoming Decentralized Autonomous Organization Supplement</strong> (W.S. 17-31-104). The DAO is a "legal person" capable of holding title. The "Manager" is defined as an algorithm (The Operator).
          </p>

          <h2 className="text-2xl font-bold mt-8 mb-4">5. Tokenomics (The Hearth Token)</h2>
          <p className="text-neutral-300 leading-relaxed mb-4">
            The <strong>HRTH</strong> token governs the protocol parameters (fees, new property acquisitions, agent upgrades). It captures value from the network's growth.
          </p>
          
          <h3 className="text-xl font-semibold text-neutral-200 mt-6 mb-2">Supply Distribution (Total: 1,000,000,000 HRTH)</h3>
          <ul className="list-disc pl-6 space-y-2 text-neutral-300 marker:text-orange-500 mb-6">
            <li><strong>40% - Community Sale (Fair Launch):</strong> Sold to raise Initial Property Capital.</li>
            <li><strong>20% - Team & Founders:</strong> Vested over 4 years (1 year cliff). Ensures long-term alignment.</li>
            <li><strong>20% - DAO Treasury:</strong> Reserved for future growth, liquidity mining, and emergency funds. Controlled by HRTH holders.</li>
            <li><strong>20% - Liquidity & Marketing:</strong> Initial DEX liquidity (Uniswap/Aerodrome) and growth campaigns.</li>
          </ul>

          <h3 className="text-xl font-semibold text-neutral-200 mt-6 mb-2">Value Accrual</h3>
          <ul className="list-disc pl-6 space-y-2 text-neutral-300 marker:text-orange-500">
            <li><strong>Protocol Fee (10%):</strong> A 10% fee is taken from the <em>Yield</em> of every property managed by Hearth.</li>
            <li><strong>Buyback & Burn:</strong> Protocol fees are used to buy back HRTH from the open market and burn it, creating deflationary pressure as the asset base grows.</li>
            <li><strong>Governance:</strong> HRTH holders vote on which properties to acquire next and managing the treasury.</li>
          </ul>

          <h2 className="text-2xl font-bold mt-8 mb-4">6. Roadmap</h2>
          <ul className="list-disc pl-6 space-y-2 text-neutral-300 marker:text-orange-500">
            <li><strong>Phase 0 (Q1 2026):</strong> LLC Formation, Genesis Contract Deployment, Whitepaper.</li>
            <li><strong>Phase 1 (Q2 2026):</strong> Community Token Sale, First Property Acquisition (Sedona, AZ).</li>
            <li><strong>Phase 2 (Q3 2026):</strong> Launch AI Operator "Vix", First Rental Income Distribution.</li>
            <li><strong>Phase 3 (2027):</strong> Network Expansion (10+ Properties), DAO-to-DAO lending.</li>
          </ul>
        </article>

        <div className="mt-12 pt-8 border-t border-neutral-800 text-center text-xs text-neutral-600">
          Disclaimer: This is a technical whitepaper, not financial advice. No token is being offered for sale at this time.
        </div>
      </div>
    </div>
  );
}
