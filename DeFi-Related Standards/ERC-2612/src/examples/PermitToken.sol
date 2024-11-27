// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../base/ERC2612.sol";

contract PermitToken is ERC2612 {
    constructor() ERC2612("PermitToken", "PT") {
        // Mint some initial supply
        _mint(msg.sender, 1000000 * 10**18);
    }
}