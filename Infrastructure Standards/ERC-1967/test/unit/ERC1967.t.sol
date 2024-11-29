// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/base/ERC1967Proxy.sol";
import "../../src/examples/ExampleImplementationV1.sol";
import "../../src/examples/ExampleImplementationV2.sol";
import "../../lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";

contract ERC1967Test is Test {
    ERC1967Proxy public proxy;
    ExampleImplementationV1 public implementationV1;
    ExampleImplementationV2 public implementationV2;
    address public owner;
    address public user;

    function setUp() public {
        owner = address(this);
        user = address(0x1);
        vm.deal(user, 100 ether);

        // Deploy implementations
        implementationV1 = new ExampleImplementationV1();
        implementationV2 = new ExampleImplementationV2();

        // Initialize V1
        implementationV1.initialize();

        // Deploy proxy pointing to V1
        proxy = new ERC1967Proxy(
            address(implementationV1),
            ""  // No initialization data as we already initialized V1
        );
    }

    function test_InitialDeployment() public {
        ExampleImplementationV1 proxiedContract = ExampleImplementationV1(address(proxy));
        assertEq(proxiedContract.value(), 0);
        assertEq(proxy.getImplementation(), address(implementationV1));
    }

    function test_SetValue() public {
        ExampleImplementationV1 proxiedContract = ExampleImplementationV1(address(proxy));
        proxiedContract.setValue(42);
        assertEq(proxiedContract.value(), 42);
    }

    function test_UpgradeToV2() public {
        // Initialize V2
        implementationV2.initializeV2();

        // Upgrade to V2
        proxy.upgradeTo(address(implementationV2));
        assertEq(proxy.getImplementation(), address(implementationV2));

        // Test V2 functionality
        ExampleImplementationV2 proxiedV2 = ExampleImplementationV2(address(proxy));
        proxiedV2.addToWhitelist(user);
        assertTrue(proxiedV2.whitelist(user));
    }

    function test_RevertUnauthorizedUpgrade() public {
        vm.prank(user);
        vm.expectRevert("Not authorized");
        proxy.upgradeTo(address(implementationV2));
    }

    function test_StoragePreservation() public {
        // Set value in V1
        ExampleImplementationV1 proxiedV1 = ExampleImplementationV1(address(proxy));
        proxiedV1.setValue(42);
        
        // Initialize V2
        implementationV2.initializeV2();
        
        // Upgrade to V2
        proxy.upgradeTo(address(implementationV2));
        
        // Check value preservation
        ExampleImplementationV2 proxiedV2 = ExampleImplementationV2(address(proxy));
        assertEq(proxiedV2.value(), 42);
    }

    function test_RevertInvalidImplementation() public {
        // Test with non-contract address
        address invalidImpl = address(0x123);
        
        vm.expectRevert(
            abi.encodeWithSelector(
                ERC1967Utils.ERC1967InvalidImplementation.selector,
                invalidImpl
            )
        );
        proxy.upgradeTo(invalidImpl);
    }

    function test_AdminAccess() public {
        // Get current admin
        address currentAdmin = proxy.admin();
        assertEq(currentAdmin, address(this));
        
        // Change admin
        address newAdmin = address(0x123);
        proxy.changeAdmin(newAdmin);
        
        // Verify admin changed
        assertEq(proxy.admin(), newAdmin);
        
        // Try upgrade with old admin (should fail)
        vm.expectRevert("Not authorized");
        proxy.upgradeTo(address(implementationV2));
        
        // Upgrade with new admin (should work)
        vm.prank(newAdmin);
        proxy.upgradeTo(address(implementationV2));
        assertEq(proxy.getImplementation(), address(implementationV2));
    }

    function test_UpgradeToAndCall() public {
        // Prepare initialization data
        bytes memory initData = abi.encodeWithSelector(
            ExampleImplementationV2.initializeV2.selector
        );

        // Upgrade and initialize in one transaction
        proxy.upgradeToAndCall(address(implementationV2), initData);
        
        // Verify upgrade
        assertEq(proxy.getImplementation(), address(implementationV2));
        
        // Test V2 functionality
        ExampleImplementationV2 proxiedV2 = ExampleImplementationV2(address(proxy));
        proxiedV2.addToWhitelist(user);
        assertTrue(proxiedV2.whitelist(user));
    }

    receive() external payable {}
}