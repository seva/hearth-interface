import Head from 'next/head';
import Link from 'next/link';

export default function Contract() {
  return (
    <div className="min-h-screen bg-neutral-900 text-neutral-100 font-sans flex flex-col items-center justify-center p-4 text-center">
      <Head>
        <title>Contracts | Hearth Protocol</title>
      </Head>

      <div className="bg-neutral-800/50 p-8 rounded-2xl border border-neutral-700 max-w-md w-full">
        <div className="w-16 h-16 bg-neutral-800 rounded-full flex items-center justify-center mx-auto mb-6 border border-neutral-700">
          <span className="text-2xl">🔒</span>
        </div>
        
        <h1 className="text-2xl font-bold mb-2">Contracts Pending</h1>
        <p className="text-neutral-400 mb-6">
          The Hearth Protocol smart contracts are currently under internal audit. Deployment to Base/Optimism Mainnet is scheduled for March 14, 2026.
        </p>

        <div className="space-y-3 text-left bg-neutral-900/50 p-4 rounded-lg border border-neutral-800 mb-8 font-mono text-sm">
          <div className="flex justify-between">
            <span className="text-neutral-500">Status:</span>
            <span className="text-orange-400">Pre-Deployment</span>
          </div>
          <div className="flex justify-between">
            <span className="text-neutral-500">Legal Deadline:</span>
            <span className="text-white">2026-03-14</span>
          </div>
          <div className="flex justify-between">
            <span className="text-neutral-500">Auditor:</span>
            <span className="text-white">Internal</span>
          </div>
        </div>

        <Link href="/" className="px-6 py-3 bg-neutral-100 text-neutral-900 font-bold rounded hover:bg-neutral-200 transition block w-full">
          Return Home
        </Link>
      </div>
    </div>
  );
}
