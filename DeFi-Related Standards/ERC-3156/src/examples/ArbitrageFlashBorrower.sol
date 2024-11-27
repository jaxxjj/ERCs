// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../base/ERC3156.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IDEXPair {
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
}

/**
 * @title Example Arbitrage Flash Borrower
 * @dev Example implementation of ERC3156 Flash Borrower for arbitrage
 */
contract ArbitrageFlashBorrower is ERC3156FlashBorrower {
    address public owner;
    IERC3156FlashLender public lender;
    
    // DEX pair contracts for arbitrage
    IDEXPair public dexPairA;
    IDEXPair public dexPairB;

    constructor(
        address _lender,
        address _dexPairA,
        address _dexPairB
    ) {
        owner = msg.sender;
        lender = IERC3156FlashLender(_lender);
        dexPairA = IDEXPair(_dexPairA);
        dexPairB = IDEXPair(_dexPairB);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /**
     * @dev Initiate a flash loan for arbitrage
     * @param token The token to borrow
     * @param amount The amount to borrow
     */
    function executeArbitrage(
        address token,
        uint256 amount
    ) external onlyOwner {
        // Prepare the data for the flash loan
        bytes memory data = abi.encode(token);

        // Execute flash loan
        lender.flashLoan(
            IERC3156FlashBorrower(address(this)),
            token,
            amount,
            data
        );
    }

    /**
     * @dev Handle the flash loan
     * This is where the arbitrage logic goes
     */
    function _handleFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) internal override {
        // Approve DEX pairs to spend tokens
        IERC20(token).approve(address(dexPairA), amount);
        IERC20(token).approve(address(dexPairB), amount);

        // Execute arbitrage trades
        // Example: Swap on DEX A
        dexPairA.swap(amount, 0, address(this), "");
        
        // Example: Swap back on DEX B
        dexPairB.swap(0, amount, address(this), "");

        // Approve lender to take repayment
        IERC20(token).approve(address(lender), amount + fee);
    }

    /**
     * @dev Withdraw tokens from the contract
     */
    function withdraw(address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(IERC20(token).transfer(owner, balance), "Transfer failed");
    }
}