// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/examples/MyToken.sol";

contract MyTokenFuzzTest is Test {
    MyToken public token;
    address public owner;
    
    uint256 constant INITIAL_SUPPLY = 1_000_000 * 10**18;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function setUp() public {
        owner = address(this);
        token = new MyToken();
    }

    // Fuzz transfer with random amounts and addresses
    function testFuzzTransfer(address to, uint256 amount) public {
        // Assumptions to make test meaningful
        vm.assume(to != address(0));
        vm.assume(to != address(this));
        vm.assume(amount <= INITIAL_SUPPLY);

        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 toBalanceBefore = token.balanceOf(to);

        bool success = token.transfer(to, amount);

        assertTrue(success);
        assertEq(token.balanceOf(owner), ownerBalanceBefore - amount);
        assertEq(token.balanceOf(to), toBalanceBefore + amount);
    }

    // Fuzz approve with random amounts and spenders
    function testFuzzApprove(address spender, uint256 amount) public {
        vm.assume(spender != address(0));

        bool success = token.approve(spender, amount);

        assertTrue(success);
        assertEq(token.allowance(owner, spender), amount);
    }

    // Fuzz transferFrom with random amounts and addresses
    function testFuzzTransferFrom(
        address from, 
        address to, 
        uint256 approval, 
        uint256 amount
    ) public {
        // Assumptions
        vm.assume(from != address(0) && to != address(0));
        vm.assume(from != to);
        vm.assume(amount <= approval);
        vm.assume(approval <= INITIAL_SUPPLY);

        // Setup
        token.transfer(from, approval);
        vm.prank(from);
        token.approve(address(this), approval);

        uint256 fromBalanceBefore = token.balanceOf(from);
        uint256 toBalanceBefore = token.balanceOf(to);

        bool success = token.transferFrom(from, to, amount);

        assertTrue(success);
        assertEq(token.balanceOf(from), fromBalanceBefore - amount);
        assertEq(token.balanceOf(to), toBalanceBefore + amount);
        assertEq(token.allowance(from, address(this)), approval - amount);
    }

    // Fuzz multiple transfers
    function testFuzzMultipleTransfers(
        address[3] memory tos,
        uint256[3] memory amounts
    ) public {
        uint256 totalAmount;
        
        // Bound the total amount to not exceed supply
        for(uint i = 0; i < amounts.length; i++) {
            amounts[i] = bound(amounts[i], 0, INITIAL_SUPPLY / 3);
            totalAmount += amounts[i];
            vm.assume(tos[i] != address(0) && tos[i] != address(this));
        }

        uint256 ownerBalanceBefore = token.balanceOf(owner);

        for(uint i = 0; i < tos.length; i++) {
            token.transfer(tos[i], amounts[i]);
            assertEq(token.balanceOf(tos[i]), amounts[i]);
        }

        assertEq(token.balanceOf(owner), ownerBalanceBefore - totalAmount);
    }

    // Fuzz allowance modifications
    function testFuzzAllowanceModification(
        address spender,
        uint256 initialAllowance,
        uint256 newAllowance
    ) public {
        vm.assume(spender != address(0));
        vm.assume(initialAllowance <= INITIAL_SUPPLY);
        vm.assume(newAllowance <= INITIAL_SUPPLY);

        token.approve(spender, initialAllowance);
        assertEq(token.allowance(owner, spender), initialAllowance);

        token.approve(spender, newAllowance);
        assertEq(token.allowance(owner, spender), newAllowance);
    }

    // Fuzz increase/decrease allowance
    function testFuzzIncreaseDecreaseAllowance(
        address spender,
        uint256 initialAllowance,
        uint256 increase,
        uint256 decrease
    ) public {
        vm.assume(spender != address(0));
        vm.assume(initialAllowance <= INITIAL_SUPPLY);
        vm.assume(increase <= INITIAL_SUPPLY - initialAllowance);
        vm.assume(decrease <= initialAllowance + increase);

        token.approve(spender, initialAllowance);
        
        token.increaseAllowance(spender, increase);
        assertEq(token.allowance(owner, spender), initialAllowance + increase);
        
        token.decreaseAllowance(spender, decrease);
        assertEq(token.allowance(owner, spender), initialAllowance + increase - decrease);
    }

    // Fuzz complex token operations
    function testFuzzComplexScenario(
        address[2] memory users,
        uint256[2] memory amounts,
        uint256[2] memory allowances
    ) public {
        // Setup assumptions
        vm.assume(users[0] != address(0) && users[1] != address(0));
        vm.assume(users[0] != users[1]);
        amounts[0] = bound(amounts[0], 0, INITIAL_SUPPLY / 2);
        amounts[1] = bound(amounts[1], 0, amounts[0]);
        allowances[0] = bound(allowances[0], amounts[1], INITIAL_SUPPLY);
        allowances[1] = bound(allowances[1], 0, INITIAL_SUPPLY);

        // Initial transfers
        token.transfer(users[0], amounts[0]);
        
        // Approvals
        vm.prank(users[0]);
        token.approve(users[1], allowances[0]);
        
        // Secondary transfers
        vm.prank(users[1]);
        token.transferFrom(users[0], users[1], amounts[1]);
        
        // Verify final state
        assertEq(token.balanceOf(users[0]), amounts[0] - amounts[1]);
        assertEq(token.balanceOf(users[1]), amounts[1]);
        assertEq(token.allowance(users[0], users[1]), allowances[0] - amounts[1]);
    }

    // Invariant: total supply should remain constant
    function testFuzzTotalSupplyInvariant(address[3] memory users, uint256[3] memory amounts) public {
        uint256 initialTotalSupply = token.totalSupply();

        for(uint i = 0; i < users.length; i++) {
            vm.assume(users[i] != address(0));
            amounts[i] = bound(amounts[i], 0, INITIAL_SUPPLY / 3);
            token.transfer(users[i], amounts[i]);
        }

        assertEq(token.totalSupply(), initialTotalSupply);
    }
} 