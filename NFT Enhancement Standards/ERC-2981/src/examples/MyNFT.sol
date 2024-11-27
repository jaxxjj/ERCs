// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../base/ERC721Royalty.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721Royalty, Ownable {
    // Constants
    uint256 public constant MINT_PRICE = 0.1 ether;
    uint256 public constant MAX_SUPPLY = 10000;
    
    // State variables
    string private _baseTokenURI;
    uint256 private _currentTokenId;
    bool public mintingEnabled;

    // Events
    event MintingEnabled(bool enabled);
    event BaseURIUpdated(string newBaseURI);

    constructor(
        string memory name,
        string memory symbol,
        string memory baseURI,
        address royaltyReceiver,
        uint96 royaltyFeeNumerator
    ) ERC721Royalty(name, symbol, royaltyReceiver, royaltyFeeNumerator) Ownable(msg.sender) {
        _baseTokenURI = baseURI;
    }

    /**
     * @dev Mint new tokens.
     */
    function mint() external payable {
        require(mintingEnabled, "Minting is not enabled");
        require(msg.value >= MINT_PRICE, "Insufficient payment");
        require(_currentTokenId < MAX_SUPPLY, "Max supply reached");

        _currentTokenId++;
        _safeMint(msg.sender, _currentTokenId);
    }

    /**
     * @dev Mint multiple tokens at once.
     */
    function mintBatch(uint256 quantity) external payable {
        require(mintingEnabled, "Minting is not enabled");
        require(msg.value >= MINT_PRICE * quantity, "Insufficient payment");
        require(_currentTokenId + quantity <= MAX_SUPPLY, "Would exceed max supply");

        for (uint256 i = 0; i < quantity; i++) {
            _currentTokenId++;
            _safeMint(msg.sender, _currentTokenId);
        }
    }

    /**
     * @dev Enable or disable minting.
     */
    function setMintingEnabled(bool enabled) external onlyOwner {
        mintingEnabled = enabled;
        emit MintingEnabled(enabled);
    }

    /**
     * @dev Set the base URI for token metadata.
     */
    function setBaseURI(string memory newBaseURI) external onlyOwner {
        _baseTokenURI = newBaseURI;
        emit BaseURIUpdated(newBaseURI);
    }

    /**
     * @dev Withdraw collected ETH to owner.
     */
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = owner().call{value: balance}("");
        require(success, "Transfer failed");
    }

    /**
     * @dev Returns current token supply.
     */
    function totalSupply() external view returns (uint256) {
        return _currentTokenId;
    }

    /**
     * @dev Returns max token supply.
     */
    function maxSupply() external pure returns (uint256) {
        return MAX_SUPPLY;
    }

    /**
     * @dev Returns the base URI for token metadata.
     */
    function _baseURI() internal view virtual returns (string memory) {
        return _baseTokenURI;
    }
}