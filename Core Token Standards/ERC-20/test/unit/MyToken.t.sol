// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/examples/MyToken.sol";
import "../../src/interfaces/IERC20.sol";

contract MyTokenTest is Test {
    MyToken public token;
    address public owner;
    address public user1;
    address public user2;
    
    // Events from IERC20
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    // Initial supply of 1 million tokens
    uint256 constant INITIAL_SUPPLY = 1_000_000 * 10**18;

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        token = new MyToken();
    }

    // Existing tests
    function testInitialSupply() public {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }

    function testTokenMetadata() public {
        assertEq(token.name(), "MyToken");
        assertEq(token.symbol(), "MTK");
        assertEq(token.decimals(), 18);
    }

    // Transfer tests
    function testTransfer() public {
        uint256 amount = 1000 * 10**18;
        bool success = token.transfer(user1, amount);
        
        assertTrue(success);
        assertEq(token.balanceOf(user1), amount);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - amount);
    }

    function testTransferEmitsEvent() public {
        uint256 amount = 1000 * 10**18;
        
        vm.expectEmit(true, true, false, true);
        emit Transfer(owner, user1, amount);
        
        token.transfer(user1, amount);
    }

    function testFailTransferInsufficientBalance() public {
        uint256 balance = token.balanceOf(owner);
        token.transfer(user1, balance + 1);
    }

    function testFailTransferToZeroAddress() public {
        token.transfer(address(0), 100);
    }

    // Approval tests
    function testApprove() public {
        assertTrue(token.approve(user1, 1000));
        assertEq(token.allowance(owner, user1), 1000);
    }

    function testApproveEmitsEvent() public {
        uint256 amount = 1000;
        
        vm.expectEmit(true, true, false, true);
        emit Approval(owner, user1, amount);
        
        token.approve(user1, amount);
    }

    // TransferFrom tests
    function testTransferFrom() public {
        uint256 amount = 1000;
        token.approve(user1, amount);
        
        vm.prank(user1);
        bool success = token.transferFrom(owner, user2, amount);
        
        assertTrue(success);
        assertEq(token.balanceOf(user2), amount);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - amount);
        assertEq(token.allowance(owner, user1), 0);
    }

    function testFailTransferFromInsufficientAllowance() public {
        token.approve(user1, 500);
        
        vm.prank(user1);
        token.transferFrom(owner, user2, 1000);
    }

    function testFailTransferFromInsufficientBalance() public {
        uint256 balance = token.balanceOf(owner);
        token.approve(user1, balance + 1);
        
        vm.prank(user1);
        token.transferFrom(owner, user2, balance + 1);
    }

    // Zero amount tests
    function testTransferZeroAmount() public {
        assertTrue(token.transfer(user1, 0));
        assertEq(token.balanceOf(user1), 0);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
    }

    function testTransferFromZeroAmount() public {
        token.approve(user1, 1000);
        
        vm.prank(user1);
        assertTrue(token.transferFrom(owner, user2, 0));
        assertEq(token.balanceOf(user2), 0);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
        assertEq(token.allowance(owner, user1), 1000);
    }

    // Multiple transfers test
    function testMultipleTransfers() public {
        token.transfer(user1, 1000);
        token.transfer(user2, 500);
        
        assertEq(token.balanceOf(user1), 1000);
        assertEq(token.balanceOf(user2), 500);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY - 1500);
    }

    // Allowance tests
    function testIncreaseAllowance() public {
        token.approve(user1, 1000);
        token.approve(user1, 2500);
        assertEq(token.allowance(owner, user1), 2500);
    }

    function testAllowanceDoesNotAffectBalance() public {
        token.approve(user1, INITIAL_SUPPLY * 2);
        assertEq(token.balanceOf(owner), INITIAL_SUPPLY);
        assertEq(token.balanceOf(user1), 0);
    }
}