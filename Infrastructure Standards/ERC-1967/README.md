# ERC-1967 Proxy Implementation

This project implements the [ERC-1967](https://eips.ethereum.org/EIPS/eip-1967) proxy pattern standard, enabling upgradeable smart contracts through a standardized storage slot system.

## Deployed Addresses (Sepolia)

The following contracts have been deployed to Sepolia testnet:

```
PROXY_ADDRESS=0x1b9A182FD159F788AAB095bf06fb60D7FFFE502B
IMPLEMENTATION_V1_ADDRESS=0x61eD5d91455A229f376A20C916118F1eDE7f286d
ADMIN_ADDRESS=0x39CA5312eF96cBF09c43ea7F2eAd639c539BF613
IMPLEMENTATION_V2_ADDRESS=0x15B728A70c71FbBC302F3aC38C94A8681DAda3Af
```

## Overview

ERC-1967 defines standard storage slots for proxy contracts, ensuring consistent storage patterns across different proxy implementations. This standardization is crucial for:

- Proxy contract interoperability
- Upgrade mechanism consistency
- Storage collision prevention
- Admin access control

### Key Features

1. **Standardized Storage Slots**
   - Implementation address: `0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc`
   - Admin address: `0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103`
   - Beacon address: `0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50`

2. **Transparent Proxy Pattern**
   - Separates admin and user functions
   - Prevents function selector clashing
   - Enables secure upgrades

3. **Access Control**
   - Admin-only upgrade functions
   - Protected initialization
   - Ownership management

## Contract Architecture

### Core Contracts

1. **ERC1967Proxy.sol**
   - Main proxy contract
   - Delegates calls to implementation
   - Manages upgrades

2. **ExampleImplementationV1.sol**
   - Initial implementation
   - Basic functionality
   - Version tracking

3. **ExampleImplementationV2.sol**
   - Upgraded implementation
   - Enhanced features
   - Backward compatibility

### Deployment Scripts

1. **Deploy.s.sol**
   - Deploys proxy and V1
   - Sets up admin
   - Initializes implementation

2. **Upgrade.s.sol**
   - Handles upgrades
   - Verifies admin
   - Manages state transitions

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd ERC-1967
```

2. Install Foundry dependencies:
```bash
forge install
```

3. Set up environment:
```bash
cp .env.example .env
```

4. Configure `.env` with:
```
PRIVATE_KEY=your_private_key
SEPOLIA_RPC_URL=your_rpc_url
ETHERSCAN_API_KEY=your_api_key
```

## Usage

### Initial Deployment

Deploy the proxy and first implementation:

```bash
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
```

### Upgrading

Upgrade to a new implementation:

```bash
forge script script/Upgrade.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify
```

### Verification

Verify contracts on Etherscan:

```bash
forge verify-contract $IMPLEMENTATION_V1_ADDRESS ExampleImplementationV1 --chain-id 11155111
forge verify-contract $PROXY_ADDRESS ERC1967Proxy --chain-id 11155111
```

## Testing

Run the complete test suite:

```bash
forge test
```

For detailed output:

```bash
forge test -vvv
```

For gas reporting:

```bash
forge test --gas-report
```

## Security Considerations

1. **Storage Collisions**
   - Use standardized slots
   - Avoid direct storage access
   - Follow upgrade patterns

2. **Access Control**
   - Verify admin rights
   - Secure upgrade process
   - Monitor ownership

3. **Upgrade Safety**
   - Test migrations
   - Verify state preservation
   - Check compatibility

## License

MIT
