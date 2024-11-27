// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../interfaces/IERC777.sol";

contract BatchTransfer {
    function batchTransfer(
        IERC777 token,
        address[] memory recipients,
        uint256[] memory amounts
    ) external {
        // batch transfer by operator
        for(uint i = 0; i < recipients.length; i++) {
            token.operatorSend(msg.sender, recipients[i], amounts[i], "", "");
        }
    }
}