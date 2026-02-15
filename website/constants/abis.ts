// HearthToken ABI (ERC20Votes)
export const HearthTokenABI = [
  { inputs: [], stateMutability: "nonpayable", type: "constructor" },
  { inputs: [], name: "delegate", outputs: [], stateMutability: "nonpayable", type: "function" },
  { inputs: [{ internalType: "address", name: "account", type: "address" }], name: "getVotes", outputs: [{ internalType: "uint256", name: "", type: "uint256" }], stateMutability: "view", type: "function" },
  { inputs: [{ internalType: "address", name: "account", type: "address" }], name: "balanceOf", outputs: [{ internalType: "uint256", name: "", type: "uint256" }], stateMutability: "view", type: "function" },
  { inputs: [{ internalType: "address", name: "to", type: "address" }, { internalType: "uint256", name: "value", type: "uint256" }], name: "transfer", outputs: [{ internalType: "bool", name: "", type: "bool" }], stateMutability: "nonpayable", type: "function" }
] as const;

// HearthGovernor ABI
export const HearthGovernorABI = [
  { inputs: [{ internalType: "address[]", name: "targets", type: "address[]" }, { internalType: "uint256[]", name: "values", type: "uint256[]" }, { internalType: "bytes[]", name: "calldatas", type: "bytes[]" }, { internalType: "string", name: "description", type: "string" }], name: "propose", outputs: [{ internalType: "uint256", name: "", type: "uint256" }], stateMutability: "nonpayable", type: "function" },
  { inputs: [{ internalType: "uint256", name: "proposalId", type: "uint256" }, { internalType: "uint8", name: "support", type: "uint8" }], name: "castVote", outputs: [{ internalType: "uint256", name: "", type: "uint256" }], stateMutability: "nonpayable", type: "function" },
  { inputs: [{ internalType: "uint256", name: "proposalId", type: "uint256" }], name: "state", outputs: [{ internalType: "uint8", name: "", type: "uint8" }], stateMutability: "view", type: "function" },
  { inputs: [{ internalType: "uint256", name: "proposalId", type: "uint256" }], name: "proposalVotes", outputs: [{ internalType: "uint256", name: "againstVotes", type: "uint256" }, { internalType: "uint256", name: "forVotes", type: "uint256" }, { internalType: "uint256", name: "abstainVotes", type: "uint256" }], stateMutability: "view", type: "function" }
] as const;

// HearthCrowdsale ABI
export const CROWDSALE_ABI = [
  { inputs: [], name: "rate", outputs: [{ internalType: "uint256", name: "", type: "uint256" }], stateMutability: "view", type: "function" },
  { inputs: [], name: "wallet", outputs: [{ internalType: "address", name: "", type: "address" }], stateMutability: "view", type: "function" },
  { inputs: [], name: "weiRaised", outputs: [{ internalType: "uint256", name: "", type: "uint256" }], stateMutability: "view", type: "function" },
  { inputs: [], name: "token", outputs: [{ internalType: "contract IERC20", name: "", type: "address" }], stateMutability: "view", type: "function" },
  { inputs: [], name: "usdc", outputs: [{ internalType: "contract IERC20", name: "", type: "address" }], stateMutability: "view", type: "function" }
] as const;
