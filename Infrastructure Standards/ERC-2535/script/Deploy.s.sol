// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {Diamond} from "../src/base/Diamond.sol";
import {DiamondCutFacet} from "../src/examples/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../src/examples/DiamondLoupeFacet.sol";
import {StorageFacet} from "../src/examples/StorageFacet.sol";
import {AccessControlFacet} from "../src/examples/AccessControlFacet.sol";
import {DiamondInit} from "../src/examples/DiamondInit.sol";
import {IDiamondCut} from "../src/interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "../src/interfaces/IDiamondLoupe.sol";


contract DeployDiamond is Script {
    Diamond public diamond;
    DiamondCutFacet public diamondCut;
    DiamondLoupeFacet public diamondLoupe;
    StorageFacet public storageFacet;
    AccessControlFacet public accessControl;
    DiamondInit public diamondInit;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address owner = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy all facets
        diamondCut = new DiamondCutFacet();
        console2.log("DiamondCutFacet deployed at:", address(diamondCut));

        diamondLoupe = new DiamondLoupeFacet();
        console2.log("DiamondLoupeFacet deployed at:", address(diamondLoupe));

        storageFacet = new StorageFacet();
        console2.log("StorageFacet deployed at:", address(storageFacet));

        accessControl = new AccessControlFacet();
        console2.log("AccessControlFacet deployed at:", address(accessControl));

        diamondInit = new DiamondInit();
        console2.log("DiamondInit deployed at:", address(diamondInit));

        // Create initial facet cuts
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        
        // Add DiamondCutFacet
        bytes4[] memory cutSelectors = new bytes4[](1);
        cutSelectors[0] = IDiamondCut.diamondCut.selector;
        cuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(diamondCut),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: cutSelectors
        });

        // Deploy diamond with initial facets
        diamond = new Diamond(
            owner,
            cuts,
            address(0), // No initialization needed for first deployment
            new bytes(0)
        );
        console2.log("Diamond deployed at:", address(diamond));

        // Add remaining facets
        _addRemainingFacets(owner);

        vm.stopBroadcast();
    }

    function _addRemainingFacets(address owner) internal {
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](3);

        // DiamondLoupeFacet
        bytes4[] memory loupeSelectors = new bytes4[](4);
        loupeSelectors[0] = IDiamondLoupe.facets.selector;
        loupeSelectors[1] = IDiamondLoupe.facetFunctionSelectors.selector;
        loupeSelectors[2] = IDiamondLoupe.facetAddresses.selector;
        loupeSelectors[3] = IDiamondLoupe.facetAddress.selector;
        cuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(diamondLoupe),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: loupeSelectors
        });

        // StorageFacet
        bytes4[] memory storageSelectors = new bytes4[](4);
        storageSelectors[0] = StorageFacet.setValue.selector;
        storageSelectors[1] = StorageFacet.getValue.selector;
        storageSelectors[2] = StorageFacet.setMessage.selector;
        storageSelectors[3] = StorageFacet.getMessage.selector;
        cuts[1] = IDiamondCut.FacetCut({
            facetAddress: address(storageFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: storageSelectors
        });

        // AccessControlFacet
        bytes4[] memory accessSelectors = new bytes4[](4);
        accessSelectors[0] = AccessControlFacet.addAdmin.selector;
        accessSelectors[1] = AccessControlFacet.removeAdmin.selector;
        accessSelectors[2] = AccessControlFacet.grantMethodAccess.selector;
        accessSelectors[3] = AccessControlFacet.revokeMethodAccess.selector;
        cuts[2] = IDiamondCut.FacetCut({
            facetAddress: address(accessControl),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: accessSelectors
        });

        // Initialize diamond with remaining facets
        DiamondInit.Args memory args = DiamondInit.Args({
            initialMessage: "Hello Diamond",
            initialAdmin: owner
        });
        bytes memory initData = abi.encodeWithSelector(
            DiamondInit.init.selector,
            args
        );

        IDiamondCut(address(diamond)).diamondCut(cuts, address(diamondInit), initData);
    }

}