// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/examples/SoulboundMembership.sol";

contract SoulboundMembershipTest is Test {
    SoulboundMembership public membership;
    address public admin = address(1);
    address public member = address(2);
    address public unauthorized = address(3);

    function setUp() public {
        vm.startPrank(admin);
        membership = new SoulboundMembership();
        vm.stopPrank();
    }

    function testInitialState() public {
        assertEq(membership.admin(), admin);
        assertEq(membership.name(), "SoulboundMembership");
        assertEq(membership.symbol(), "MEMBER");
    }

    function testIssueMembership() public {
        vm.startPrank(admin);
        uint256 tokenId = membership.issueMembership(
            member,
            SoulboundMembership.MembershipTier.SILVER,
            365 days
        );
        vm.stopPrank();

        assertEq(membership.ownerOf(tokenId), member);
        assertTrue(membership.locked(tokenId));

        (
            SoulboundMembership.MembershipTier tier,
            uint256 issuedAt,
            uint256 validUntil,
            bool isValid
        ) = membership.getMembershipDetails(tokenId);

        assertEq(uint(tier), uint(SoulboundMembership.MembershipTier.SILVER));
        assertEq(issuedAt, block.timestamp);
        assertEq(validUntil, block.timestamp + 365 days);
        assertTrue(isValid);
    }

    function testUnauthorizedIssuance() public {
        vm.startPrank(unauthorized);
        vm.expectRevert("Only admin can call this function");
        membership.issueMembership(member, SoulboundMembership.MembershipTier.BRONZE, 30 days);
        vm.stopPrank();
    }

    function testFailTransferLockedToken() public {
        vm.startPrank(admin);
        uint256 tokenId = membership.issueMembership(
            member,
            SoulboundMembership.MembershipTier.GOLD,
            365 days
        );
        vm.stopPrank();

        vm.startPrank(member);
        vm.expectRevert("Token is soul bound");
        membership.transferFrom(member, unauthorized, tokenId);
        vm.stopPrank();
    }

    function testMembershipValidity() public {
        vm.startPrank(admin);
        uint256 tokenId = membership.issueMembership(
            member,
            SoulboundMembership.MembershipTier.BRONZE,
            30 days
        );
        vm.stopPrank();

        assertTrue(membership.isMembershipValid(tokenId));

        // Fast forward 31 days
        vm.warp(block.timestamp + 31 days);

        assertFalse(membership.isMembershipValid(tokenId));
    }

    function testRenewMembership() public {
        vm.startPrank(admin);
        uint256 tokenId = membership.issueMembership(
            member,
            SoulboundMembership.MembershipTier.SILVER,
            30 days
        );
        
        // Fast forward 20 days
        vm.warp(block.timestamp + 20 days);

        membership.renewMembership(tokenId, 30 days);
        vm.stopPrank();

        (, , uint256 validUntil, bool isValid) = membership.getMembershipDetails(tokenId);
        assertEq(validUntil, block.timestamp + 40 days);
        assertTrue(isValid);
    }

    function testUnauthorizedRenewal() public {
        vm.startPrank(admin);
        uint256 tokenId = membership.issueMembership(
            member,
            SoulboundMembership.MembershipTier.BRONZE,
            30 days
        );
        vm.stopPrank();

        vm.startPrank(unauthorized);
        vm.expectRevert("Only admin can call this function");
        membership.renewMembership(tokenId, 30 days);
        vm.stopPrank();
    }

    function testMultipleMemberships() public {
        vm.startPrank(admin);
        
        uint256 tokenId1 = membership.issueMembership(
            member,
            SoulboundMembership.MembershipTier.BRONZE,
            30 days
        );

        uint256 tokenId2 = membership.issueMembership(
            member,
            SoulboundMembership.MembershipTier.SILVER,
            60 days
        );

        vm.stopPrank();

        assertEq(membership.ownerOf(tokenId1), member);
        assertEq(membership.ownerOf(tokenId2), member);
        assertTrue(tokenId2 > tokenId1);

        (SoulboundMembership.MembershipTier tier1,,,) = membership.getMembershipDetails(tokenId1);
        (SoulboundMembership.MembershipTier tier2,,,) = membership.getMembershipDetails(tokenId2);
        
        assertEq(uint(tier1), uint(SoulboundMembership.MembershipTier.BRONZE));
        assertEq(uint(tier2), uint(SoulboundMembership.MembershipTier.SILVER));
    }

    function testLockStatus() public {
        vm.startPrank(admin);
        uint256 tokenId = membership.issueMembership(
            member,
            SoulboundMembership.MembershipTier.GOLD,
            365 days
        );
        vm.stopPrank();

        assertTrue(membership.locked(tokenId));
    }

}