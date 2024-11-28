// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title CloneFactory
 * @dev Implementation of ERC-1167 proxy factory pattern
 */
contract CloneFactory {
    
    /**
     * @dev Creates a clone of an implementation contract
     * @param implementation Address of the implementation contract
     * @return instance Address of the new proxy contract
     */
    function createClone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cloning bytecode
            let ptr := mload(0x40)
            
            // Copy initialization code
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(96, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            
            // Create clone
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "Create failed");
    }

    /**
     * @dev Predicts the address of a clone
     * @param implementation Address of the implementation contract
     * @param salt Salt used for create2
     * @return predicted The predicted address of the clone
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        assembly ("memory-safe") {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := and(keccak256(add(ptr, 0x43), 0x55), 0xffffffffffffffffffffffffffffffffffffffff)
        }
    }

    /**
     * @dev Creates a deterministic clone using create2
     * @param implementation Address of the implementation contract
     * @param salt Salt for create2
     * @return instance Address of the new proxy contract
     */
    function createCloneDeterministic(
        address implementation,
        bytes32 salt
    ) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            
            // Copy initialization code
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(96, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            
            // Create2 clone
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "Create2 failed");
    }
}