import { useReadContract } from 'wagmi';
import { CROWDSALE_ABI } from '../constants/abis';
import { HearthCrowdsale } from '../constants/addresses';

export function useCrowdsale() {
  const rate = useReadContract({
    abi: CROWDSALE_ABI,
    address: HearthCrowdsale,
    functionName: 'rate'
  });

  const wallet = useReadContract({
    abi: CROWDSALE_ABI,
    address: HearthCrowdsale,
    functionName: 'wallet'
  });

  const weiRaised = useReadContract({
    abi: CROWDSALE_ABI,
    address: HearthCrowdsale,
    functionName: 'weiRaised'
  });

  const token = useReadContract({
    abi: CROWDSALE_ABI,
    address: HearthCrowdsale,
    functionName: 'token'
  });

  const usdc = useReadContract({
    abi: CROWDSALE_ABI,
    address: HearthCrowdsale,
    functionName: 'usdc'
  });

  return {
    rate,
    wallet,
    weiRaised,
    token,
    usdc,
    isLoading: rate.isLoading || wallet.isLoading || weiRaised.isLoading || token.isLoading || usdc.isLoading
  };
}