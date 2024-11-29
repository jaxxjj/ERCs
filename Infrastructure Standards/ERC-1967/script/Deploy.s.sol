// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/base/ERC1967Proxy.sol";
import "../src/examples/ExampleImplementationV1.sol";

contract DeployScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        // Deploy implementation V1
        ExampleImplementationV1 implementationV1 = new ExampleImplementationV1();
        console.log("ImplementationV1 deployed at:", address(implementationV1));

        // Initialize implementation
        implementationV1.initialize();

        // Deploy proxy
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(implementationV1),
            ""  // No initialization data needed as we already initialized
        );
        console.log("Proxy deployed at:", address(proxy));

        // Get admin (should be deployer)
        address admin = proxy.admin();
        console.log("Admin set as:", admin);
        require(admin == deployer, "Admin not set correctly");

        vm.stopBroadcast();

        // Save deployment addresses
        string memory deploymentData = string(
            abi.encodePacked(
                "PROXY_ADDRESS=", vm.toString(address(proxy)), "\n",
                "IMPLEMENTATION_V1_ADDRESS=", vm.toString(address(implementationV1)), "\n",
                "ADMIN_ADDRESS=", vm.toString(admin), "\n"
            )
        );
        vm.writeFile(".env.deployments", deploymentData);
    }
} 