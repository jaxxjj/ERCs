// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/examples/RentableNFT.sol";

contract RentableNFTTest is Test {
    RentableNFT public nft;
    address public owner = address(1);
    address public renter = address(2);
    uint256 public constant TOKEN_ID = 1;

    function setUp() public {
        nft = new RentableNFT();
        nft.mint(owner, TOKEN_ID);
    }

    function testMint() public {
        assertEq(nft.ownerOf(TOKEN_ID), owner);
    }

    function testRentOut() public {
        vm.startPrank(owner);
        nft.rentOut(TOKEN_ID, renter, 3600); // Rent for 1 hour
        vm.stopPrank();

        assertEq(nft.userOf(TOKEN_ID), renter);
        assertTrue(nft.isRented(TOKEN_ID));
    }

    function testRentOutNotOwner() public {
        vm.startPrank(renter);
        vm.expectRevert("Not token owner");
        nft.rentOut(TOKEN_ID, renter, 3600);
        vm.stopPrank();
    }

    function testIsRented() public {
        assertFalse(nft.isRented(TOKEN_ID));

        vm.startPrank(owner);
        nft.rentOut(TOKEN_ID, renter, 3600);
        vm.stopPrank();

        assertTrue(nft.isRented(TOKEN_ID));
    }

    function testGetRemainingRentalTime() public {
        vm.startPrank(owner);
        nft.rentOut(TOKEN_ID, renter, 3600);
        vm.stopPrank();

        assertGt(nft.getRemainingRentalTime(TOKEN_ID), 0);
        assertLe(nft.getRemainingRentalTime(TOKEN_ID), 3600);

        // Fast forward 2 hours
        vm.warp(block.timestamp + 7200);

        assertEq(nft.getRemainingRentalTime(TOKEN_ID), 0);
    }

    function testRentalExpiration() public {
        vm.startPrank(owner);
        nft.rentOut(TOKEN_ID, renter, 3600);
        vm.stopPrank();

        assertTrue(nft.isRented(TOKEN_ID));

        // Fast forward 2 hours
        vm.warp(block.timestamp + 7200);

        assertFalse(nft.isRented(TOKEN_ID));
        assertEq(nft.userOf(TOKEN_ID), address(0));
    }

    function testSetUser() public {
        vm.startPrank(owner);
        nft.setUser(TOKEN_ID, renter, uint64(block.timestamp + 3600));
        vm.stopPrank();

        assertEq(nft.userOf(TOKEN_ID), renter);
    }

    function testSetUserNotOwner() public {
        vm.startPrank(renter);
        vm.expectRevert("ERC4907: caller is not token owner or approved");
        nft.setUser(TOKEN_ID, renter, uint64(block.timestamp + 3600));
        vm.stopPrank();
    }
}