// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title LibAppStorage
 * @dev Centralized storage handling for all facets
 */
library LibAppStorage {
    // Storage struct contains all contract state variables
    struct AppStorage {
        // StorageFacet state
        uint256 value;
        mapping(address => bool) authorized;
        string message;
        
        // AccessControlFacet state
        mapping(address => bool) admins;
        mapping(bytes4 => mapping(address => bool)) methodAccess;
    }

    // Returns the storage struct from a fixed slot
    function diamondStorage() internal pure returns (AppStorage storage ds) {
        // Unique storage position for diamond storage
        bytes32 position = keccak256("diamond.app.storage");
        assembly {
            ds.slot := position
        }
    }
}