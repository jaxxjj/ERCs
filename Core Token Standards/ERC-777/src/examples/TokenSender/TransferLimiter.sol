// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../../interfaces/IERC777Sender.sol";
import "../../interfaces/IERC1820Registry.sol";

contract TransferLimiter is IERC777Sender {
    mapping(address => uint256) public dailyTransferred;
    mapping(address => uint256) public lastTransferTime;
    uint256 constant DAILY_LIMIT = 1000 * 1e18;

    constructor() {
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24)
            .setInterfaceImplementer(
                address(this),
                keccak256("ERC777TokensSender"),
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
        uint256 currentDay = block.timestamp / 1 days;
        uint256 lastDay = lastTransferTime[from] / 1 days;
        
        if (currentDay > lastDay) {
            dailyTransferred[from] = 0;
        }
        
        require(
            dailyTransferred[from] + amount <= DAILY_LIMIT,
            "Daily limit exceeded"
        );
        
        dailyTransferred[from] += amount;
        lastTransferTime[from] = block.timestamp;
    }
}