// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {MyToken} from "../src/examples/ERC777WithHooks.sol";

contract DeployERC777 is Script {
    function setUp() public {}

    function run() public returns (MyToken) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        address[] memory defaultOperators = new address[](1);
        defaultOperators[0] = address(0x39CA5312eF96cBF09c43ea7F2eAd639c539BF613); 


        vm.startBroadcast(deployerPrivateKey);

        // Deploy the token
        MyToken token = new MyToken(
            defaultOperators
        );

        vm.stopBroadcast();

        return token;
    }
}