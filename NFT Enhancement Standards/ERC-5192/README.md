# ERC-5192: Minimal Soulbound NFTs

A minimal implementation of soulbound tokens (SBTs) following the ERC-5192 standard.

## Overview

ERC-5192 is a minimal extension on top of ERC-721 that adds a "soulbound" property to NFTs, meaning they cannot be transferred once minted. This makes them suitable for representing non-transferable assets like credentials, memberships, and certifications.

## Features

- Implements the ERC-5192 interface for soulbound tokens
- Built on top of ERC-721 for NFT compatibility 
- Tokens are permanently locked after minting
- Includes membership validity tracking
- Role-based access control for minting and management

## Contracts

### SoulboundMembership.sol

Main implementation of the ERC-5192 standard that adds membership functionality:

- Minting of soulbound membership tokens
- Membership validity tracking
- Admin controls for issuing and revoking memberships
- Automatic locking of tokens after minting

## Usage

```solidity
// Create a new membership token
SoulboundMembership membership = new SoulboundMembership("Name", "SYMBOL");

// Issue a membership to an address
membership.issueMembership(address recipient, uint256 validUntil);

// Check if a membership is valid
bool isValid = membership.isMembershipValid(uint256 tokenId);

// Get membership details
(address owner, uint256 validUntil) = membership.getMembershipDetails(uint256 tokenId);
```

## Testing

The contracts include a comprehensive test suite. To run the tests:

```bash
forge test
```

## Gas Usage

Key functions gas costs:

- issueMembership: ~163k gas
- renewMembership: ~27k gas  
- getMembershipDetails: ~1.7k gas
- isMembershipValid: ~0.7k gas

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Resources

- [ERC-5192 Standard](https://eips.ethereum.org/EIPS/eip-5192)
- [ERC-721 Standard](https://eips.ethereum.org/EIPS/eip-721)
