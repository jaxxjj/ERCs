// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../interfaces/IERC6551Account.sol";

contract GameCharacterAccount is IERC6551Account {
    // Game inventory
    mapping(address => mapping(uint256 => uint256)) public itemBalances; // ERC1155 items
    mapping(address => uint256) public goldBalance; // ERC20 currency
    
    // Track state changes
    uint256 private _state;

    // Required by IERC6551Account
    receive() external payable {
        // Allow the account to receive ETH
    }

    // Required by IERC6551Account - track account state
    function state() external view returns (uint256) {
        return _state;
    }

    function executeCall(
        address to,
        uint256 value,
        bytes calldata data
    ) external payable returns (bytes memory) {
        require(msg.sender == owner(), "Not token owner");
        
        (bool success, bytes memory result) = to.call{value: value}(data);
        require(success, "Call failed");
        
        // Increment state on successful execution
        _state++;
        
        return result;
    }

    // Character can collect gold (ERC20)
    function collectGold(address goldToken, uint256 amount) external {
        require(msg.sender == owner(), "Not token owner");
        IERC20(goldToken).transferFrom(msg.sender, address(this), amount);
        goldBalance[goldToken] += amount;
        _state++;
    }

    // Character can collect items (ERC1155)
    function collectItem(
        address itemContract,
        uint256 itemId,
        uint256 amount
    ) external {
        require(msg.sender == owner(), "Not token owner");
        IERC1155(itemContract).safeTransferFrom(
            msg.sender,
            address(this),
            itemId,
            amount,
            ""
        );
        itemBalances[itemContract][itemId] += amount;
        _state++;
    }

    function token()
        external
        view
        returns (
            uint256 chainId,
            address tokenContract,
            uint256 tokenId
        )
    {
        // Return the NFT that owns this account
        return (block.chainid, address(0), 0); // Implementation specific
    }

    function owner() public view returns (address) {
        (uint256 chainId, address tokenContract, uint256 tokenId) = this.token();
        if (chainId != block.chainid) return address(0);
        
        return IERC721(tokenContract).ownerOf(tokenId);
    }

    function isValidSigner(address signer, bytes calldata) external view returns (bytes4) {
        return signer == owner() ? IERC6551Account.isValidSigner.selector : bytes4(0);
    }
}