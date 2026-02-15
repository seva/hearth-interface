import React, { useState } from 'react';
import { useContractRead, useContractWrite, useAccount } from 'wagmi';
import { ERC20ABI } from '../constants/abis';
import { CROWDSALE_ABI } from '../constants/abis';

export const BuyWidget = () => {
  const [amount, setAmount] = useState<string>('');
  const [status, setStatus] = useState<string>('');
  const { address } = useAccount();

  // Read USDC allowance
  const { data: allowance } = useContractRead({
    address: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48', // USDC contract address
    abi: ERC20ABI,
    functionName: 'allowance',
    args: [address, '0x123...'], // Replace with crowdsale contract address
  });

  // Read USDC balance
  const { data: balance } = useContractRead({
    address: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48', // USDC contract address
    abi: ERC20ABI,
    functionName: 'balanceOf',
    args: [address],
  });

  // Approve USDC for crowdsale
  const { write: approve } = useContractWrite({
    address: '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48', // USDC contract address
    abi: ERC20ABI,
    functionName: 'approve',
    onSuccess: () => {
      setStatus('Approving...');
    },
    onError: (error) => {
      setStatus(`Error: ${error.message}`);
    },
  });

  // Buy tokens from crowdsale
  const { write: buyTokens } = useContractWrite({
    address: '0x123...', // Replace with crowdsale contract address
    abi: CROWDSALE_ABI,
    functionName: 'buyTokens',
    onSuccess: () => {
      setStatus('Buying...');
    },
    onError: (error) => {
      setStatus(`Error: ${error.message}`);
    },
  });

  const handleBuy = async () => {
    if (!amount || !address) return;
    const amountInWei = BigInt(parseFloat(amount) * 1e6); // USDC has 6 decimals

    // Check balance
    if (balance && balance < amountInWei) {
      setStatus('Insufficient USDC balance');
      return;
    }

    // Check allowance
    if (allowance && allowance < amountInWei) {
      approve({ args: ['0x123...', amountInWei] }); // Replace with crowdsale contract address
      return;
    }

    // Buy tokens
    buyTokens({ args: [amountInWei] });
  };

  return (
    <div>
      <h2>Buy Tokens</h2>
      <input
        type="number"
        value={amount}
        onChange={(e) => setAmount(e.target.value)}
        placeholder="USDC Amount"
      />
      <button onClick={handleBuy}>Buy</button>
      {status && <p>{status}</p>}
    </div>
  );
};