// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {UUPSUpgradeable} from "../base/UUPSUpgradeable.sol";

/**
 * @title Example Implementation V1
 */
contract ExampleImplementationV1 is UUPSUpgradeable {
    uint256 public value;
    address private owner;

    // Initializer modifier ensures function can only be called once
    modifier initializer() {
        require(!_isInitialized(), "Already initialized");
        _;
        _setInitialized();
    }

    function initialize(address _owner) public initializer {
        owner = _owner;
    }

    function setValue(uint256 _value) external {
        require(msg.sender == owner, "Not owner");
        value = _value;
    }

    function _authorizeUpgrade(address) internal view override {
        require(msg.sender == owner, "Not owner");
    }

    function _isInitialized() internal view returns (bool) {
        return owner != address(0);
    }

    function _setInitialized() private {
        require(owner == address(0), "Already initialized");
        owner = msg.sender;
    }
}