// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IERC1271.sol";

contract SignatureVerifier {
    /**
     * @dev Verifies a signature from an EOA or ERC1271 contract
     */
    function verifySignature(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) public view returns (bool) {

        // If signer is a contract, use ERC1271 verification
        if (signer.code.length > 0) {
            try IERC1271(signer).isValidSignature(hash, signature) returns (bytes4 magicValue) {
                return magicValue == IERC1271(signer).isValidSignature.selector;
            } catch {
                return false;
            }
        }

        // If signer is an EOA, use regular ecrecover
        require(signature.length == 65, "Invalid signature length");
        
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        address recovered = ecrecover(hash, v, r, s);
        return recovered == signer;
    }
}