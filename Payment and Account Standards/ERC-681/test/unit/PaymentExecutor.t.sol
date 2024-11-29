// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {PaymentExecutor} from "../../src/Example/PaymentExecutor.sol";
import {MockERC20, MockERC20Malicious} from "../../src/mocks/MockERC20.sol";

contract PaymentExecutorTest is Test {
    PaymentExecutor public executor;
    MockERC20 public token;
    
    address public constant ALICE = address(0x1);
    address public constant BOB = address(0x2);
    uint256 public constant INITIAL_BALANCE = 100 ether;
    uint256 public constant PAYMENT_AMOUNT = 1 ether;

    event PaymentExecuted(address from, address to, uint256 value);
    event ContractCallExecuted(address contract_, string functionName, bytes params);

    function setUp() public {
        // Deploy contracts
        executor = new PaymentExecutor();
        token = new MockERC20("Test Token", "TEST");
        console.log("Token deployed at:", address(token));
        // Setup test accounts
        vm.deal(ALICE, INITIAL_BALANCE);
        token.mint(ALICE, INITIAL_BALANCE);

        // Approve executor for token transfers
        vm.prank(ALICE);
        token.approve(address(executor), type(uint256).max);
    }

    function testETHPayment() public {
        // Create payment request
        string memory url = executor.createPaymentRequest(PAYMENT_AMOUNT, false, address(0));
        
        // Execute payment
        vm.prank(ALICE);
        vm.expectEmit(true, true, true, true);
        emit PaymentExecuted(ALICE, address(executor), PAYMENT_AMOUNT);
        
        executor.executeFromURL{value: PAYMENT_AMOUNT}(url);

        // Verify balances
        assertEq(address(executor).balance, PAYMENT_AMOUNT);
        assertEq(ALICE.balance, INITIAL_BALANCE - PAYMENT_AMOUNT);
    }

    function testTokenPayment() public {
        // Create token payment request
        string memory url = executor.createPaymentRequest(PAYMENT_AMOUNT, true, address(token));
        
        // Log URL for debugging
        console.log("Token Payment URL:", url);
        
        // Setup approvals
        vm.startPrank(ALICE);
        token.approve(address(executor), PAYMENT_AMOUNT);
        
        // Execute payment
        vm.expectEmit(true, true, true, true);
        emit ContractCallExecuted(
            address(token),
            "transfer",
            abi.encode(address(executor), PAYMENT_AMOUNT)  // These should match the parsed parameters
        );
        
        executor.executeFromURL(url);
        vm.stopPrank();
    
        // Verify balances
        assertEq(token.balanceOf(address(executor)), PAYMENT_AMOUNT);
        assertEq(token.balanceOf(ALICE), INITIAL_BALANCE - PAYMENT_AMOUNT);
    }

    function testFailInvalidETHAmount() public {
        string memory url = executor.createPaymentRequest(PAYMENT_AMOUNT, false, address(0));
        
        vm.prank(ALICE);
        executor.executeFromURL{value: PAYMENT_AMOUNT - 0.1 ether}(url);
    }

    function testFailDoubleExecution() public {
        string memory url = executor.createPaymentRequest(PAYMENT_AMOUNT, false, address(0));
        
        vm.startPrank(ALICE);
        
        executor.executeFromURL{value: PAYMENT_AMOUNT}(url);
        executor.executeFromURL{value: PAYMENT_AMOUNT}(url); // Should fail
        
        vm.stopPrank();
    }

    function testFailInsufficientETHBalance() public {
        string memory url = executor.createPaymentRequest(INITIAL_BALANCE + 1 ether, false, address(0));
        
        vm.prank(ALICE);
        executor.executeFromURL{value: INITIAL_BALANCE + 1 ether}(url);
    }

    function testFailInsufficientTokenBalance() public {
        string memory url = executor.createPaymentRequest(INITIAL_BALANCE + 1 ether, true, address(token));
        
        vm.prank(ALICE);
        executor.executeFromURL(url);
    }

    function testFailInvalidTokenTransfer() public {
        // Deploy malicious token that always returns false on transfer
        MockERC20Malicious maliciousToken = new MockERC20Malicious();
        
        string memory url = executor.createPaymentRequest(PAYMENT_AMOUNT, true, address(maliciousToken));
        
        vm.prank(ALICE);
        executor.executeFromURL(url);
    }
}

