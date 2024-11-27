// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/examples/ERC777WithHooks.sol";
import "../../src/interfaces/IERC1820Registry.sol";

contract ERC777WithHooksTest is Test {
    // Canonical ERC1820 Registry address
    IERC1820Registry constant internal ERC1820_REGISTRY =
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    
    MyToken token;
    TokenSender sender;
    TokenRecipient recipient;
    TokenInteractor interactor;
    
    address operator = makeAddr("operator");
    uint256 constant INITIAL_SUPPLY = 1000 * 1e18;
    
    function setUp() public {
        // Fork mainnet at a recent block
        vm.createSelectFork(vm.envString("MAINNET_RPC_URL"));
        
        // Deploy token with initial operators
        address[] memory operators = new address[](1);
        operators[0] = operator;
        token = new MyToken(operators);
        
        // Deploy TokenInteractor
        interactor = new TokenInteractor(address(token));
        sender = interactor.sender();
        recipient = interactor.recipient();
        
        // Mint initial tokens to test contract
        token.transfer(address(this), INITIAL_SUPPLY);
        
        // Label addresses for better trace output
        vm.label(address(token), "ERC777Token");
        vm.label(address(sender), "TokenSender");
        vm.label(address(recipient), "TokenRecipient");
        vm.label(address(interactor), "TokenInteractor");
    }

    function test_Fork_InitialSupply() public {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
        assertEq(token.balanceOf(address(this)), INITIAL_SUPPLY);
    }

    function test_Fork_TokenTransfer() public {
        uint256 transferAmount = 100 * 1e18;
        
        // Ensure we have enough tokens
        assertGe(token.balanceOf(address(this)), transferAmount, "Insufficient balance");
        
        // Approve interactor to spend tokens
        token.approve(address(interactor), transferAmount);
        
        uint256 preBalance = token.balanceOf(address(this));
        uint256 preRecipientBalance = token.balanceOf(address(recipient));
        
        // Execute transfer through interactor
        interactor.executeTransfer(transferAmount);
        
        // Check balances
        assertEq(token.balanceOf(address(recipient)), preRecipientBalance + transferAmount);
        assertEq(token.balanceOf(address(this)), preBalance - transferAmount);
    }

    function test_Fork_TokenSenderHook() public {
        uint256 transferAmount = 100 * 1e18;
        
        // Check if sender is registered in ERC1820
        bytes32 senderHash = keccak256("ERC777TokensSender");
        address registeredSender = ERC1820_REGISTRY.getInterfaceImplementer(
            address(sender),
            senderHash
        );
        assertEq(registeredSender, address(sender), "Sender not registered");
        
        // Approve and transfer
        token.approve(address(interactor), transferAmount);
        
        // Record pre-transfer state
        uint256 preBalance = token.balanceOf(address(this));
        
        vm.expectEmit(true, true, true, true, address(sender));
        emit TokenSender.TokensToSendCalled(
            address(this),
            address(this),
            address(recipient),
            transferAmount,
            "",
            ""
        );
        
        interactor.executeTransfer(transferAmount);
        
        // Verify transfer occurred
        assertEq(token.balanceOf(address(this)), preBalance - transferAmount);
    }

    function test_Fork_TokenRecipientHook() public {
        uint256 transferAmount = 100 * 1e18;
        
        // Check if recipient is registered in ERC1820
        bytes32 recipientHash = keccak256("ERC777TokensRecipient");
        address registeredRecipient = ERC1820_REGISTRY.getInterfaceImplementer(
            address(recipient),
            recipientHash
        );
        assertEq(registeredRecipient, address(recipient), "Recipient not registered");
        
        // Ensure we have enough tokens
        assertGe(token.balanceOf(address(this)), transferAmount, "Insufficient balance");
        
        // Approve and transfer
        token.approve(address(interactor), transferAmount);
        interactor.executeTransfer(transferAmount);
        
        // Check received amount tracking
        assertEq(interactor.checkReceivedAmount(address(this)), transferAmount);
    }

    function test_Fork_OperatorAuthorization() public {
        assertTrue(token.isOperatorFor(operator, address(this)));
    }

    function testFail_Fork_UnauthorizedOperator() public {
        address unauthorized = makeAddr("unauthorized");
        vm.prank(unauthorized);
        token.operatorSend(
            address(this),
            address(recipient),
            100 * 1e18,
            "",
            ""
        );
    }

    function test_Fork_RegistryIntegration() public {
        // Verify ERC1820 Registry exists and works
        bytes32 interfaceHash = keccak256("ERC777Token");
        assertTrue(address(ERC1820_REGISTRY).code.length > 0, "Registry not deployed");
        
        // Become the implementer
        vm.startPrank(address(this));
        ERC1820_REGISTRY.setInterfaceImplementer(
            address(this),
            interfaceHash,
            address(token)
        );
        vm.stopPrank();
        
        address implementer = ERC1820_REGISTRY.getInterfaceImplementer(
            address(this),
            interfaceHash
        );
        assertEq(implementer, address(token), "Registry interface setting failed");
    }
}