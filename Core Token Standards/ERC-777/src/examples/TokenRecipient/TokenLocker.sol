// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../../interfaces/IERC777Recipient.sol";
import "../../interfaces/IERC1820Registry.sol";
import "../../interfaces/IERC777.sol";

contract TokenLocker is IERC777Recipient {
    IERC777 public token;
    mapping(address => uint256) public lockedAmount;
    mapping(address => uint256) public lockEndTime;
    
    constructor(address tokenAddress) {
        token = IERC777(tokenAddress);
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24)
            .setInterfaceImplementer(
                address(this),
                keccak256("ERC777TokensRecipient"),
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
        require(msg.sender == address(token), "Invalid token");
        
        // decode lock duration
        uint256 lockDuration = abi.decode(userData, (uint256));
        
        lockedAmount[from] += amount;
        lockEndTime[from] = block.timestamp + lockDuration;
    }
    
    function withdraw() external {
        require(block.timestamp >= lockEndTime[msg.sender], "Still locked");
        require(lockedAmount[msg.sender] > 0, "No locked tokens");
        
        uint256 amount = lockedAmount[msg.sender];
        lockedAmount[msg.sender] = 0;
        
        token.send(msg.sender, amount, "");
    }
}