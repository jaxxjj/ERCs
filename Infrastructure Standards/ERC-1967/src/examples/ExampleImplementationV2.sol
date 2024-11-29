// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {UUPSUpgradeable} from "../base/UUPSUpgradeable.sol";

/**
 * @title Example Implementation V2
 */
contract ExampleImplementationV2 is UUPSUpgradeable {
    uint256 public value;
    address private owner;
    mapping(address => bool) public whitelist;

    // Added functionality in V2
    function addToWhitelist(address account) external {
        require(msg.sender == owner, "Not owner");
        whitelist[account] = true;
    }

    function setValue(uint256 _value) external {
        require(msg.sender == owner || whitelist[msg.sender], "Not authorized");
        value = _value;
    }

    function _authorizeUpgrade(address) internal view override {
        require(msg.sender == owner, "Not owner");
    }
}