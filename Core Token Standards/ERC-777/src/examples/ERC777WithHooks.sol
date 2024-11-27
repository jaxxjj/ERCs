// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../base/ERC777.sol";
import "../interfaces/IERC1820Registry.sol";
import "../interfaces/IERC777Recipient.sol";
import "../interfaces/IERC777Sender.sol";

// Main Token
contract MyToken is ERC777 {
    constructor(address[] memory initialOperators) 
        ERC777("MyToken", "MTK", initialOperators) {
        // Mint some initial tokens to msg.sender
        _mint(msg.sender, 1000 * 10**18, "", "");
    }
}

// Sender Contract with Hooks
contract TokenSender is IERC777Sender {
    IERC1820Registry private constant _ERC1820_REGISTRY = 
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    
    bytes32 private constant _TOKENS_SENDER_INTERFACE_HASH = 
        keccak256("ERC777TokensSender");
    
    // Events for monitoring
    event TokensToSendCalled(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );

    constructor() {
        // Register interface with ERC1820
        _ERC1820_REGISTRY.setInterfaceImplementer(
            address(this),
            _TOKENS_SENDER_INTERFACE_HASH,
            address(this)
        );
    }

    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external override {
        // Implement pre-transfer logic
        require(amount <= 1000 * 10**18, "Transfer amount too high");
        
        emit TokensToSendCalled(
            operator,
            from,
            to,
            amount,
            userData,
            operatorData
        );
    }
}

// Recipient Contract with Hooks
contract TokenRecipient is IERC777Recipient {
    IERC1820Registry private constant _ERC1820_REGISTRY = 
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    
    bytes32 private constant _TOKENS_RECIPIENT_INTERFACE_HASH = 
        keccak256("ERC777TokensRecipient");
    
    // Track received tokens
    mapping(address => uint256) public receivedTokens;
    
    event TokensReceivedCalled(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );

    constructor() {
        // Register interface with ERC1820
        _ERC1820_REGISTRY.setInterfaceImplementer(
            address(this),
            _TOKENS_RECIPIENT_INTERFACE_HASH,
            address(this)
        );
    }

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external override {
        // Implement post-transfer logic
        receivedTokens[from] += amount;
        
        emit TokensReceivedCalled(
            operator,
            from,
            to,
            amount,
            userData,
            operatorData
        );
    }
}

// Example Usage Contract
contract TokenInteractor {
    MyToken public token;
    TokenSender public sender;
    TokenRecipient public recipient;

    constructor(address tokenAddress) {
        token = MyToken(tokenAddress);
        sender = new TokenSender();
        recipient = new TokenRecipient();
    }

    function executeTransfer(uint256 amount) external {
        // Transfer tokens from sender to recipient
        token.send(address(recipient), amount, "");
    }

    function checkReceivedAmount(address from) external view returns (uint256) {
        return recipient.receivedTokens(from);
    }
}