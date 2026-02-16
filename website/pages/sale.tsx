import Head from 'next/head';

export default function Sale() {
  return (
    <div className="min-h-screen bg-neutral-900 text-neutral-100 font-sans flex flex-col items-center py-20 px-4">
      <Head>
        <title>Token Sale | Hearth DAO</title>
      </Head>
      
      <div className="max-w-xl w-full bg-neutral-800 p-10 rounded-xl border border-neutral-700 shadow-2xl">
        <h1 className="text-4xl font-bold text-center mb-8 bg-clip-text text-transparent bg-gradient-to-r from-orange-400 to-red-600">
          HRTH Token Sale
        </h1>

        <div className="space-y-6 text-center">
          <p className="text-xl text-neutral-300">
            Hearth DAO has pivoted to a regulated capital raise to ensure institutional compliance and long-term stability.
          </p>
          
          <div className="bg-neutral-900 p-8 rounded-lg border border-orange-900/30">
            <h2 className="text-orange-400 font-bold text-lg mb-4 uppercase tracking-widest">
              Qualified Investors Only
            </h2>
            <p className="text-neutral-400 mb-6">
              HRTH tokens are not available for direct on-chain purchase at this time. 
              Participation is restricted to accredited investors through regulated crowdfunding platforms.
            </p>
            
            <div className="p-4 bg-orange-500/10 border border-orange-500/20 rounded font-medium text-orange-200">
              Hearth DAO is currently undergoing onboarding with SEC-regulated platforms (Securitize / Republic).
            </div>
          </div>

          <div className="pt-6">
            <p className="text-sm text-neutral-500 mb-4">
              Legacy Base Sepolia testnet holders can still view their holdings in supported wallets.
            </p>
            <a 
              href="mailto:contact@hearthdao.com"
              className="inline-block px-8 py-3 bg-neutral-700 hover:bg-neutral-600 text-white font-bold rounded transition"
            >
              Contact Support
            </a>
          </div>
        </div>
      </div>
      
      <p className="mt-12 text-neutral-600 text-xs max-w-lg text-center leading-relaxed">
        DISCLAIMER: This is not an offer to sell or a solicitation of an offer to buy any securities. 
        Any such offer or solicitation will be made only through definitive offering documents. 
        Investing in private placements involves a high degree of risk and is suitable only for sophisticated investors.
      </p>
    </div>
  );
}
