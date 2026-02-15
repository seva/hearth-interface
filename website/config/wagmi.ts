import { base, baseSepolia } from 'viem/chains';
import { createConfig, http } from 'wagmi';
import { getDefaultConfig, RainbowKitProvider } from '@rainbow-me/rainbowkit';

export const config = createConfig(
  getDefaultConfig({
    appName: 'My App',
    projectId: process.env.NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID,
    chains: [base, baseSepolia],
    transports: {
      [base.id]: http(),
      [baseSepolia.id]: http(),
    },
  })
);