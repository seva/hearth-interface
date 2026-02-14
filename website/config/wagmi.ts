import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { baseSepolia, hardhat } from 'wagmi/chains';

export const config = getDefaultConfig({
  appName: 'Hearth Protocol',
  projectId: '3fbb6bba6f1de962d911bb5b5c9dbaef', // Public testing ID, replace purely for prod
  chains: [hardhat, baseSepolia],
  ssr: true,
});
