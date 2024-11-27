// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../base/ERC3156.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Example Flash Lender
 * @dev Example implementation of ERC3156 Flash Lender
 */
contract FlashLender is ERC3156FlashLender, Ownable {
    constructor(address[] memory tokens) ERC3156FlashLender(tokens) Ownable(msg.sender) {}

    /**
     * @dev Add a supported token (only owner)
     */
    function addSupportedToken(address token) external onlyOwner {
        _addSupportedToken(token);
    }

    /**
     * @dev Remove a supported token (only owner)
     */
    function removeSupportedToken(address token) external onlyOwner {
        _removeSupportedToken(token);
    }

    /**
     * @dev Withdraw tokens (only owner)
     */
    function withdrawToken(address token, uint256 amount) external onlyOwner {
        require(IERC20(token).transfer(owner(), amount), "Transfer failed");
    }
}