// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {IDiamondLoupe} from "../src/interfaces/IDiamondLoupe.sol";
import {IDiamondCut} from "../src/interfaces/IDiamondCut.sol";
import {StorageFacet} from "../src/examples/StorageFacet.sol";
import {AccessControlFacet} from "../src/examples/AccessControlFacet.sol";

contract InteractDiamond is Script {
    address constant DIAMOND = 0xEEceD3e2aE266B46dEcc1627D31855CdCDB02524;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // First, let's check what facets are installed
        _checkFacets();

        // Test Storage Facet
        _testStorageFacet();

        // Test Access Control Facet
        _testAccessControlFacet();

        vm.stopBroadcast();
    }

    function _checkFacets() internal {
        IDiamondLoupe diamond = IDiamondLoupe(DIAMOND);
        
        // Get all facets
        IDiamondLoupe.Facet[] memory facets = diamond.facets();
        console2.log("Number of facets:", facets.length);
        
        for (uint i = 0; i < facets.length; i++) {
            console2.log("Facet", i, "address:", facets[i].facetAddress);
            bytes4[] memory selectors = facets[i].functionSelectors;
            console2.log("Number of functions:", selectors.length);
            
            for (uint j = 0; j < selectors.length; j++) {
                console2.log("  Function selector:", vm.toString(selectors[j]));
            }
        }
    }

    function _testStorageFacet() internal {
        StorageFacet storageFacet = StorageFacet(DIAMOND);
        
        // Test setValue/getValue
        console2.log("\nTesting Storage Facet:");
        console2.log("Initial value:", storageFacet.getValue());
        
        storageFacet.setValue(42);
        console2.log("After setValue(42):", storageFacet.getValue());
        
        // Test setMessage/getMessage
        console2.log("Initial message:", storageFacet.getMessage());
        
        storageFacet.setMessage("Hello from interaction script!");
        console2.log("After setMessage:", storageFacet.getMessage());
    }

    function _testAccessControlFacet() internal {
        AccessControlFacet access = AccessControlFacet(DIAMOND);
        
        console2.log("\nTesting Access Control Facet:");
        
        // Add a new admin
        address newAdmin = address(0x123);
        try access.addAdmin(newAdmin) {
            console2.log("Successfully added new admin:", newAdmin);
            
            // Test method access
            bytes4 selector = StorageFacet.setValue.selector;
            access.grantMethodAccess(selector, newAdmin);
            console2.log("Granted setValue access to new admin");
            
            // Remove admin
            access.removeAdmin(newAdmin);
            console2.log("Removed admin:", newAdmin);
        } catch Error(string memory reason) {
            console2.log("Failed to add admin. Reason:", reason);
        }
    }
} 