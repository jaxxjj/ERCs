// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {ExampleContract} from "../../src/examples/ExampleContract.sol";

contract ExampleContractTest is Test {
    ExampleContract public example;
    address public user1;
    address public user2;
    bytes4 public constant PROTECTED_FUNC = bytes4(keccak256("protectedFunction()"));
    bytes32 public constant PERMISSION_TYPEHASH = keccak256(
        "Permission(address user,bytes4 functionSig,uint256 expiry)"
    );

    function setUp() public {
        example = new ExampleContract();
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
    }

    function getDomainSeparator() internal view returns (bytes32) {
        string memory name = "ExampleContract";
        string memory version = "1";
        uint256 chainId = block.chainid;
        address verifyingContract = address(example);

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
        address user,
        bytes4 functionSig,
        uint256 expiry
    ) internal view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                PERMISSION_TYPEHASH,
                user,
                functionSig,
                expiry
            )
        );

        return keccak256(
            abi.encodePacked("\x19\x01", getDomainSeparator(), structHash)
        );
    }

    function test_GrantPermission() public {
        example.grantPermission(user1, PROTECTED_FUNC);
        assertTrue(example.hasPermission(user1, PROTECTED_FUNC));
    }

    function test_RevokePermission() public {
        example.grantPermission(user1, PROTECTED_FUNC);
        example.revokePermission(user1, PROTECTED_FUNC);
        assertFalse(example.hasPermission(user1, PROTECTED_FUNC));
    }

    function test_ProtectedFunctionWithPermission() public {
        example.grantPermission(address(this), PROTECTED_FUNC);
        example.protectedFunction();
        // Success if no revert
    }

    function testFail_ProtectedFunctionWithoutPermission() public {
        example.protectedFunction();
    }

    function test_ValidateSignedPermission() public {
        uint256 privateKey = 0x1234;
        address signer = vm.addr(privateKey);
        uint256 expiry = block.timestamp + 1 hours;

        bytes32 digest = getDigest(
            signer,
            PROTECTED_FUNC,
            expiry
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        bool isValid = example.validateSignedPermission(
            signer,
            PROTECTED_FUNC,
            expiry,
            v,
            r,
            s
        );
        assertTrue(isValid);
    }

    function testFail_ValidateExpiredPermission() public {
        uint256 privateKey = 0x1234;
        address signer = vm.addr(privateKey);
        uint256 expiry = block.timestamp - 1 hours; // Expired

        bytes32 digest = getDigest(
            signer,
            PROTECTED_FUNC,
            expiry
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        example.validateSignedPermission(
            signer,
            PROTECTED_FUNC,
            expiry,
            v,
            r,
            s
        );
    }

    function test_MultiplePermissions() public {
        bytes4 func1 = bytes4(keccak256("function1()"));
        bytes4 func2 = bytes4(keccak256("function2()"));

        example.grantPermission(user1, func1);
        example.grantPermission(user1, func2);

        assertTrue(example.hasPermission(user1, func1));
        assertTrue(example.hasPermission(user1, func2));
    }

    function test_PermissionEvents() public {
        vm.expectEmit(true, true, false, false);
        emit ExampleContract.PermissionGranted(user1, PROTECTED_FUNC);
        example.grantPermission(user1, PROTECTED_FUNC);

        vm.expectEmit(true, true, false, false);
        emit ExampleContract.PermissionRevoked(user1, PROTECTED_FUNC);
        example.revokePermission(user1, PROTECTED_FUNC);
    }

    function testFail_ValidateInvalidSignature() public {
        uint256 privateKey = 0x1234;
        address signer = vm.addr(privateKey);
        uint256 expiry = block.timestamp + 1 hours;

        bytes32 digest = getDigest(
            signer,
            PROTECTED_FUNC,
            expiry
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        // Try to validate with wrong signer
        assert(example.validateSignedPermission(
            user1, // Different from signer
            PROTECTED_FUNC,
            expiry,
            v,
            r,
            s
        ));
    }

    function test_BatchPermissions() public {
        address[] memory users = new address[](2);
        users[0] = user1;
        users[1] = user2;

        bytes4[] memory funcs = new bytes4[](2);
        funcs[0] = PROTECTED_FUNC;
        funcs[1] = bytes4(keccak256("otherFunction()"));

        for (uint i = 0; i < users.length; i++) {
            example.grantPermission(users[i], funcs[i]);
            assertTrue(example.hasPermission(users[i], funcs[i]));
        }
    }
}