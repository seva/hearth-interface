import { ConnectButton } from '@rainbow-me/rainbowkit';
import { useCrowdsale } from '../hooks/useCrowdsale';
import { formatEther } from 'viem';

export default function Home() {
  const { rate, weiRaised, isLoading } = useCrowdsale();

  return (
    <div>
      <ConnectButton />
      
      {isLoading ? (
        <p>Loading crowdsale data...</p>
      ) : (
        <div>
          <p>Rate: {rate.data ? formatEther(rate.data) : 'N/A'} HRTH/USDC</p>
          <p>Raised: {weiRaised.data ? formatEther(weiRaised.data) : 'N/A'} USDC</p>
          <p>Contract Logic: Active</p>
        </div>
      )}
    </div>
  );
}