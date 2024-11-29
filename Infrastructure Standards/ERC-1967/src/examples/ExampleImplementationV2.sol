// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {UUPSUpgradeable} from "../base/UUPSUpgradeable.sol";

/**
 * @title Example Implementation V2
 */
contract ExampleImplementationV2 is UUPSUpgradeable {
    uint256 public value;
    mapping(address => bool) public whitelist;
    bool private initialized;

    modifier initializer() {
        require(!initialized, "Already initialized");
        _;
        initialized = true;
    }

    function initializeV2() public initializer {
        // No need to set value as it's preserved from V1
    }

    function setValue(uint256 _value) external {
        value = _value;
    }

    function addToWhitelist(address _address) external {
        whitelist[_address] = true;
    }

    function _authorizeUpgrade(address) internal pure override {
        // Anyone can upgrade in this example
    }
}