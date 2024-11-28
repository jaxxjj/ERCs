// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Example Implementation Contract
 */
contract ExampleImplementation {
    address public owner;
    uint256 public value;
    bool public initialized;
    uint256 public version;

    event Upgraded(address indexed implementation);

    // Add virtual keyword to allow override
    function initialize(address _owner) external virtual {
        require(!initialized, "Already initialized");
        owner = _owner;
        initialized = true;
        version = 1; // Initial version
    }

    function setValue(uint256 _value) external {
        require(msg.sender == owner, "Not owner");
        value = _value;
    }

    function getVersion() external view returns (uint256) {
        return version;
    }
}
