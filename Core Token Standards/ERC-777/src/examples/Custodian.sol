// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../interfaces/IERC777.sol";

contract Custodian {
    function manageFunds(IERC777 token, address user, uint256 amount) external {
        // manage user funds as operator
        token.operatorSend(user, address(this), amount, "", "");
    }
}