// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {EIP712} from "../base/EIP712.sol";

/**
 * @title Permission Manager with ERC5267
 */
contract PermissionManager is EIP712 {
    mapping(address => mapping(address => mapping(bytes4 => bool))) private _delegatedPermissions;
    
    constructor() EIP712("PermissionManager", "1") {}

    /**
     * @dev Delegates permission to another address
     */
    function delegatePermission(
        address to,
        address target,
        bytes4 functionSig,
        uint256 expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(expiry > block.timestamp, "Invalid expiry");
        
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("DelegatePermission(address to,address target,bytes4 functionSig,uint256 expiry)"),
                to,
                target,
                functionSig,
                expiry
            )
        );
        
        bytes32 hash = _hashTypedDataV4(structHash);
        address signer = ecrecover(hash, v, r, s);
        
        require(signer != address(0) && signer == msg.sender, "Invalid signature");
        
        _delegatedPermissions[msg.sender][to][functionSig] = true;
    }

    /**
     * @dev Checks delegated permission
     */
    function checkDelegatedPermission(
        address from,
        address to,
        bytes4 functionSig
    ) external view returns (bool) {
        return _delegatedPermissions[from][to][functionSig];
    }
}