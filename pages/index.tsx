// pages/index.tsx
import Head from 'next/head';
import Link from 'next/link';

export default function Home() {
  return (
    <div className="min-h-screen bg-neutral-900 text-neutral-100 font-sans">
      <Head>
        <title>Hearth Protocol | Autonomous Real Estate</title>
        <meta name="description" content="Hearth Protocol: Algorithmically managed real estate DAO. Zero-profit management, automated yield distribution." />
        <link rel="icon" href="/favicon.ico" />
      </Head>

      {/* Hero Section */}
      <main className="flex flex-col items-center justify-center min-h-[80vh] px-4 text-center">
        <h1 className="text-6xl font-bold tracking-tighter mb-4 bg-clip-text text-transparent bg-gradient-to-r from-orange-400 to-red-600">
          Hearth Protocol
        </h1>
        <p className="text-xl text-neutral-400 max-w-2xl mb-8">
          The first legally compliant, algorithmically managed Real Estate DAO.
          <br />
          <span className="text-orange-500 font-mono text-sm mt-2 block">ID: 2026-001894157 (Wyoming)</span>
        </p>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 mt-12 max-w-4xl w-full text-left">
          <Card 
            title="Zero-Touch Management" 
            desc="Operations governed by immutable smart contracts, not human landlords. No management fees." 
          />
          <Card 
            title="Sovereign Yield" 
            desc="Rental income flows directly to the treasury and is distributed algorithmically via USDC." 
          />
          <Card 
            title="Legal Compliance" 
            desc="Registered Wyoming DAO LLC. Bridging on-chain governance with real-world property deeds." 
          />
        </div>

        <div className="mt-16 flex gap-4">
          <Link href="/whitepaper" className="px-6 py-3 bg-neutral-100 text-neutral-900 font-bold rounded hover:bg-neutral-200 transition">
            Read Whitepaper
          </Link>
          <Link href="/contract" className="px-6 py-3 border border-neutral-700 rounded hover:border-orange-500 transition">
            View Contract
          </Link>
        </div>
      </main>

      <footer className="w-full border-t border-neutral-800 py-8 text-center text-neutral-500 text-sm">
        <p>© 2026 Hearth Protocol DAO LLC. All rights reserved.</p>
        <p className="mt-2">30 N Gould St, Ste N, Sheridan, WY 82801</p>
      </footer>
    </div>
  );
}

function Card({ title, desc }: { title: string; desc: string }) {
  return (
    <div className="p-6 border border-neutral-800 rounded bg-neutral-800/20 hover:border-orange-500/50 transition">
      <h3 className="text-lg font-semibold text-white mb-2">{title}</h3>
      <p className="text-neutral-400 text-sm">{desc}</p>
    </div>
  );
}
