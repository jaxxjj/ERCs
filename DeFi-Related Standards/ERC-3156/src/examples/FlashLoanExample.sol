// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./FlashLender.sol";
import "./ArbitrageFlashBorrower.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FlashLoanExample {
    FlashLender public lender;
    ArbitrageFlashBorrower public borrower;
    IERC20 public token;

    constructor(address _token) {
        // Create array with single token
        address[] memory tokens = new address[](1);
        tokens[0] = _token;
        
        // Deploy lender with supported token
        lender = new FlashLender(tokens);
        
        // Deploy borrower with lender address and mock DEX pairs
        borrower = new ArbitrageFlashBorrower(
            address(lender),
            address(0), // Replace with actual DEX pair A
            address(0)  // Replace with actual DEX pair B
        );

        token = IERC20(_token);
    }

    /**
     * @dev Example of setting up and executing a flash loan
     */
    function executeExample(uint256 amount) external {
        // First, transfer some tokens to the lender
        require(token.transferFrom(msg.sender, address(lender), amount * 2), "Transfer failed");

        // Execute flash loan through borrower
        borrower.executeArbitrage(address(token), amount);

        // Check results
        uint256 borrowerBalance = token.balanceOf(address(borrower));
        require(borrowerBalance > 0, "Arbitrage failed");

        // Withdraw profits
        borrower.withdraw(address(token));
    }
}