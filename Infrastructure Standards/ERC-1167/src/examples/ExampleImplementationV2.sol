// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ExampleImplementation.sol";

/**
 * @title Example Implementation Contract V2
 */
contract ExampleImplementationV2 is ExampleImplementation {
    // New state variables
    string public description;
    
    // Override initialize to handle new state

    function initialize(address _owner) external override {
        require(!initialized, "Already initialized");
        owner = _owner;
        initialized = true;
        version = 2; 
    }
    
    // New function in V2
    function setDescription(string memory _description) external {
        require(msg.sender == owner, "Not owner");
        description = _description;
    }
}