# ERC-777 Token Standard Implementation

## Overview

ERC-777 is an advanced token standard that extends ERC-20 functionality while maintaining backward compatibility. It introduces powerful features through hooks - callbacks that execute during token transfers, enabling sophisticated token behaviors and controls.

## Key Features

- **Hooks**: Pre and post-transfer execution
- **Operators**: Authorized accounts that can move tokens
- **ERC-20 Compatibility**: Works with existing ERC-20 infrastructure
- **Data Field**: Attach metadata to transfers
- **Token Control**: Reject unwanted transfers

## Deployment

Sepolia (11155111): 
- MyNFT deployed at: [0xA10B82f101b2724B8e79Db97cB00A900E44FE8D2](https://sepolia.etherscan.io/address/0xA10B82f101b2724B8e79Db97cB00A900E44FE8D2)

Arbitrum sepolia (421611):
- MyNFT deployed at: [0xC764FDc0A76d8074DC848d55824f1B24A7568D58](https://sepolia.arbiscan.io/address/0xC764FDc0A76d8074DC848d55824f1B24A7568D58)

Base sepolia (84632):
- MyNFT deployed at: [0xBc2e2A0b54F128118C3886ef2045e6982822719b](https://sepolia.basescan.org/address/0xBc2e2A0b54F128118C3886ef2045e6982822719b)

### Hook System

#### TokenSender Hook
```solidity
interface IERC777Sender {
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}
```

- Executes before tokens leave an address
- Can validate or prepare for transfers
- Ability to reject transfers
- Common uses: Transfer limits, whitelisting

#### TokenRecipient Hook
```solidity
interface IERC777Recipient {
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;
}
```

- Executes after tokens arrive
- Can process received tokens
- Must complete successfully
- Common uses: Accounting, notifications

## Implementation Examples

### 1. Basic Token
```solidity
contract MyToken is ERC777 {
    constructor(address[] memory operators) 
        ERC777("MyToken", "MTK", operators) {
        // Token initialization
    }
}
```

### 2. Transfer Limiter
```solidity
contract TransferLimiter is IERC777Sender {
    uint256 constant DAILY_LIMIT = 1000 * 1e18;
    
    function tokensToSend(...) external {
        require(amount <= DAILY_LIMIT, "Exceeds daily limit");
    }
}
```

### 3. Escrow Recipient
```solidity
contract EscrowRecipient is IERC777Recipient {
    mapping(address => uint256) public held;
    
    function tokensReceived(...) external {
        held[from] += amount;
    }
}
```

## Security Considerations

### 1. ERC1820 Registry
- **Required**: Must register implementations
- **Verification**: Check registration status
- **Updates**: Handle implementation changes

### 2. Reentrancy Protection
```solidity
contract SecureRecipient is IERC777Recipient {
    uint256 private _status;
    
    modifier nonReentrant() {
        require(_status == 0, "Reentrant call");
        _status = 1;
        _;
        _status = 0;
    }
    
    function tokensReceived(...) external nonReentrant {
        // Safe implementation
    }
}
```

### 3. Hook Validation
- Validate operator permissions
- Check transfer amounts
- Verify sender/recipient addresses
- Handle failed hook executions

## Testing

### Setup
```bash
# Install dependencies
forge install
```

### Run Tests
```bash
# Run all tests
forge test

# Run fork tests
forge test --fork-url $MAINNET_RPC_URL -vvv
```

### Test Coverage
```bash
forge coverage
```

## Development Guide

### 1. Installation
```bash
# Clone repository
git clone <repository>

# Install dependencies
forge install
```

### 2. Configuration
```bash
# Copy environment file
cp .env.example .env

# Set required variables
MAINNET_RPC_URL=your_rpc_url
```

### 3. Deployment
```bash
# Deploy to local network
forge script scripts/Deploy.s.sol --broadcast

# Deploy to testnet
forge script scripts/Deploy.s.sol --rpc-url $TESTNET_RPC_URL --broadcast
```

## Best Practices

1. **Hook Implementation**
   - Keep hooks lightweight
   - Implement proper security checks
   - Handle all edge cases
   - Add comprehensive events

2. **Operator Management**
   - Carefully control operator permissions
   - Implement operator revocation
   - Monitor operator activities
   - Regular permission audits

3. **Testing**
   - Test all hook scenarios
   - Verify ERC-20 compatibility
   - Check operator behaviors
   - Test failure cases

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Submit pull request

## License

MIT License - see LICENSE.md

## Resources

- [EIP-777 Specification](https://eips.ethereum.org/EIPS/eip-777)
- [ERC1820 Registry](https://eips.ethereum.org/EIPS/eip-1820)
- [OpenZeppelin Implementation](https://docs.openzeppelin.com/contracts/4.x/api/token/erc777)
