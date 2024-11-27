// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {GameItems} from "../src/examples/GameItems.sol";
import {console2} from "forge-std/console2.sol";

contract DeployGameItems is Script {
    function setUp() public {}

    function run() public returns (GameItems) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console2.log("Deploying GameItems contract with deployer:", deployer);

        vm.startBroadcast(deployerPrivateKey);

        GameItems gameItems = new GameItems();

        vm.stopBroadcast();

        console2.log("GameItems deployed to:", address(gameItems));
        console2.log("Initial items minted to:", deployer);
        
        // Log initial supplies
        console2.log("\nInitial supplies:");
        console2.log("HEALTH_POTION supply:", gameItems.getCurrentSupply(gameItems.HEALTH_POTION()));
        console2.log("MANA_POTION supply:", gameItems.getCurrentSupply(gameItems.MANA_POTION()));
        console2.log("LEGENDARY_SWORD supply:", gameItems.getCurrentSupply(gameItems.LEGENDARY_SWORD()));
        console2.log("DRAGON_SCALE_ARMOR supply:", gameItems.getCurrentSupply(gameItems.DRAGON_SCALE_ARMOR()));
        console2.log("MAGIC_SCROLL supply:", gameItems.getCurrentSupply(gameItems.MAGIC_SCROLL()));

        return gameItems;
    }
}