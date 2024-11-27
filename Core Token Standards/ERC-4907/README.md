# ERC-4907: Rental NFT Standard

ERC-4907 is a standard for implementing rentable NFTs on the Ethereum blockchain. It extends ERC-721 by adding a "user" role that can be granted temporarily, making it perfect for NFT rental use cases.

## Key Features

1. **Dual Roles**: 
   - **Owner**: Has full rights to the NFT (can sell, rent, or transfer)
   - **User**: Has temporary usage rights (cannot sell or transfer)

2. **Time-Based Access**:
   - User rights automatically expire at a specified timestamp
   - No manual revocation needed

## Core Functions

1. `setUser(uint256 tokenId, address user, uint64 expires)`
   - Sets the user and expiration time for an NFT
   - Only callable by token owner or approved address

2. `userOf(uint256 tokenId) → address`
   - Returns the current user of the NFT
   - Returns `address(0)` if no valid user or expired

3. `userExpires(uint256 tokenId) → uint256`
   - Returns when the current user's access expires

## Use Cases

1. **Gaming**:
   - Rent in-game items
   - Temporary character usage
   - Time-limited power-ups

2. **Real Estate**:
   - Digital property rental
   - Virtual land leasing
   - Timeshare representation

3. **Digital Services**:
   - Subscription-based access
   - Time-limited licenses
   - Service memberships

4. **Metaverse Assets**:
   - Virtual space rental
   - Avatar costume rental
   - Event ticket delegation

## Implementation Example

```solidity
contract GameItem is ERC4907 {
    constructor() ERC4907("GameItem", "GITM") {}

    function mint(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }

    function rentOut(uint256 tokenId, address renter, uint64 duration) external {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        uint64 expires = uint64(block.timestamp + duration);
        setUser(tokenId, renter, expires);
    }
}
```
## Deployment

### Sepolia (11155111)
- MyNFT deployed at: [0xC746C16197335D3D39334c353453d70654021865](https://sepolia.etherscan.io/address/0xC746C16197335D3D39334c353453d70654021865)

### Arbitrum Sepolia (421611)
- MyNFT deployed at: [0x43046be9c546C37d64675b85210Ff97597247Eaa](https://sepolia.arbiscan.io/address/0x43046be9c546C37d64675b85210Ff97597247Eaa)

### Base Sepolia (84632)
- MyNFT deployed at: [0x20806731D06A12B85e88209079beaB9391FA6687](https://sepolia.basescan.org/address/0x20806731D06A12B85e88209079beaB9391FA6687)

## Important Considerations

1. **Ownership vs Usage**:
   - Owner retains full ownership rights
   - User has temporary usage rights
   - Rights are clearly separated

2. **Automatic Expiration**:
   - No manual intervention needed
   - Rights expire based on timestamp
   - Clean and predictable behavior

3. **Gas Efficiency**:
   - Minimal storage overhead
   - Efficient rights management
   - Optimized for rental operations

4. **Security**:
   - Clear permission boundaries
   - Time-based access control
   - Automatic cleanup on transfer

## Events

1. `UpdateUser(uint256 indexed tokenId, address indexed user, uint64 expires)`
   - Emitted when user rights are updated
   - Tracks rental history and changes

## Resources

- [EIP-4907: Rental NFT Standard](https://eips.ethereum.org/EIPS/eip-4907)
- [ERC-721 Standard](https://eips.ethereum.org/EIPS/eip-721)