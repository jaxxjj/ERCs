// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {GeneralERC721} from "../base/ERC721A.sol";
import {Ownable} from "../../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "../../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {Strings} from "../../lib/openzeppelin-contracts/contracts/utils/Strings.sol";

contract MyToken is GeneralERC721, Ownable, ReentrancyGuard {
    using Strings for uint256;

    // Constants
    uint256 public constant PRICE = 0.08 ether;
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public constant MAX_PER_MINT = 5;
    uint256 public constant MAX_PER_WALLET = 10;

    // State variables
    string private _baseTokenURI;
    bool public isPublicMintEnabled;
    mapping(address => bool) public isWhitelisted;
    mapping(address => uint256) public mintedPerWallet;

    // Events
    event PublicMintToggled(bool isEnabled);
    event BaseURIUpdated(string newBaseURI);
    event WhitelistUpdated(address indexed user, bool isWhitelisted);
    event TokensMinted(address indexed to, uint256 quantity);

    // Custom errors
    error MintingNotEnabled();
    error MaxSupplyExceeded();
    error MaxPerMintExceeded();
    error MaxPerWalletExceeded();
    error InsufficientPayment();
    error WithdrawFailed();
    error NotWhitelisted();

    constructor() GeneralERC721("MyToken", "MTK") Ownable(msg.sender) {}

    // Mint functions
    function mint(uint256 quantity) external payable nonReentrant {
        // Checks
        if (!isPublicMintEnabled) revert MintingNotEnabled();
        if (_totalMinted() + quantity > MAX_SUPPLY) revert MaxSupplyExceeded();
        if (quantity > MAX_PER_MINT) revert MaxPerMintExceeded();
        if (mintedPerWallet[msg.sender] + quantity > MAX_PER_WALLET) 
            revert MaxPerWalletExceeded();
        if (msg.value < PRICE * quantity) revert InsufficientPayment();

        // Effects
        mintedPerWallet[msg.sender] += quantity;
        _safeMint(msg.sender, quantity);

        emit TokensMinted(msg.sender, quantity);
    }

    function whitelistMint(uint256 quantity) external payable nonReentrant {
        if (!isWhitelisted[msg.sender]) revert NotWhitelisted();
        if (_totalMinted() + quantity > MAX_SUPPLY) revert MaxSupplyExceeded();
        if (quantity > MAX_PER_MINT) revert MaxPerMintExceeded();
        if (mintedPerWallet[msg.sender] + quantity > MAX_PER_WALLET) 
            revert MaxPerWalletExceeded();
        if (msg.value < PRICE * quantity) revert InsufficientPayment();

        mintedPerWallet[msg.sender] += quantity;
        _safeMint(msg.sender, quantity);

        emit TokensMinted(msg.sender, quantity);
    }

    // Admin functions
    function setPublicMintEnabled(bool enabled) external onlyOwner {
        isPublicMintEnabled = enabled;
        emit PublicMintToggled(enabled);
    }

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
        emit BaseURIUpdated(baseURI);
    }

    function updateWhitelist(address user, bool status) external onlyOwner {
        isWhitelisted[user] = status;
        emit WhitelistUpdated(user, status);
    }

    function batchUpdateWhitelist(
        address[] calldata users,
        bool status
    ) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            isWhitelisted[users[i]] = status;
            emit WhitelistUpdated(users[i], status);
        }
    }

    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = msg.sender.call{value: balance}("");
        if (!success) revert WithdrawFailed();
    }

    // View functions
    function _baseURI() internal view returns (string memory) {
        return _baseTokenURI;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) revert URIQueryForNonexistentToken();

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 
            ? string(abi.encodePacked(baseURI, tokenId.toString())) 
            : "";
    }

    function getMintedCount(address wallet) external view returns (uint256) {
        return mintedPerWallet[wallet];
    }

    function getPrice() external pure returns (uint256) {
        return PRICE;
    }

    function getMaxSupply() external pure returns (uint256) {
        return MAX_SUPPLY;
    }
}