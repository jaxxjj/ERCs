# ERC-4626: Tokenized Vault Standard

## Overview

ERC-4626 is the Tokenized Vault Standard, providing a standardized API for yield-bearing vaults. It extends ERC-20 to create a robust standard for yield-generating token vaults, significantly improving composability in DeFi protocols.

## Key Features

- **Standardized API**: Unified interface for deposit/withdrawal operations
- **Asset/Share Accounting**: Precise conversion between vault shares and underlying assets
- **Yield Distribution**: Automated yield accrual to vault shareholders
- **ERC-20 Compatibility**: Full compatibility with existing token infrastructure
- **Composability**: Easy integration with other DeFi protocols

## Architecture

### Core Components

#### Vault Interface
```solidity
interface IERC4626 is IERC20 {
    function asset() external view returns (address);
    function totalAssets() external view returns (uint256);
    function convertToShares(uint256 assets) external view returns (uint256);
    function convertToAssets(uint256 shares) external view returns (uint256);
    function maxDeposit(address receiver) external view returns (uint256);
    function maxMint(address receiver) external view returns (uint256);
    function maxWithdraw(address owner) external view returns (uint256);
    function maxRedeem(address owner) external view returns (uint256);
}
```

### Key Functions

1. **Deposit/Mint**
```solidity
function deposit(uint256 assets, address receiver) external returns (uint256 shares);
function mint(uint256 shares, address receiver) external returns (uint256 assets);
```

2. **Withdraw/Redeem**
```solidity
function withdraw(uint256 assets, address receiver, address owner) external returns (uint256 shares);
function redeem(uint256 shares, address receiver, address owner) external returns (uint256 assets);
```

## Implementation Guide

### 1. Basic Vault Setup
```solidity
contract MyVault is ERC4626 {
    constructor(
        ERC20 _asset,
        string memory _name,
        string memory _symbol
    ) ERC4626(_asset) ERC20(_name, _symbol) {}
}
```

### 2. Asset Management
```solidity
function totalAssets() public view override returns (uint256) {
    return asset.balanceOf(address(this)) + _externalBalance();
}

function _externalBalance() internal view returns (uint256) {
    // Add protocol-specific external balance calculation
}
```

## Security Considerations

1. **Rounding Protection**
   - Implement proper rounding for share/asset conversions
   - Use consistent rounding direction
   - Handle dust amounts safely

2. **Slippage Control**
   - Implement deposit/withdrawal limits
   - Add slippage protection parameters
   - Monitor for sandwich attacks

3. **Access Control**
   - Implement proper role management
   - Secure admin functions
   - Emergency pause mechanisms

## Development

### Setup
```bash
# Clone repository
git clone <repository>

# Install dependencies
forge install
```

### Configuration
```bash
# Copy environment file
cp .env.example .env

# Set required variables
ETHERSCAN_API_KEY=your_api_key
RPC_URL=your_rpc_url
PRIVATE_KEY=your_private_key
```

### Testing

```bash
# Run all tests
forge test

# Run with gas reporting
forge test --gas-report

# Run specific test
forge test --match-test testDepositWithdraw
```

### Deployment

```bash
# Deploy to local network
forge script scripts/Deploy.s.sol --broadcast

# Deploy to testnet
forge script scripts/Deploy.s.sol --rpc-url $TESTNET_RPC_URL --broadcast
```

## Integration Examples

### 1. Basic Deposit
```solidity
// Approve vault to spend tokens
asset.approve(address(vault), amount);

// Deposit assets
vault.deposit(amount, receiver);
```

### 2. Share Redemption
```solidity
// Calculate assets to receive
uint256 assets = vault.convertToAssets(shares);

// Redeem shares
vault.redeem(shares, receiver, owner);
```

## Best Practices

1. **Asset Handling**
   - Validate asset transfers
   - Handle token decimals correctly
   - Implement proper rounding

2. **Share Management**
   - Maintain accurate share/asset ratios
   - Handle edge cases (e.g., first deposit)
   - Implement share limits

3. **Testing**
   - Test all vault operations
   - Verify share/asset conversions
   - Test edge cases
   - Fuzz testing for conversion functions

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Submit pull request

## Resources

- [EIP-4626 Specification](https://eips.ethereum.org/EIPS/eip-4626)
- [OpenZeppelin ERC4626](https://docs.openzeppelin.com/contracts/4.x/api/token/erc4626)
- [DeFi Integration Guide](https://ethereum.org/en/defi/)

## License

MIT License - see LICENSE.md 