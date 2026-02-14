// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract HearthCrowdsale is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public token;
    IERC20 public usdc;
    uint256 public rate; // Tokens per USDC unit (watch out for decimals!)

    event TokensPurchased(address indexed purchaser, uint256 amountUSDC, uint256 amountTokens);
    event RateUpdated(uint256 newRate);
    event FundsWithdrawn(address indexed token, uint256 amount);

    constructor(
        address initialOwner,
        address _token,
        address _usdc,
        uint256 _rate
    ) Ownable(initialOwner) {
        require(_token != address(0), "Token is zero address");
        require(_usdc != address(0), "USDC is zero address");
        require(_rate > 0, "Rate is zero");
        
        token = IERC20(_token);
        usdc = IERC20(_usdc);
        rate = _rate;
    }

    // Buy tokens with USDC
    function buyTokens(uint256 usdcAmount) external nonReentrant {
        require(usdcAmount > 0, "Amount is zero");
        
        // Calculate token amount
        // Example: USDC (6 dec), Hearth (18 dec). Rate = 1e12 (for 1:1).
        // 1 USDC (1e6) * 1e12 = 1e18 Hearth.
        uint256 tokenAmount = usdcAmount * rate;
        
        require(token.balanceOf(address(this)) >= tokenAmount, "Insufficient tokens in contract");

        // Transfer USDC from user to this contract
        usdc.safeTransferFrom(msg.sender, address(this), usdcAmount);

        // Transfer Tokens to user
        token.safeTransfer(msg.sender, tokenAmount);

        emit TokensPurchased(msg.sender, usdcAmount, tokenAmount);
    }

    // Owner functions
    function setRate(uint256 _rate) external onlyOwner {
        require(_rate > 0, "Rate is zero");
        rate = _rate;
        emit RateUpdated(_rate);
    }

    function withdrawToken(address _tokenAddress, uint256 _amount) external onlyOwner {
        IERC20(_tokenAddress).safeTransfer(owner(), _amount);
        emit FundsWithdrawn(_tokenAddress, _amount);
    }
}
