// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Diamond} from "../../src/base/Diamond.sol";
import {DiamondCutFacet} from "../../src/examples/DiamondCutFacet.sol";
import {DiamondLoupeFacet} from "../../src/examples/DiamondLoupeFacet.sol";
import {StorageFacet} from "../../src/examples/StorageFacet.sol";
import {AccessControlFacet} from "../../src/examples/AccessControlFacet.sol";
import {DiamondInit} from "../../src/examples/DiamondInit.sol";
import {IDiamondCut} from "../../src/interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "../../src/interfaces/IDiamondLoupe.sol";

contract DiamondTest is Test {
    Diamond public diamond;
    DiamondCutFacet public diamondCut;
    DiamondLoupeFacet public diamondLoupe;
    StorageFacet public storageFacet;
    AccessControlFacet public accessControl;
    DiamondInit public diamondInit;
    
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        // Deploy facets first
        diamondCut = new DiamondCutFacet();
        diamondLoupe = new DiamondLoupeFacet();
        storageFacet = new StorageFacet();
        accessControl = new AccessControlFacet();
        diamondInit = new DiamondInit();

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

        vm.startPrank(owner);
        
        // Now add remaining facets
        _addRemainingFacets();
        
        vm.stopPrank();
    }

    function _addRemainingFacets() internal {
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

    function test_DiamondCut() public {
        IDiamondLoupe.Facet[] memory facets = IDiamondLoupe(address(diamond)).facets();
        assertEq(facets.length, 4); // DiamondCut, DiamondLoupe, Storage, AccessControl
    }

    function test_StorageFacet() public {
        // Test setValue/getValue
        StorageFacet(address(diamond)).setValue(42);
        assertEq(StorageFacet(address(diamond)).getValue(), 42);

        // Test setMessage/getMessage
        StorageFacet(address(diamond)).setMessage("New Message");
        assertEq(StorageFacet(address(diamond)).getMessage(), "New Message");
    }

    function test_AccessControl() public {
        vm.startPrank(owner);
        
        // Test admin management
        AccessControlFacet(address(diamond)).addAdmin(user1);
        AccessControlFacet(address(diamond)).grantMethodAccess(
            StorageFacet.setValue.selector,
            user1
        );

        vm.stopPrank();
        vm.startPrank(user1);

        // Test access control
        StorageFacet(address(diamond)).setValue(100);
        assertEq(StorageFacet(address(diamond)).getValue(), 100);

        vm.stopPrank();
    }

    function testFail_UnauthorizedAccess() public {
        vm.prank(user2);
        AccessControlFacet(address(diamond)).addAdmin(user2);
    }

    function test_DiamondLoupe() public {
        // Test facet addresses
        address[] memory addresses = IDiamondLoupe(address(diamond)).facetAddresses();
        assertEq(addresses.length, 4);

        // Test facet function selectors
        bytes4[] memory selectors = IDiamondLoupe(address(diamond)).facetFunctionSelectors(address(storageFacet));
        assertEq(selectors.length, 4);

        // Test facet address for function
        address facetAddress = IDiamondLoupe(address(diamond)).facetAddress(StorageFacet.setValue.selector);
        assertEq(facetAddress, address(storageFacet));
    }

    function test_ReplaceFacet() public {
        vm.startPrank(owner);

        // Deploy new storage facet
        StorageFacet newStorageFacet = new StorageFacet();

        // Replace storage facet
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        bytes4[] memory selectors = new bytes4[](4);
        selectors[0] = StorageFacet.setValue.selector;
        selectors[1] = StorageFacet.getValue.selector;
        selectors[2] = StorageFacet.setMessage.selector;
        selectors[3] = StorageFacet.getMessage.selector;

        cuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(newStorageFacet),
            action: IDiamondCut.FacetCutAction.Replace,
            functionSelectors: selectors
        });

        IDiamondCut(address(diamond)).diamondCut(cuts, address(0), "");

        // Verify replacement
        address facetAddress = IDiamondLoupe(address(diamond)).facetAddress(StorageFacet.setValue.selector);
        assertEq(facetAddress, address(newStorageFacet));

        vm.stopPrank();
    }

    function test_RemoveFacet() public {
        vm.startPrank(owner);

        // Remove storage facet
        IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
        bytes4[] memory selectors = new bytes4[](4);
        selectors[0] = StorageFacet.setValue.selector;
        selectors[1] = StorageFacet.getValue.selector;
        selectors[2] = StorageFacet.setMessage.selector;
        selectors[3] = StorageFacet.getMessage.selector;

        cuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(0),
            action: IDiamondCut.FacetCutAction.Remove,
            functionSelectors: selectors
        });

        IDiamondCut(address(diamond)).diamondCut(cuts, address(0), "");

        // Verify removal
        address facetAddress = IDiamondLoupe(address(diamond)).facetAddress(StorageFacet.setValue.selector);
        assertEq(facetAddress, address(0));

        vm.stopPrank();
    }
}