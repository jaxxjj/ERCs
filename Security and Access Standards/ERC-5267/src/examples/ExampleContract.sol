// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {EIP712} from "../base/EIP712.sol";

/**
 * @title Example contract implementing ERC5267
 */
contract ExampleContract is EIP712 {
    // Mapping to store function permissions
    mapping(bytes4 => mapping(address => bool)) private _permissions;
    
    // Typehash for permission grants
    bytes32 private constant PERMISSION_TYPEHASH = 
        keccak256("Permission(address user,bytes4 functionSig,uint256 expiry)");

    // Events
    event PermissionGranted(address indexed user, bytes4 indexed functionSig);
    event PermissionRevoked(address indexed user, bytes4 indexed functionSig);

    constructor() EIP712("ExampleContract", "1") {}

    /**
     * @dev Grants permission to an address for a specific function
     */
    function grantPermission(address user, bytes4 functionSig) external {
        _permissions[functionSig][user] = true;
        emit PermissionGranted(user, functionSig);
    }

    /**
     * @dev Revokes permission from an address for a specific function
     */
    function revokePermission(address user, bytes4 functionSig) external {
        _permissions[functionSig][user] = false;
        emit PermissionRevoked(user, functionSig);
    }

    /**
     * @dev Checks if an address has permission for a specific function
     */
    function hasPermission(
        address user,
        bytes4 functionSig
    ) public view returns (bool) {
        return _permissions[functionSig][user];
    }

    /**
     * @dev Example of a protected function
     */
    function protectedFunction() external {
        require(
            hasPermission(msg.sender, this.protectedFunction.selector),
            "No permission"
        );
        // Function logic
    }

    /**
     * @dev Validates a signed permission
     */
    function validateSignedPermission(
        address user,
        bytes4 functionSig,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public view returns (bool) {
        require(expiry > block.timestamp, "Permission expired");

        bytes32 structHash = keccak256(
            abi.encode(PERMISSION_TYPEHASH, user, functionSig, expiry)
        );
        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = ecrecover(hash, v, r, s);

        return signer != address(0) && signer == user;
    }
}