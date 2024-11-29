// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {UUPSUpgradeable} from "../base/UUPSUpgradeable.sol";

/**
 * @title Example Implementation V1
 */
contract ExampleImplementationV1 is UUPSUpgradeable {
    uint256 public value;
    bool private initialized;

    modifier initializer() {
        require(!initialized, "Already initialized");
        _;
        initialized = true;
    }

    function initialize() public initializer {
        value = 0;
    }

    function setValue(uint256 _value) external {
        value = _value;
    }

    function _authorizeUpgrade(address) internal pure override {
        // Anyone can upgrade in this example
    }
}