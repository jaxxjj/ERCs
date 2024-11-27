// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/examples/PermitToken.sol";

contract ERC2612Test is Test {
    PermitToken public token;
    address public owner;
    address public spender;
    uint256 public ownerPrivateKey;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setUp() public {
        // Use a deterministic private key for testing
        ownerPrivateKey = 0xA11CE; // or any other constant value
        owner = vm.addr(ownerPrivateKey);
        spender = makeAddr("spender");
        vm.startPrank(owner);
        token = new PermitToken();
        vm.stopPrank();
        assertEq(token.balanceOf(owner), 1000000 * 10**18, "Initial balance incorrect");
    }

    function testInitialState() public {
        assertEq(token.name(), "PermitToken");
        assertEq(token.symbol(), "PT");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), 1000000 * 10**18);
    }

    function testPermit() public {
        uint256 value = 100 * 10**18;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = token.nonces(owner);

        // Create permit signature
        bytes32 digest = getPermitDigest(
            address(token),
            owner,
            spender,
            value,
            nonce,
            deadline
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        // Execute permit
        token.permit(owner, spender, value, deadline, v, r, s);

        // Verify allowance
        assertEq(token.allowance(owner, spender), value);
        assertEq(token.nonces(owner), nonce + 1);
    }

    function testFailExpiredPermit() public {
        uint256 value = 100 * 10**18;
        uint256 deadline = block.timestamp - 1; // Expired deadline
        uint256 nonce = token.nonces(owner);

        bytes32 digest = getPermitDigest(
            address(token),
            owner,
            spender,
            value,
            nonce,
            deadline
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        // Should fail due to expired deadline
        token.permit(owner, spender, value, deadline, v, r, s);
    }

    function testInvalidSignature() public {
        uint256 value = 100 * 10**18;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = token.nonces(owner);

        bytes32 digest = getPermitDigest(
            address(token),
            owner,
            spender,
            value,
            nonce,
            deadline
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(0xBAD, digest); // Wrong private key

        // Expect the specific error message
        vm.expectRevert("ERC2612: invalid signature");
        
        // Should revert with invalid signature error
        token.permit(owner, spender, value, deadline, v, r, s);
    }

    // Helper function to create permit digest
    function getPermitDigest(
        address token_,
        address owner_,
        address spender_,
        uint256 value_,
        uint256 nonce_,
        uint256 deadline_
    ) internal view returns (bytes32) {
        bytes32 PERMIT_TYPEHASH = keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );
        
        bytes32 structHash = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                owner_,
                spender_,
                value_,
                nonce_,
                deadline_
            )
        );

        bytes32 DOMAIN_SEPARATOR = token.DOMAIN_SEPARATOR();
        
        return keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash)
        );
    }
}