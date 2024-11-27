# ERC-1155 Multi Token Standard

A comprehensive implementation of ERC-1155, the multi-token standard that enables managing multiple token types (both fungible and non-fungible) within a single smart contract.

## Overview

ERC-1155 introduces a novel token standard that combines the functionalities of ERC-20 and ERC-721, allowing for efficient management of multiple token types in one contract. This implementation provides a gas-efficient way to transfer multiple tokens simultaneously through batch operations.

### Key Features

- **Multi-Token Support**: Single contract manages multiple token types
- **Batch Operations**: Transfer multiple tokens in one transaction
- **Semi-Fungible Tokens**: Support for both fungible and non-fungible tokens
- **Gas Efficiency**: Optimized for minimal gas consumption
- **Safe Transfer Guarantees**: Built-in safety checks for token transfers

### Core Functions

#### Balance Management
- `balanceOf(address account, uint256 id)`: Get balance of an account for a token ID
- `balanceOfBatch(address[] accounts, uint256[] ids)`: Get balances for multiple account/token pairs

#### Transfer Operations
- `safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes data)`: Transfer single token type
- `safeBatchTransferFrom(address from, address to, uint256[] ids, uint256[] amounts, bytes data)`: Transfer multiple token types

#### Approval Management
- `setApprovalForAll(address operator, bool approved)`: Enable/disable operator for all tokens
- `isApprovedForAll(address account, address operator)`: Check if operator is approved

#### Metadata
- `uri(uint256 id)`: Get metadata URI for token type

### Use Cases

1. **Gaming Assets**
   - In-game items
   - Character attributes
   - Resource tokens

2. **Digital Collections**
   - Mixed media assets
   - Tiered membership tokens
   - Limited edition items

3. **DeFi Applications**
   - Multi-token liquidity pools
   - Hybrid financial instruments
   - Tokenized asset baskets

4. **Marketplace Integration**
   - Batch trading
   - Bundle sales
   - Collection management

## Deployments

### Sepolia (11155111)
- MyToken deployed at: [0x5f9E2a2Ac273da2a89A83c1919bE463586028B20](https://sepolia.etherscan.io/address/0x5f9E2a2Ac273da2a89A83c1919bE463586028B20)

### Arbitrum Sepolia (421611)
- MyToken deployed at: [0x65b00a88302cCED57B8B0b30a50AEdc264C0216d](https://sepolia.arbiscan.io/address/0x65b00a88302cCED57B8B0b30a50AEdc264C0216d)

### Base Sepolia (84632)
- MyToken deployed at: [0x07c1E784542c3b3B33f2fD2bdc8d0a55b29531a0](https://sepolia.basescan.org/address/0x07c1E784542c3b3B33f2fD2bdc8d0a55b29531a0)

## License

MIT
