// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/examples/ExampleImplementation.sol";
import "../src/examples/ExampleFactory.sol";

contract DeployScript is Script {
    function run() external {
        // Get deployment private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy implementation contract
        ExampleImplementation implementation = new ExampleImplementation();
        console.log("Implementation deployed to:", address(implementation));

        // Deploy factory contract
        ExampleFactory factory = new ExampleFactory(address(implementation));
        console.log("Factory deployed to:", address(factory));

        // Create initial clone (optional)
        address initialClone = factory.createNewClone(msg.sender);
        console.log("Initial clone deployed to:", initialClone);

        // Stop broadcasting transactions
        vm.stopBroadcast();

        // Log deployment details for verification
        console.log("\nDeployment Summary:");
        console.log("-------------------");
        console.log("Network:", block.chainid);
        console.log("Implementation:", address(implementation));
        console.log("Factory:", address(factory));
        console.log("Initial Clone:", initialClone);
    }
}