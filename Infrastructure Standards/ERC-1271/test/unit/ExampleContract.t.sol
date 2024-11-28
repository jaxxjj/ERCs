// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/examples/ExampleContract.sol";
import "../../src/interfaces/IERC1271.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

// Mock contract wallet that implements ERC1271
contract MockContractWallet is IERC1271 {
    address public owner;
    
    constructor(address _owner) {
        owner = _owner;
    }
    
    function isValidSignature(
        bytes32 _hash,
        bytes memory _signature
    ) external view override returns (bytes4) {
        require(_signature.length == 65, "Invalid signature length");
        
        bytes32 r;
        bytes32 s;
        uint8 v;
        
        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }
        
        if (v < 27) v += 27;
        
        bytes32 ethSignedHash = MessageHashUtils.toEthSignedMessageHash(_hash);
        address recovered = ecrecover(ethSignedHash, v, r, s);
        
        // Return magic value if signature is valid
        if (recovered == owner) {
            return this.isValidSignature.selector;
        }
        
        return 0xffffffff;
    }
}

contract ExampleContractTest is Test {
    ExampleContract public example;
    MockContractWallet public wallet;
    

    uint256 public eoaKey = 0x1234;
    address public eoa = vm.addr(eoaKey);
    
    uint256 public walletOwnerKey = 0x5678;
    address public walletOwner = vm.addr(walletOwnerKey);
    
    function setUp() public {
        example = new ExampleContract();
        wallet = new MockContractWallet(walletOwner);
        
        vm.deal(eoa, 100 ether);
        vm.deal(walletOwner, 100 ether);
        
        vm.label(eoa, "EOA Signer");
        vm.label(walletOwner, "Wallet Owner");
        vm.label(address(wallet), "Contract Wallet");

    }

    function testExecuteWithContractWalletSignature() public {
        bytes32 hash = keccak256("test message");
        
        // Create signature from wallet owner using the original hash
        bytes32 ethSignedHash = MessageHashUtils.toEthSignedMessageHash(hash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(walletOwnerKey, ethSignedHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        // Execute with contract wallet using original hash
        vm.expectEmit(true, true, false, true);
        emit ExampleContract.ActionExecuted(address(wallet), hash);
        
        example.executeWithSignature(address(wallet), hash, signature);
    }

    function testExecuteWithEOASignature() public {
        bytes32 hash = keccak256("test message");
        bytes32 ethSignedHash = MessageHashUtils.toEthSignedMessageHash(hash);
        
        // Create signature from EOA
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(eoaKey, ethSignedHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        // Execute with EOA signature
        vm.expectEmit(true, true, false, true);
        emit ExampleContract.ActionExecuted(eoa, hash);
        
        example.executeWithSignature(eoa, hash, signature);
    }
    
    function testFailInvalidEOASignature() public {
        bytes32 hash = keccak256("test message");
        bytes32 ethSignedHash = MessageHashUtils.toEthSignedMessageHash(hash);
        
        // Create signature from wrong key
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0x9999, ethSignedHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        // Should revert with invalid signature
        example.executeWithSignature(eoa, hash, signature);
    }
    
    function testFailInvalidContractWalletSignature() public {
        bytes32 hash = keccak256("test message");
        bytes32 ethSignedHash = MessageHashUtils.toEthSignedMessageHash(hash);
        
        // Create signature from wrong key
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0x9999, ethSignedHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        // Should revert with invalid signature
        example.executeWithSignature(address(wallet), hash, signature);
    }
    
    function testFailInvalidSignatureLength() public {
        bytes32 hash = keccak256("test message");
        bytes memory signature = new bytes(64); // Invalid length
        
        example.executeWithSignature(eoa, hash, signature);
    }
    
    function testFailNonContractWalletImplementation() public {
        bytes32 hash = keccak256("test message");
        address nonContractWallet = address(0x3);
        
        bytes32 ethSignedHash = MessageHashUtils.toEthSignedMessageHash(hash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(eoaKey, ethSignedHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        example.executeWithSignature(nonContractWallet, hash, signature);
    }
}