// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC6372} from "../interfaces/IERC6372.sol";

/**
 * @title Block Number Based ERC6372
 * @dev Alternative implementation using block numbers instead of timestamps
 */
contract BlockNumberERC6372 is IERC6372 {
    function clock() public view virtual returns (uint48) {
        return uint48(block.number);
    }

    function CLOCK_MODE() public view virtual returns (string memory) {
        return "mode=block";
    }
}