// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/examples/ExampleImplementation.sol";
import "../../src/examples/ExampleFactory.sol";

contract ExampleTest is Test {
    ExampleImplementation public implementation;
    ExampleFactory public factory;
    
    address public owner;
    address public user;
    bytes32 public constant SALT = bytes32(uint256(1));

    event CloneCreated(address indexed clone, address indexed owner);

    function setUp() public {
        // Set up accounts
        owner = makeAddr("owner");
        user = makeAddr("user");

        // Deploy implementation
        implementation = new ExampleImplementation();
        
        // Deploy factory
        factory = new ExampleFactory(address(implementation));
    }

    function testImplementationInitialization() public {
        // Direct initialization of implementation
        implementation.initialize(owner);
        
        // Verify state
        assertEq(implementation.owner(), owner);
        assertTrue(implementation.initialized());
        assertEq(implementation.value(), 0);
    }

    function testDoubleInitialization() public {
        implementation.initialize(owner);
        vm.expectRevert("Already initialized");
        implementation.initialize(user);
    }

    function testCreateNewClone() public {

        address cloneAddress = factory.createNewClone(owner);
        
        // Verify clone creation
        assertTrue(factory.isClone(cloneAddress));
        assertEq(factory.clones(0), cloneAddress);
        
        // Verify clone state
        ExampleImplementation clone = ExampleImplementation(cloneAddress);
        assertEq(clone.owner(), owner);
        assertTrue(clone.initialized());
    }

    function testCreateDeterministicClone() public {
        // Predict address
        address predicted = factory.predictCloneAddress(SALT);
        
        // Create deterministic clone
        vm.expectEmit(true, true, false, true);
        emit CloneCreated(predicted, owner);
        
        address cloneAddress = factory.createDeterministicClone(owner, SALT);
        
        // Verify address matches prediction
        assertEq(cloneAddress, predicted);
        
        // Verify clone creation
        assertTrue(factory.isClone(cloneAddress));
        assertEq(factory.clones(0), cloneAddress);
        
        // Verify clone state
        ExampleImplementation clone = ExampleImplementation(cloneAddress);
        assertEq(clone.owner(), owner);
        assertTrue(clone.initialized());
    }

    function testDuplicateDeterministicClone() public {
        // Create first clone
        factory.createDeterministicClone(owner, SALT);
        
        // Attempt to create clone with same salt
        vm.expectRevert("Create2 failed");
        factory.createDeterministicClone(user, SALT);
    }

    function testCloneSetValue() public {
        // Create and get clone
        address cloneAddress = factory.createNewClone(owner);
        ExampleImplementation clone = ExampleImplementation(cloneAddress);
        
        // Set value as owner
        vm.prank(owner);
        clone.setValue(100);
        assertEq(clone.value(), 100);
    }

    function testNonOwnerSetValue() public {
        // Create and get clone
        address cloneAddress = factory.createNewClone(owner);
        ExampleImplementation clone = ExampleImplementation(cloneAddress);
        
        // Attempt to set value as non-owner
        vm.prank(user);
        vm.expectRevert("Not owner");
        clone.setValue(100);
    }

    function testGetAllClones() public {
        // Create multiple clones
        address clone1 = factory.createNewClone(owner);
        address clone2 = factory.createNewClone(user);
        address clone3 = factory.createDeterministicClone(owner, SALT);
        
        // Get all clones
        address[] memory allClones = factory.getAllClones();
        
        // Verify list
        assertEq(allClones.length, 3);
        assertEq(allClones[0], clone1);
        assertEq(allClones[1], clone2);
        assertEq(allClones[2], clone3);
    }

    function testPredictCloneAddress() public {
        // Get prediction
        address predicted = factory.predictCloneAddress(SALT);
        
        // Create clone
        address actual = factory.createDeterministicClone(owner, SALT);
        
        // Verify prediction
        assertEq(actual, predicted);
    }

    function testImplementationIsolation() public {
        // Create two clones
        address clone1 = factory.createNewClone(owner);
        address clone2 = factory.createNewClone(user);
        
        // Set value in first clone
        vm.prank(owner);
        ExampleImplementation(clone1).setValue(100);
        
        // Set value in second clone
        vm.prank(user);
        ExampleImplementation(clone2).setValue(200);
        
        // Verify values are independent
        assertEq(ExampleImplementation(clone1).value(), 100);
        assertEq(ExampleImplementation(clone2).value(), 200);
        assertEq(implementation.value(), 0);
    }
}