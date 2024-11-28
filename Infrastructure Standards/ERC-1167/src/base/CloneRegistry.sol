// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Example Registry using ERC-1167 Clones
 */
contract CloneRegistry {
    // Implementation => Clone[] mapping
    mapping(address => address[]) private implementationToClones;
    
    // Clone => Implementation mapping
    mapping(address => address) private cloneToImplementation;

    event CloneRegistered(address indexed implementation, address indexed clone);

    /**
     * @dev Registers a clone
     */
    function registerClone(address implementation, address clone) external {
        require(cloneToImplementation[clone] == address(0), "Clone already registered");
        
        implementationToClones[implementation].push(clone);
        cloneToImplementation[clone] = implementation;
        
        emit CloneRegistered(implementation, clone);
    }

    /**
     * @dev Gets all clones for an implementation
     */
    function getClones(address implementation) external view returns (address[] memory) {
        return implementationToClones[implementation];
    }

    /**
     * @dev Gets implementation for a clone
     */
    function getImplementation(address clone) external view returns (address) {
        return cloneToImplementation[clone];
    }
}