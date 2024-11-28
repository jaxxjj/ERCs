// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IERC1271.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract ExampleContract {
    event ActionExecuted(address indexed executor, bytes32 hash);

    /**
     * @dev Execute an action with signature validation
     */
    function executeWithSignature(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) external {

        require(
            verifySignature(signer, hash, signature),
            "Invalid signature"
        );

        // Execute action
        emit ActionExecuted(signer, hash);
    }

    function verifySignature(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {
        bytes32 prefixedHash = MessageHashUtils.toEthSignedMessageHash(hash);
        // If signer is a contract, use ERC1271 verification
        if (signer.code.length > 0) {
            try IERC1271(signer).isValidSignature(hash, signature) returns (bytes4 magicValue) {
                return magicValue == IERC1271.isValidSignature.selector;
            } catch {
                return false;   
            }
        }

        // If signer is an EOA, use regular ecrecover with EIP-191 prefix
        require(signature.length == 65, "Invalid signature length");
        
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        if (v < 27) v += 27;

        address recovered = ecrecover(prefixedHash, v, r, s);
        return recovered == signer;
    }
}