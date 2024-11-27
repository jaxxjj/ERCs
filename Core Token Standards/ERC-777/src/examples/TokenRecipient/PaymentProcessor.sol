// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../../interfaces/IERC777Recipient.sol";
import "../../interfaces/IERC1820Registry.sol";
import "../../interfaces/IERC777.sol";

contract PaymentProcessor is IERC777Recipient {
    IERC777 public paymentToken;
    mapping(address => uint256) public processingFees;
    uint256 public constant FEE_RATE = 1; // 0.1%
    
    constructor(address tokenAddress) {
        paymentToken = IERC777(tokenAddress);
        // register interface
        IERC1820Registry registry = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
        registry.setInterfaceImplementer(
            address(this),
            keccak256("ERC777TokensRecipient"),
            address(this)
        );
        registry.setInterfaceImplementer(
            address(this),
            keccak256("ERC777TokensSender"),
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
        require(msg.sender == address(paymentToken), "Invalid token");
        
        // decode recipient address
        address recipient = abi.decode(userData, (address));
        
        // calculate fee
        uint256 fee = (amount * FEE_RATE) / 1000;
        uint256 remaining = amount - fee;
        
        // record fee
        processingFees[from] += fee;
        
        // forward token
        paymentToken.send(recipient, remaining, "");
    }
}