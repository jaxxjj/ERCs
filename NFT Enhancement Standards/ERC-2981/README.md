# ERC-2981: NFT Royalty Standard

ERC-2981 is a standard for NFT royalties on the Ethereum blockchain. It allows for the implementation of royalty payments to original creators or rights holders when NFTs are resold on the secondary market.

## Key Functions

1. `royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address receiver, uint256 royaltyAmount)`
   - Returns the royalty recipient and the royalty amount for a given token and sale price.

2. `supportsInterface(bytes4 interfaceId) public view virtual override returns (bool)`
   - Indicates if the contract implements the ERC-2981 interface.

## Use Cases

1. **Artist Royalties**: Artists can receive ongoing royalties from secondary sales of their digital artwork.

2. **Music Rights**: Musicians or record labels can earn royalties when music-related NFTs are resold.

3. **Game Item Creators**: Developers of in-game items can receive royalties when players trade these items as NFTs.

4. **Collectible Designers**: Creators of digital collectibles can earn from the ongoing popularity and trading of their designs.

5. **Charity Fundraising**: Organizations can create NFTs where a portion of each resale goes to a charitable cause.

## Implementation Example

```solidity
contract MyNFT is ERC721, ERC2981 {
    constructor() ERC721("MyNFT", "MNFT") {
        // Set a 2.5% royalty fee
        _setDefaultRoyalty(msg.sender, 250);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
```

## Deployment

Sepolia (11155111): 
- MyNFT deployed at: [0x28B0a75554337F91Ac7fDCa839Efef28a716c033](https://sepolia.etherscan.io/address/0x28B0a75554337F91Ac7fDCa839Efef28a716c033)

Arbitrum sepolia (421611):
- MyNFT deployed at: [0x4E4D62A88C9D14147d9fEb02CE3978b4D86509d1](https://sepolia.arbiscan.io/address/0x4E4D62A88C9D14147d9fEb02CE3978b4D86509d1)

Base sepolia (84632):
- MyNFT deployed at: [0x0fad00F2204ff3232760259bf8bC85be26B3F180](https://sepolia.basescan.org/address/0x0fad00F2204ff3232760259bf8bC85be26B3F180)

## Important Considerations

1. **Marketplace Support**: For royalties to be effective, NFT marketplaces must implement ERC-2981 support.

2. **Royalty Enforcement**: While ERC-2981 provides a standard way to express royalties, it doesn't enforce their payment. Compliance relies on marketplace implementation.

3. **Flexibility**: Royalties can be set differently for individual tokens or changed over time, depending on the implementation.

4. **Gas Efficiency**: ERC-2981 is designed to be gas-efficient, with minimal overhead for royalty calculations.

5. **Compatibility**: This standard is compatible with other ERC standards like ERC-721 and ERC-1155.

## Resources

- [EIP-2981: NFT Royalty Standard](https://eips.ethereum.org/EIPS/eip-2981)
- [OpenZeppelin ERC2981 Implementation](https://docs.openzeppelin.com/contracts/4.x/api/token/common#ERC2981)