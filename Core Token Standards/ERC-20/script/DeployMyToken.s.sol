// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MyToken} from "../src/examples/MyToken.sol";
import {console2} from "forge-std/console2.sol";

contract DeployMyToken is Script {
    function setUp() public {}

    function run() public returns (MyToken) {
        // Begin broadcasting transactions
        vm.startBroadcast();

        // Deploy MyToken
        MyToken token = new MyToken();
        console2.log("Deploying at chain:", block.chainid);
        console2.log("MyToken deployed at:", address(token));
        
        vm.stopBroadcast();
        return token;
    }
} 