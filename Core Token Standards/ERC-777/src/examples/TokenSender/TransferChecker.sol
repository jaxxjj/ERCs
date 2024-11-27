// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../../interfaces/IERC777Sender.sol";
import "../../interfaces/IERC1820Registry.sol";

contract TransferChecker is IERC777Sender {
    mapping(address => bool) public blacklist;
    address public admin;

    constructor() {
        admin = msg.sender;
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
        require(!blacklist[from], "Sender blacklisted");
        require(!blacklist[to], "Recipient blacklisted");
    }

    function setBlacklist(address user, bool status) external {
        require(msg.sender == admin, "Only admin");
        blacklist[user] = status;
    }
}