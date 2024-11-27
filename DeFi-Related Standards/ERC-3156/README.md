# ERC-3156: Flash Loan Standard

ERC-3156 is a standard for flash loans on the Ethereum blockchain. It provides a standardized way to implement flash loans, allowing protocols to borrow assets for the duration of a single transaction, provided they pay back the loan plus any fees before the transaction ends.

## Key Functions

1. `maxFlashLoan(address token) external view returns (uint256)`
   - Returns the maximum amount of tokens available for a flash loan.
   - Used to check liquidity before attempting a loan.

2. `flashFee(address token, uint256 amount) external view returns (uint256)`
   - Returns the fee required for a flash loan of the specified amount.
   - Allows borrowers to calculate costs upfront.

3. `flashLoan(IERC3156FlashBorrower receiver, address token, uint256 amount, bytes calldata data) external returns (bool)`
   - Initiates a flash loan, transferring tokens to the receiver.
   - Executes the borrower's callback function.
   - Verifies loan repayment before completion.

4. `onFlashLoan(address initiator, address token, uint256 amount, uint256 fee, bytes calldata data) external returns (bytes32)`
   - Callback function implemented by borrowers.
   - Must return `keccak256("ERC3156FlashBorrower.onFlashLoan")` to confirm proper implementation.

## Implementation Example

```solidity
contract FlashLender is IERC3156FlashLender {
    bytes32 public constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");
    mapping(address => bool) public supportedTokens;
    uint256 public fee; // 0.1% = 100

    constructor(address[] memory tokens) {
        for (uint256 i = 0; i < tokens.length; i++) {
            supportedTokens[tokens[i]] = true;
        }
    }

    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool) {
        require(supportedTokens[token], "Token not supported");
        
        uint256 fee = flashFee(token, amount);
        IERC20(token).transfer(address(receiver), amount);
        
        require(
            receiver.onFlashLoan(msg.sender, token, amount, fee, data) == CALLBACK_SUCCESS,
            "Invalid callback return"
        );
        
        require(
            IERC20(token).transferFrom(address(receiver), address(this), amount + fee),
            "Repayment failed"
        );
        
        return true;
    }
}
```

## Use Cases

1. **Arbitrage Trading**
   - Execute trades across multiple DEXs to profit from price differences.
   - Borrow large amounts to maximize arbitrage opportunities.
   ```solidity
   contract ArbitrageFlashBorrower is IERC3156FlashBorrower {
       function executeArbitrage(address token, uint256 amount) external {
           // Borrow tokens
           lender.flashLoan(this, token, amount, "");
           // Arbitrage logic executed in onFlashLoan
       }
   }
   ```

2. **Collateral Swaps**
   - Replace collateral in lending protocols without closing positions.
   - Optimize interest rates and liquidation risks.

3. **Liquidations**
   - Access capital to liquidate underwater positions.
   - Profit from liquidation bonuses without capital lock-up.

4. **Self-Liquidation**
   - Users can liquidate their own positions to avoid penalties.
   - Maintain better control over collateral recovery.

## Important Considerations

1. **Security**
   - Always implement reentrancy guards
   - Verify return values from token transfers
   - Check for proper callback responses
   - Validate loan amounts and fees

2. **Gas Optimization**
   - Minimize storage operations during flash loans
   - Batch operations when possible
   - Consider gas costs in fee calculations

3. **Error Handling**
   - Implement proper revert messages
   - Handle failed transfers gracefully
   - Consider edge cases in token implementations

4. **Testing**
   - Test with various token implementations
   - Verify fee calculations
   - Simulate failed scenarios
   - Check gas consumption

## Testing

```shell
# Run all tests
forge test

# Run specific test file
forge test --match-path test/FlashLoan.t.sol

# Run with gas reporting
forge test --gas-report
```

## Resources

- [EIP-3156: Flash Loans](https://eips.ethereum.org/EIPS/eip-3156)
- [OpenZeppelin ERC3156 Implementation](https://docs.openzeppelin.com/contracts/4.x/api/interfaces#IERC3156FlashLender)
- [Flash Loans Documentation](https://docs.aave.com/developers/guides/flash-loans)
- [DeFi Flash Loan Guide](https://ethereum.org/en/defi/#flash-loans)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
