// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title ERC1967Storage
 * @dev Storage slots defined by ERC1967
 */
abstract contract ERC1967Storage {
    // keccak-256 hash of "eip1967.proxy.implementation" subtracted by 1
    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    // keccak-256 hash of "eip1967.proxy.admin" subtracted by 1
    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    // keccak-256 hash of "eip1967.proxy.beacon" subtracted by 1
    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;
}