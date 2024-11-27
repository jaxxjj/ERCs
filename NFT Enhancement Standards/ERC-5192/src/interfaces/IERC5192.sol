// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IERC721.sol";

/**
 * @title IERC5192 - Minimal Soulbound NFT interface
 * @dev Interface for soulbound tokens (non-transferable tokens)
 * Interface ID: 0xb45a3c0e
 */
interface IERC5192 {
    /// @notice Emitted when the locking status is changed to locked
    /// @dev Emitted when the locking status is changed to locked
    event Locked(uint256 tokenId);

    /// @notice Emitted when the locking status is changed to unlocked
    /// @dev Emitted when the locking status is changed to unlocked
    event Unlocked(uint256 tokenId);

    /// @notice Returns the locking status of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries about them throw
    /// @param tokenId The identifier for an NFT
    /// @return Whether the NFT is locked
    function locked(uint256 tokenId) external view returns (bool);
}