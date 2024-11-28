// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/examples/ExampleImplementation.sol";
import "../src/examples/ExampleImplementationV2.sol";
import "../src/examples/ExampleFactory.sol";

contract UpgradeScript is Script {
    // Config struct for deployment addresses
    struct DeploymentConfig {
        address factory;
        address implementationV1;
        address implementationV2;
    }

    function run() external {
        // Load deployment configuration
        DeploymentConfig memory config = getConfig();

        // Get deployer private key
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy new V2 implementation if needed
        if (config.implementationV2 == address(0)) {
            ExampleImplementationV2 implementationV2 = new ExampleImplementationV2();
            config.implementationV2 = address(implementationV2);
            console.log("New Implementation V2 deployed to:", address(implementationV2));
        }

        // Get factory instance
        ExampleFactory factory = ExampleFactory(config.factory);

        // Upgrade factory implementation
        factory.upgradeImplementation(config.implementationV2);
        console.log("Factory implementation upgraded to V2");

        // Get all clones
        address[] memory clones = factory.getAllClones();
        console.log("Found", clones.length, "clones to upgrade");

        // Upgrade each clone
        for (uint i = 0; i < clones.length; i++) {
            address clone = clones[i];
            uint256 version = factory.getCloneVersion(clone);
            
            if (version == 1) {
                try factory.upgradeClone(clone) {
                    console.log("Upgraded clone:", clone);
                } catch Error(string memory reason) {
                    console.log("Failed to upgrade clone:", clone);
                    console.log("Reason:", reason);
                }
            }
        }

        vm.stopBroadcast();

        // Log upgrade summary
        console.log("\nUpgrade Summary:");
        console.log("-------------------");
        console.log("Factory:", address(factory));
        console.log("New Implementation:", config.implementationV2);
        console.log("Total Clones:", clones.length);
    }

    function getConfig() internal view returns (DeploymentConfig memory) {
        // Get chain ID
        uint256 chainId = block.chainid;

        if (chainId == 11155111) { // Sepolia
            return DeploymentConfig({
                factory: vm.envAddress("FACTORY_ADDRESS"),
                implementationV1: vm.envAddress("IMPLEMENTATION_V1_ADDRESS"),
                implementationV2: vm.envAddress("IMPLEMENTATION_V2_ADDRESS")
            });
        } else if (chainId == 421611) { // Arbitrum Sepolia
            return DeploymentConfig({
                factory: vm.envAddress("ARB_FACTORY_ADDRESS"),
                implementationV1: vm.envAddress("ARB_IMPLEMENTATION_V1_ADDRESS"),
                implementationV2: vm.envAddress("ARB_IMPLEMENTATION_V2_ADDRESS")
            });
        } else if (chainId == 84532) { // Base Sepolia
            return DeploymentConfig({
                factory: vm.envAddress("BASE_FACTORY_ADDRESS"),
                implementationV1: vm.envAddress("BASE_IMPLEMENTATION_V1_ADDRESS"),
                implementationV2: vm.envAddress("BASE_IMPLEMENTATION_V2_ADDRESS")
            });
        } else {
            revert("Unsupported chain");
        }
    }
} 