// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {PermissionManager} from "../../src/examples/PermissionManager.sol";

contract PermissionManagerTest is Test {
    PermissionManager public manager;
    address public delegator;
    address public delegate;
    address public target;
    bytes4 public constant TEST_FUNC = bytes4(keccak256("testFunction()"));
    bytes32 public constant DELEGATE_TYPEHASH = keccak256(
        "DelegatePermission(address to,address target,bytes4 functionSig,uint256 expiry)"
    );

    function setUp() public {
        manager = new PermissionManager();
        delegator = makeAddr("delegator");
        delegate = makeAddr("delegate");
        target = makeAddr("target");
    }

    function getDomainSeparator() internal view returns (bytes32) {
        string memory name = "PermissionManager";
        string memory version = "1";
        uint256 chainId = block.chainid;
        address verifyingContract = address(manager);

        return keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                chainId,
                verifyingContract
            )
        );
    }

    function getDigest(
        address to,
        address targetAddr,
        bytes4 functionSig,
        uint256 expiry
    ) internal view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                DELEGATE_TYPEHASH,
                to,
                targetAddr,
                functionSig,
                expiry
            )
        );

        return keccak256(
            abi.encodePacked("\x19\x01", getDomainSeparator(), structHash)
        );
    }

    function test_DelegatePermission() public {
        uint256 privateKey = 0x1234;
        address signer = vm.addr(privateKey);
        uint256 expiry = block.timestamp + 1 hours;

        bytes32 digest = getDigest(
            delegate,
            target,
            TEST_FUNC,
            expiry
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        vm.prank(signer);
        manager.delegatePermission(
            delegate,
            target,
            TEST_FUNC,
            expiry,
            v,
            r,
            s
        );

        assertTrue(manager.checkDelegatedPermission(signer, delegate, TEST_FUNC));
    }

    function testFail_DelegatePermissionExpired() public {
        uint256 privateKey = 0x1234;
        address signer = vm.addr(privateKey);
        uint256 expiry = block.timestamp - 1 hours; // Expired

        bytes32 digest = getDigest(
            delegate,
            target,
            TEST_FUNC,
            expiry
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        vm.prank(signer);
        manager.delegatePermission(
            delegate,
            target,
            TEST_FUNC,
            expiry,
            v,
            r,
            s
        );
    }

    function testFail_DelegatePermissionInvalidSigner() public {
        uint256 privateKey = 0x1234;
        address signer = vm.addr(privateKey);
        uint256 expiry = block.timestamp + 1 hours;

        bytes32 digest = getDigest(
            delegate,
            target,
            TEST_FUNC,
            expiry
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        // Try to use signature with different sender
        vm.prank(delegator);
        manager.delegatePermission(
            delegate,
            target,
            TEST_FUNC,
            expiry,
            v,
            r,
            s
        );
    }

    function test_CheckDelegatedPermission() public {
        assertFalse(manager.checkDelegatedPermission(delegator, delegate, TEST_FUNC));
    }
}