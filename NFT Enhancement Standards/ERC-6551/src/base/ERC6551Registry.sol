// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interfaces/IERC6551Registry.sol";

/**
 * @title ERC6551Registry
 * @dev Implementation of the ERC6551 registry for creating and tracking token bound accounts
 * @author Your Name
 */
contract ERC6551Registry is IERC6551Registry {
    /**
     * @dev Creates a token bound account
     * @param implementation The implementation contract address
     * @param salt Random value for account address generation
     * @param chainId Chain ID of the NFT
     * @param tokenContract NFT contract address
     * @param tokenId Token ID
     * @return accountAddress The created account address
     */
    function createAccount(
        address implementation,
        bytes32 salt,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId
    ) external returns (address accountAddress) {
        bytes memory code = _creationCode(implementation, chainId, tokenContract, tokenId);
        bytes32 deploySalt = keccak256(abi.encodePacked(salt, chainId, tokenContract, tokenId));
        
        assembly {
            accountAddress := create2(0, add(code, 0x20), mload(code), deploySalt)
        }
        
        if (accountAddress == address(0)) {
            revert AccountCreationFailed();
        }

        emit ERC6551AccountCreated(
            accountAddress,
            implementation,
            salt,
            chainId,
            tokenContract,
            tokenId
        );

        return accountAddress;
    }

    /**
     * @dev Computes the token bound account address
     * @param implementation The implementation contract address
     * @param salt Random value for account address generation
     * @param chainId Chain ID of the NFT
     * @param tokenContract NFT contract address
     * @param tokenId Token ID
     * @return predictedAddress The computed account address
     */
    function account(
        address implementation,
        bytes32 salt,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId
    ) external view returns (address predictedAddress) {
        bytes32 deploySalt = keccak256(abi.encodePacked(salt, chainId, tokenContract, tokenId));
        bytes memory code = _creationCode(implementation, chainId, tokenContract, tokenId);
        
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                deploySalt,
                keccak256(code)
            )
        );
        
        return address(uint160(uint256(hash)));
    }

    /**
     * @dev Internal function to generate creation code for the account
     * @param implementation Implementation address
     * @param chainId Chain ID
     * @param tokenContract Token contract address
     * @param tokenId Token ID
     * @return Creation bytecode
     */
    function _creationCode(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(
            hex"3d60ad80600a3d3981f3363d3d373d3d3d363d73",
            implementation,
            hex"5af43d82803e903d91602b57fd5bf3",
            abi.encode(chainId, tokenContract, tokenId)
        );
    }
}