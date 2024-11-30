// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../lib/LibAppStorage.sol";

/**
 * @title DiamondInit
 * @dev Handles initialization of diamond storage
 */
contract DiamondInit {
    using LibAppStorage for LibAppStorage.AppStorage;

    struct Args {
        string initialMessage;
        address initialAdmin;
    }

    function init(Args memory _args) external {
        LibAppStorage.AppStorage storage ds = LibAppStorage.diamondStorage();
        
        // Initialize storage values
        ds.value = 0;
        ds.message = _args.initialMessage;
        ds.admins[_args.initialAdmin] = true;
    }
}