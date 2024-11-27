// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../base/ERC721.sol";
import "../interfaces/IERC2981.sol";

contract ERC721Royalty is ERC721, IERC2981 {
    // Events
    event RoyaltySet(uint256 indexed tokenId, address indexed receiver, uint96 feeNumerator);
    event DefaultRoyaltySet(address indexed receiver, uint96 feeNumerator);

    // Errors
    error InvalidRoyaltyReceiver();
    error InvalidRoyaltyFraction();

    struct RoyaltyInfo {
        address receiver;
        uint96 royaltyFraction;
    }

    // Royalty fee denominator (10000 = 100%)
    uint96 private constant ROYALTY_FEE_DENOMINATOR = 10000;

    // Default royalty info for all tokens
    RoyaltyInfo private s_defaultRoyaltyInfo;
    
    // Token specific royalty overrides
    mapping(uint256 => RoyaltyInfo) private s_tokenRoyaltyInfo;

    constructor(
        string memory name_,
        string memory symbol_,
        address defaultRoyaltyReceiver,
        uint96 defaultRoyaltyFraction
    ) ERC721(name_, symbol_) {
        if (defaultRoyaltyReceiver == address(0)) revert InvalidRoyaltyReceiver();
        if (defaultRoyaltyFraction > ROYALTY_FEE_DENOMINATOR) revert InvalidRoyaltyFraction();
        
        s_defaultRoyaltyInfo = RoyaltyInfo(defaultRoyaltyReceiver, defaultRoyaltyFraction);
        emit DefaultRoyaltySet(defaultRoyaltyReceiver, defaultRoyaltyFraction);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override (ERC721, IERC165) returns (bool) {
        return interfaceId == type(IERC2981).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns the royalty info for a given token and sale price.
     */
    function royaltyInfo(
        uint256 tokenId,
        uint256 salePrice
    ) external view override returns (address, uint256) {
        require(_exists(tokenId), "ERC721Royalty: Query for nonexistent token");

        RoyaltyInfo memory royalty = s_tokenRoyaltyInfo[tokenId].receiver != address(0) 
            ? s_tokenRoyaltyInfo[tokenId]
            : s_defaultRoyaltyInfo;

        uint256 royaltyAmount = (salePrice * royalty.royaltyFraction) / ROYALTY_FEE_DENOMINATOR;
        return (royalty.receiver, royaltyAmount);
    }

    /**
     * @dev Sets token-specific royalty info.
     */
    function setTokenRoyalty(
        uint256 tokenId,
        address receiver,
        uint96 feeNumerator
    ) public virtual {
        require(_exists(tokenId), "ERC721Royalty: Query for nonexistent token");
        if (receiver == address(0)) revert InvalidRoyaltyReceiver();
        if (feeNumerator > ROYALTY_FEE_DENOMINATOR) revert InvalidRoyaltyFraction();

        s_tokenRoyaltyInfo[tokenId] = RoyaltyInfo(receiver, feeNumerator);
        emit RoyaltySet(tokenId, receiver, feeNumerator);
    }

    /**
     * @dev Sets default royalty info for all tokens.
     */
    function setDefaultRoyalty(
        address receiver,
        uint96 feeNumerator
    ) public virtual {
        if (receiver == address(0)) revert InvalidRoyaltyReceiver();
        if (feeNumerator > ROYALTY_FEE_DENOMINATOR) revert InvalidRoyaltyFraction();

        s_defaultRoyaltyInfo = RoyaltyInfo(receiver, feeNumerator);
        emit DefaultRoyaltySet(receiver, feeNumerator);
    }

    /**
     * @dev Resets token royalty info to use default.
     */
    function resetTokenRoyalty(uint256 tokenId) public virtual {
        require(_exists(tokenId), "ERC721Royalty: Query for nonexistent token");
        delete s_tokenRoyaltyInfo[tokenId];
    }

    /**
     * @dev Returns the current royalty info for a token.
     */
    function getTokenRoyaltyInfo(uint256 tokenId) public view returns (address, uint96) {
        require(_exists(tokenId), "ERC721Royalty: Query for nonexistent token");
        
        RoyaltyInfo memory royalty = s_tokenRoyaltyInfo[tokenId].receiver != address(0)
            ? s_tokenRoyaltyInfo[tokenId]
            : s_defaultRoyaltyInfo;

        return (royalty.receiver, royalty.royaltyFraction);
    }

    /**
     * @dev Returns the default royalty info.
     */
    function getDefaultRoyaltyInfo() public view returns (address, uint96) {
        return (s_defaultRoyaltyInfo.receiver, s_defaultRoyaltyInfo.royaltyFraction);
    }
}