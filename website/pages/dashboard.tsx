import { ConnectButton } from '@rainbow-me/rainbowkit';
import { useAccount, useReadContract, useWriteContract } from 'wagmi';
import { addresses } from '../constants/addresses.json'; // We need to import the JSON properly or type it
import { HearthTokenABI, HearthGovernorABI } from '../constants/abis';
import { useState } from 'react';
import { parseEther } from 'viem';

// Workaround for importing JSON directly in Next.js without issues in some setups:
// (Usually fine, but let's assume we import the file we copied earlier)
import deployedAddresses from '../constants/addresses.json';

const CONTRACTS = deployedAddresses;

export default function Dashboard() {
  const { address } = useAccount();
  
  // State for Proposal
  const [description, setDescription] = useState("Proposal #1");

  // Read: Token Balance
  const { data: balance } = useReadContract({
    address: CONTRACTS.HearthToken as `0x${string}`,
    abi: HearthTokenABI,
    functionName: 'balanceOf',
    args: [address || '0x0000000000000000000000000000000000000000'],
  });

  // Read: Voting Power
  const { data: votes } = useReadContract({
    address: CONTRACTS.HearthToken as `0x${string}`,
    abi: HearthTokenABI,
    functionName: 'getVotes',
    args: [address || '0x0000000000000000000000000000000000000000'],
  });

  // Write: Delegate
  const { writeContract: delegate } = useWriteContract();
  
  // Write: Propose
  const { writeContract: propose } = useWriteContract();

  return (
    <div className="min-h-screen bg-neutral-900 text-neutral-100 p-8 font-sans">
      <header className="flex justify-between items-center mb-12">
        <h1 className="text-3xl font-bold">Governance Dashboard</h1>
        <ConnectButton />
      </header>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        
        {/* Your Stats */}
        <div className="p-6 bg-neutral-800 rounded-xl border border-neutral-700">
          <h2 className="text-xl font-bold mb-4">Your Power</h2>
          <div className="space-y-2">
            <p><strong>Balance:</strong> {balance?.toString()} HTH</p>
            <p><strong>Votes:</strong> {votes?.toString()} Votes</p>
          </div>
          
          <div className="mt-6 flex gap-4">
            <button 
              onClick={() => delegate({ 
                address: CONTRACTS.HearthToken as `0x${string}`,
                abi: HearthTokenABI,
                functionName: 'delegate', 
                args: [address as `0x${string}`] 
              })}
              className="px-4 py-2 bg-orange-600 rounded hover:bg-orange-500"
            >
              Self-Delegate
            </button>
          </div>
        </div>

        {/* Create Proposal */}
        <div className="p-6 bg-neutral-800 rounded-xl border border-neutral-700">
          <h2 className="text-xl font-bold mb-4">Create Proposal</h2>
          <textarea 
            className="w-full bg-neutral-900 border border-neutral-600 rounded p-2 mb-4"
            placeholder="Proposal Description"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
          />
          <button 
            onClick={() => propose({
              address: CONTRACTS.HearthGovernor as `0x${string}`,
              abi: HearthGovernorABI,
              functionName: 'propose',
              args: [
                [address as `0x${string}`], // Target: Self (just for testing)
                [0n], // Value
                ["0x"], // Calldata
                description // Description
              ]
            })}
            className="px-4 py-2 bg-neutral-100 text-neutral-900 font-bold rounded hover:bg-neutral-200"
          >
            Submit Proposal
          </button>
        </div>

      </div>
    </div>
  );
}
