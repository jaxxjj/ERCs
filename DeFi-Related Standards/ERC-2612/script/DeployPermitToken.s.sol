// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/examples/PermitToken.sol";

contract DeployPermitToken is Script {
    function setUp() public {}

    function run() public {

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    
        vm.startBroadcast(deployerPrivateKey);
        PermitToken token = new PermitToken();
    
        console.log("PermitToken deployed to:", address(token));
        vm.stopBroadcast();
    }
} 