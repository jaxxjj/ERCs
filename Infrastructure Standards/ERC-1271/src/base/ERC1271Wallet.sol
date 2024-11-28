// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IERC1271.sol";

contract ERC1271Wallet is IERC1271 {
    // bytes4(keccak256("isValidSignature(bytes32,bytes)")
    bytes4 constant internal MAGIC_VALUE = 0x1626ba7e;
    bytes4 constant internal FAIL_VALUE = 0xffffffff;

    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    /**
     * @dev Verifies that the signature is valid for the given hash
     */
    function isValidSignature(
        bytes32 hash,
        bytes memory signature
    ) public view override returns (bytes4) {
        require(signature.length == 65, "Invalid signature length");

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        // Verify EIP-2 compliant signature
        if (v < 27) {
            v += 27;
        }

        // Verify signature
        address recovered = ecrecover(hash, v, r, s);
        
        if (recovered == owner && recovered != address(0)) {
            return MAGIC_VALUE;
        } else {
            return FAIL_VALUE;
        }
    }
}