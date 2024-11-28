// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IERC165
 * @dev Standard interface for contract interface detection
 */
interface IERC165 {
    /**
     * @notice Query if a contract implements an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return `true` if the contract implements `interfaceId`, `false` otherwise
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}