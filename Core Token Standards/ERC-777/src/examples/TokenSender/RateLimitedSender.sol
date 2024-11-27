// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../../interfaces/IERC777Sender.sol";
import "../../interfaces/IERC1820Registry.sol";

contract RateLimitedSender is IERC777Sender {
    mapping(address => uint256) private lastTransferTime;
    uint256 constant COOLDOWN = 1 hours;

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
        require(
            block.timestamp >= lastTransferTime[from] + COOLDOWN,
            "Transfer too frequent"
        );
        lastTransferTime[from] = block.timestamp;
    }
}