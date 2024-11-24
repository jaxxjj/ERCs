// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../base/ERC20.sol";

contract MyToken is ERC20 {
    // Initial supply of 1 million tokens
    uint256 constant INITIAL_SUPPLY = 1_000_000 * 10**18;

    constructor() ERC20("MyToken", "MTK", 18) {
        // Mint initial supply to deployer
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}