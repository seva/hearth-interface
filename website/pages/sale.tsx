import { useState, useEffect } from 'react';
import Head from 'next/head';
import { ethers } from 'ethers';

// Configuration
const CROWDSALE_ADDR = "0xef990083409741011b6ed280a1519D75De8F8012";
const USDC_ADDR = "0x036CbD53842c5426634e7929541eC2318f3dCF7e";
// Base Sepolia Chain ID: 84532
const CHAIN_ID = 84532; 

const CROWDSALE_ABI = [
  "function rate() view returns (uint256)",
  "function buyTokens(uint256 usdcAmount) external",
  "function token() view returns (address)"
];

const ERC20_ABI = [
  "function balanceOf(address owner) view returns (uint256)",
  "function approve(address spender, uint256 amount) external returns (bool)",
  "function allowance(address owner, address spender) view returns (uint256)",
  "function decimals() view returns (uint8)"
];

export default function Sale() {
  const [account, setAccount] = useState<string | null>(null);
  const [balance, setBalance] = useState<string>("0"); // USDC
  const [tokenBalance, setTokenBalance] = useState<string>("0"); // HRTH
  const [rate, setRate] = useState<bigint>(0n);
  const [inputUSDC, setInputUSDC] = useState<string>("");
  const [status, setStatus] = useState<string>("");
  const [loading, setLoading] = useState<boolean>(false);

  // Connect Wallet
  async function connect() {
    if (typeof (window as any).ethereum === 'undefined') return alert("No Wallet Found");
    try {
      const provider = new ethers.BrowserProvider((window as any).ethereum);
      const accounts = await provider.send("eth_requestAccounts", []);
      setAccount(accounts[0]);
      checkChain(provider);
    } catch (e: any) {
      console.error(e);
      setStatus("Connection failed: " + e.message);
    }
  }

  async function checkChain(provider: ethers.BrowserProvider) {
    const network = await provider.getNetwork();
    if (Number(network.chainId) !== CHAIN_ID) {
      setStatus("Wrong Network! Please switch to Base Sepolia.");
      try {
        await (window as any).ethereum.request({
          method: 'wallet_switchEthereumChain',
          params: [{ chainId: '0x14A34' }], // 84532
        });
      } catch (e) {
        console.error(e);
      }
    }
  }

  // Load Data
  useEffect(() => {
    if (!account) return;
    refreshData();
  }, [account]);

  async function refreshData() {
    try {
      const provider = new ethers.BrowserProvider((window as any).ethereum);
      const signer = await provider.getSigner();
      
      const usdc = new ethers.Contract(USDC_ADDR, ERC20_ABI, signer);
      const crowdsale = new ethers.Contract(CROWDSALE_ADDR, CROWDSALE_ABI, signer);
      const tokenAddr = await crowdsale.token();
      const token = new ethers.Contract(tokenAddr, ERC20_ABI, signer);

      const bal = await usdc.balanceOf(account);
      setBalance(ethers.formatUnits(bal, 6)); // USDC 6 decimals

      const tBal = await token.balanceOf(account);
      setTokenBalance(ethers.formatEther(tBal)); // HRTH 18 decimals

      const r = await crowdsale.rate();
      setRate(r);
    } catch (e: any) {
      console.error(e);
      setStatus("Error loading data: " + e.message);
    }
  }

  async function handleBuy() {
    if (!account || !inputUSDC) return;
    setStatus("Processing...");
    setLoading(true);
    
    try {
      const provider = new ethers.BrowserProvider((window as any).ethereum);
      const signer = await provider.getSigner();
      const usdc = new ethers.Contract(USDC_ADDR, ERC20_ABI, signer);
      const crowdsale = new ethers.Contract(CROWDSALE_ADDR, CROWDSALE_ABI, signer);

      const amount = ethers.parseUnits(inputUSDC, 6);
      
      // 1. Check Allowance
      const allowance = await usdc.allowance(account, CROWDSALE_ADDR);
      if (allowance < amount) {
        setStatus("Approving USDC...");
        const txApprove = await usdc.approve(CROWDSALE_ADDR, amount);
        await txApprove.wait();
        setStatus("Approved! Buying now...");
      }

      // 2. Buy
      const txBuy = await crowdsale.buyTokens(amount);
      setStatus(`Transaction Sent: ${txBuy.hash}`);
      await txBuy.wait();
      
      setStatus("Purchase Successful!");
      setInputUSDC("");
      refreshData();
    } catch (e: any) {
      console.error(e);
      setStatus("Failed: " + e.message);
    } finally {
      setLoading(false);
    }
  }

  // Conversion Preview
  const previewAmount = inputUSDC && rate 
    ? (Number(inputUSDC) * Number(ethers.formatUnits(rate, 12))).toFixed(2) // Rate is 1e13, but converting USDC(6) to Token(18) logic is handled on contract.
    // rate is tokens per usdc unit.
    // 1 USDC (1e6) * Rate = Output.
    // If rate = 1e13. 1e6 * 1e13 = 1e19 (10 tokens).
    // So visual rate is Rate / 1e12 = 10.
    : "0";

  return (
    <div className="min-h-screen bg-neutral-900 text-neutral-100 font-sans flex flex-col items-center py-20 px-4">
      <Head><title>Presale | Hearth DAO</title></Head>
      
      <div className="max-w-md w-full bg-neutral-800 p-8 rounded-xl border border-neutral-700 shadow-xl">
        <h1 className="text-3xl font-bold text-center mb-6 bg-clip-text text-transparent bg-gradient-to-r from-orange-400 to-red-600">
          Token Presale
        </h1>

        {!account ? (
          <button 
            onClick={connect}
            className="w-full py-4 bg-white text-black font-bold rounded hover:bg-neutral-200 transition"
          >
            Connect Wallet
          </button>
        ) : (
          <div className="space-y-6">
            <div className="flex justify-between text-sm text-neutral-400">
              <span>Account:</span>
              <span className="font-mono text-white">{account.slice(0,6)}...{account.slice(-4)}</span>
            </div>
            
            <div className="bg-neutral-900 p-4 rounded border border-neutral-700">
              <div className="flex justify-between mb-2">
                <span className="text-neutral-500">Your Balance</span>
                <span>{Number(balance).toFixed(2)} USDC</span>
              </div>
              <div className="flex justify-between">
                <span className="text-neutral-500">Hearth Holdings</span>
                <span className="text-orange-400 font-bold">{Number(tokenBalance).toFixed(2)} HRTH</span>
              </div>
            </div>

            <div>
              <label className="block text-sm text-neutral-400 mb-2">Buy Amount (USDC)</label>
              <input 
                type="number" 
                value={inputUSDC}
                onChange={(e) => setInputUSDC(e.target.value)}
                className="w-full p-4 bg-neutral-900 border border-neutral-700 rounded text-white focus:border-orange-500 outline-none transition"
                placeholder="100"
              />
              <p className="text-right text-sm text-neutral-500 mt-2">
                Recieve: <span className="text-white">{previewAmount} HRTH</span>
              </p>
            </div>

            <button 
              onClick={handleBuy}
              disabled={loading || !inputUSDC}
              className={`w-full py-4 font-bold rounded transition ${
                loading ? 'bg-neutral-600 cursor-not-allowed' : 'bg-orange-500 hover:bg-orange-600 text-white'
              }`}
            >
              {loading ? "Processing..." : "Buy Details"}
            </button>

            {status && (
              <div className="p-4 bg-neutral-900/50 rounded border border-neutral-700 text-xs text-center font-mono break-all">
                {status}
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
