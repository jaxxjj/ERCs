// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ExampleContract} from "../src/examples/ExampleContract.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        // Retrieve private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy ExampleContract
        ExampleContract example = new ExampleContract();
        
        // Log the deployment
        console.log("ExampleContract deployed to:", address(example));

        vm.stopBroadcast();
    }
}