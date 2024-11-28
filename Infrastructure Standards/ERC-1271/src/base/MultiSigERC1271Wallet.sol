// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IERC1271.sol";

contract MultiSigERC1271Wallet is IERC1271 {
    bytes4 constant internal MAGIC_VALUE = 0x1626ba7e;
    bytes4 constant internal FAIL_VALUE = 0xffffffff;

    mapping(address => bool) public isOwner;
    uint256 public requiredSignatures;
    address[] public owners;

    constructor(address[] memory _owners, uint256 _requiredSignatures) {
        require(_owners.length >= _requiredSignatures, "Invalid required signatures");
        require(_requiredSignatures > 0, "Required signatures must be > 0");

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Duplicate owner");

            isOwner[owner] = true;
            owners.push(owner);
        }

        requiredSignatures = _requiredSignatures;
    }

    /**
     * @dev Verifies multiple signatures are valid
     */
    function isValidSignature(
        bytes32 hash,
        bytes memory signatures
    ) public view override returns (bytes4) {
        // Check signature length is correct
        require(signatures.length % 65 == 0, "Invalid signature length");
        uint256 signatureCount = signatures.length / 65;
        require(signatureCount >= requiredSignatures, "Not enough signatures");

        // Array to track used addresses (prevent signature reuse)
        address[] memory usedAddresses = new address[](signatureCount);
        uint256 validSignatures = 0;

        for (uint256 i = 0; i < signatureCount; i++) {
            // Extract signature components
            bytes32 r;
            bytes32 s;
            uint8 v;

            assembly {
                let signaturePos := mul(0x41, i)
                r := mload(add(add(signatures, 0x20), signaturePos))
                s := mload(add(add(signatures, 0x40), signaturePos))
                v := byte(0, mload(add(add(signatures, 0x60), signaturePos)))
            }

            if (v < 27) {
                v += 27;
            }

            // Recover signer address
            address recovered = ecrecover(hash, v, r, s);
            require(recovered != address(0), "Invalid signature");

            // Check if signer is an owner and signature hasn't been used
            if (isOwner[recovered]) {
                bool signatureUnique = true;
                for (uint256 j = 0; j < validSignatures; j++) {
                    if (usedAddresses[j] == recovered) {
                        signatureUnique = false;
                        break;
                    }
                }

                if (signatureUnique) {
                    usedAddresses[validSignatures] = recovered;
                    validSignatures++;
                }
            }
        }

        return validSignatures >= requiredSignatures ? MAGIC_VALUE : FAIL_VALUE;
    }
}