// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IERC721.sol";

/**
 * @title ERC-4907 NFT Rental Standard
 * @dev Interface for an NFT rental standard as an extension of ERC-721
 * Interface ID: 0xad092b5c
 */
interface IERC4907 is IERC721 {
    // Logged when the user of an NFT is changed or expires is changed
    event UpdateUser(uint256 indexed tokenId, address indexed user, uint64 expires);

    /**
     * @notice Set the user and expires of an NFT
     * @dev The zero address indicates there is no user
     * @param tokenId The NFT to assign the user to
     * @param user The new user of the NFT
     * @param expires UNIX timestamp when the user's rights expire
     */
    function setUser(uint256 tokenId, address user, uint64 expires) external;

    /**
     * @notice Get the user address of an NFT
     * @dev The zero address indicates that there is no user or the user has expired
     * @param tokenId The NFT to get the user address for
     * @return The user address for this NFT
     */
    function userOf(uint256 tokenId) external view returns (address);

    /**
     * @notice Get the user expires of an NFT
     * @dev Returns 0 if there is no user
     * @param tokenId The NFT to get the user expires for
     * @return The user expires timestamp for this NFT
     */
    function userExpires(uint256 tokenId) external view returns (uint256);
}