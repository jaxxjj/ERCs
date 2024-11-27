// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/examples/PermitToken.sol";
import "../../src/examples/PermitExample.sol";

contract PermitExampleTest is Test {
    PermitToken public token;
    PermitExample public example;
    address public owner;
    address public recipient;
    uint256 public ownerPrivateKey;

    function setUp() public {
        ownerPrivateKey = 0xA11CE;
        owner = vm.addr(ownerPrivateKey);
        recipient = makeAddr("recipient");

        vm.startPrank(owner);
        // Deploy the token - owner will receive all initial supply (1000000 * 10**18)
        token = new PermitToken();
        // Deploy the example contract
        example = new PermitExample(address(token));
        vm.stopPrank();

        // Label addresses for better trace output
        vm.label(owner, "Owner");
        vm.label(recipient, "Recipient");
        vm.label(address(token), "PermitToken");
        vm.label(address(example), "PermitExample");
    }

    function testTransferWithPermit() public {
        uint256 amount = 100 * 10**18;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = token.nonces(owner);

        // Create permit signature
        bytes32 digest = getPermitDigest(
            address(token),
            owner,
            address(example),
            amount,
            nonce,
            deadline
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        // Initial balances
        uint256 initialOwnerBalance = token.balanceOf(owner);
        uint256 initialRecipientBalance = token.balanceOf(recipient);

        // Execute transfer with permit
        example.transferWithPermit(
            owner,
            recipient,
            amount,
            deadline,
            v,
            r,
            s
        );

        // Verify balances
        assertEq(token.balanceOf(owner), initialOwnerBalance - amount);
        assertEq(token.balanceOf(recipient), initialRecipientBalance + amount);
    }

    function testBatchTransferWithPermit() public {
        address[] memory recipients = new address[](3);
        recipients[0] = makeAddr("recipient1");
        recipients[1] = makeAddr("recipient2");
        recipients[2] = makeAddr("recipient3");

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 100 * 10**18;
        amounts[1] = 200 * 10**18;
        amounts[2] = 300 * 10**18;

        uint256 totalAmount = 600 * 10**18;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = token.nonces(owner);

        // Create permit signature
        bytes32 digest = getPermitDigest(
            address(token),
            owner,
            address(example),
            totalAmount,
            nonce,
            deadline
        );

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        // Record initial balances
        uint256 initialOwnerBalance = token.balanceOf(owner);
        uint256[] memory initialRecipientBalances = new uint256[](3);
        for (uint256 i = 0; i < recipients.length; i++) {
            initialRecipientBalances[i] = token.balanceOf(recipients[i]);
        }

        // Execute batch transfer
        example.batchTransferWithPermit(
            owner,
            recipients,
            amounts,
            deadline,
            v,
            r,
            s
        );

        // Verify balances
        assertEq(token.balanceOf(owner), initialOwnerBalance - totalAmount);
        for (uint256 i = 0; i < recipients.length; i++) {
            assertEq(
                token.balanceOf(recipients[i]),
                initialRecipientBalances[i] + amounts[i]
            );
        }
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