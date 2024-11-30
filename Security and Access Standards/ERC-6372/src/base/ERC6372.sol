// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC6372} from "../interfaces/IERC6372.sol";

/**
 * @title ERC6372 Implementation
 * @dev Implementation of the ERC6372 Clock Mode standard
 */
contract ERC6372Implementation is IERC6372 {
    /**
     * @dev Returns the current timepoint according to the mode the contract is operating in
     * For timestamp mode, returns block.timestamp
     * For block number mode, returns block.number
     */
    function clock() public view virtual returns (uint48) {
        return uint48(block.timestamp);
    }

    /**
     * @dev Machine-readable description of the clock as specified in ERC-6372
     * Returns "mode=timestamp" or "mode=block" depending on implementation
     */
    function CLOCK_MODE() public view virtual returns (string memory) {
        return "mode=timestamp";
    }
}

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