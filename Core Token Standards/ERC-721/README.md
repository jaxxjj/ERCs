# ERC-721 Token Standard Implementation

This folder contains a reference implementation of the ERC-721 Non-Fungible Token Standard. ERC-721 is a standard interface for non-fungible tokens (NFTs), meaning each token has unique properties and is not interchangeable with other tokens.

## Overview

The ERC-721 standard provides core functionality to track and transfer NFTs. Each token represents a unique digital asset, with its own specific tokenId and metadata. This implementation includes:

- Full ERC-721 standard interface implementation
- Optional metadata extension (ERC-721Metadata)
- Optional enumeration extension (ERC-721Enumerable)
- Comprehensive test suite
- Gas-optimized operations

## Deployment

Sepolia (11155111): 
- MyNFT deployed at: [0x6A3df19B58D4e1652CAa5b0e3c546D6d9d2194cc](https://sepolia.etherscan.io/address/0x6A3df19B58D4e1652CAa5b0e3c546D6d9d2194cc)

Arbitrum sepolia (421611):
- MyNFT deployed at: [0xB98dA6123f052A427d4b82D313C07389B088f64F](https://sepolia.arbiscan.io/address/0xB98dA6123f052A427d4b82D313C07389B088f64F)

Base sepolia (84632):
- MyNFT deployed at: [0x4D02b24ccE4C047Ab2AEeC55b2a53c6820CC4274](https://sepolia.basescan.org/address/0x4D02b24ccE4C047Ab2AEeC55b2a53c6820CC4274)

## Key Features

- Unique token IDs for each NFT
- Safe transfer mechanisms with receiver validation
- Token metadata support (name, symbol, tokenURI)
- Owner and operator approval system
- Enumeration capabilities (optional)
- Gas-efficient implementations
- Thoroughly tested functionality

## Getting Started

### Prerequisites

- [Git](https://git-scm.com/)
- [Foundry](https://getfoundry.sh/)

### Installation

1. Clone the repository:

```bash
git clone <repository-url>
```

2. Install dependencies:

```bash
forge install
```

3. Copy the environment file:

```bash
cp .env.example .env
```

4. Configure your environment variables in `.env`:

```
ETHERSCAN_API_KEY=your_api_key
RPC_URL=your_rpc_url
PRIVATE_KEY=your_private_key
ANVIL_PRIVATE_KEY=your_anvil_private_key
```

### Testing

Run the test suite:

```bash
forge test
```

For detailed test output:

```bash
forge test -vvv
```

## Core Functions

### Basic Functionality
- `balanceOf(address owner)`: Get the number of NFTs owned by an address
- `ownerOf(uint256 tokenId)`: Get the owner of a specific token
- `safeTransferFrom(address from, address to, uint256 tokenId)`: Safely transfer ownership of a token
- `transferFrom(address from, address to, uint256 tokenId)`: Transfer ownership of a token
- `approve(address to, uint256 tokenId)`: Approve another address to transfer a token
- `getApproved(uint256 tokenId)`: Get the approved address for a token
- `setApprovalForAll(address operator, bool approved)`: Enable/disable operator to manage all caller's tokens
- `isApprovedForAll(address owner, address operator)`: Check if an address is an authorized operator

### Metadata Extension
- `name()`: Get the token collection name
- `symbol()`: Get the token collection symbol
- `tokenURI(uint256 tokenId)`: Get the metadata URI for a specific token

### Enumeration Extension
- `totalSupply()`: Get the total number of tokens
- `tokenByIndex(uint256 index)`: Get token ID by its position in global list
- `tokenOfOwnerByIndex(address owner, uint256 index)`: Get token ID by its position in owner's list

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.







