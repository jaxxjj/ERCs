// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/examples/ExampleContract.sol";
import "../../src/interfaces/IERC1271.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract SignatureFuzzTest is Test {
    ExampleContract public example;
    MockContractWallet public wallet;
    
    address public eoa;
    uint256 public constant EOA_KEY = 0x1234;
    
    address public walletOwner;
    uint256 public constant WALLET_OWNER_KEY = 0x5678;
    
    // Constants for private key bounds
    uint256 internal constant MIN_PRIVATE_KEY = 1;
    uint256 internal constant MAX_PRIVATE_KEY = 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364140;
    
    function setUp() public {
        example = new ExampleContract();
        
        // Setup EOA
        eoa = vm.addr(EOA_KEY);
        vm.deal(eoa, 100 ether);
        vm.label(eoa, "EOA Signer");
        
        // Setup wallet owner
        walletOwner = vm.addr(WALLET_OWNER_KEY);
        wallet = new MockContractWallet(walletOwner);
        vm.deal(walletOwner, 100 ether);
        vm.label(walletOwner, "Wallet Owner");
        vm.label(address(wallet), "Contract Wallet");
    }

    function testFuzzEOASignature(bytes32 message) public {
        bytes32 ethSignedHash = MessageHashUtils.toEthSignedMessageHash(message);
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(EOA_KEY, ethSignedHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        vm.expectEmit(true, true, false, true);
        emit ExampleContract.ActionExecuted(eoa, message);
        
        example.executeWithSignature(eoa, message, signature);
    }
    
    function testFuzzContractWalletSignature(bytes32 message) public {
        bytes32 ethSignedHash = MessageHashUtils.toEthSignedMessageHash(message);
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(WALLET_OWNER_KEY, ethSignedHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        vm.expectEmit(true, true, false, true);
        emit ExampleContract.ActionExecuted(address(wallet), message);
        
        example.executeWithSignature(address(wallet), message, signature);
    }
    
    function testFuzzFailInvalidEOASignature(bytes32 message, uint256 wrongKey) public {
        // Ensure wrongKey is valid but different from EOA_KEY
        wrongKey = bound(wrongKey, MIN_PRIVATE_KEY, MAX_PRIVATE_KEY);
        vm.assume(wrongKey != EOA_KEY);
        
        bytes32 ethSignedHash = MessageHashUtils.toEthSignedMessageHash(message);
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(wrongKey, ethSignedHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        vm.expectRevert("Invalid signature");
        example.executeWithSignature(eoa, message, signature);
    }
    
    function testFuzzFailInvalidContractWalletSignature(bytes32 message, uint256 wrongKey) public {
        // Ensure wrongKey is valid but different from WALLET_OWNER_KEY
        wrongKey = bound(wrongKey, MIN_PRIVATE_KEY, MAX_PRIVATE_KEY);
        vm.assume(wrongKey != WALLET_OWNER_KEY);
        
        bytes32 ethSignedHash = MessageHashUtils.toEthSignedMessageHash(message);
        
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(wrongKey, ethSignedHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        
        vm.expectRevert("Invalid signature");
        example.executeWithSignature(address(wallet), message, signature);
    }
    
    function testFuzzFailInvalidSignatureLength(bytes32 message, uint8 invalidLength) public {
        vm.assume(invalidLength != 65);
        
        bytes memory signature = new bytes(invalidLength);
        
        vm.expectRevert("Invalid signature length");
        example.executeWithSignature(eoa, message, signature);
    }
}

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