// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/LibAppStorage.sol";

/**
 * @title StorageFacet implementing AppStorage
 */
contract StorageFacet {
    using LibAppStorage for LibAppStorage.AppStorage;

    // Get the storage
    function _storage() internal pure returns (LibAppStorage.AppStorage storage) {
        return LibAppStorage.diamondStorage();
    }

    function setValue(uint256 _value) external {
        _storage().value = _value;
    }

    function getValue() external view returns (uint256) {
        return _storage().value;
    }

    function setMessage(string calldata _message) external {
        _storage().message = _message;
    }

    function getMessage() external view returns (string memory) {
        return _storage().message;
    }
}