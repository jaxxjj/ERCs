// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MyToken} from "../src/examples/MyToken.sol";
import {console} from "forge-std/console.sol";

contract DeployMyToken is Script {
    // Config values
    string constant INITIAL_BASE_URI = "ipfs://example.com/";
    address[] INITIAL_WHITELIST = [
        address(0x39CA5312eF96cBF09c43ea7F2eAd639c539BF613)
    ];

    function setUp() public {}

    function run() public {
        // Retrieve deployer private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying MyToken from:", deployer);
        console.log("Network:", block.chainid);

        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy contract
        MyToken token = new MyToken();
        console.log("MyToken deployed to:", address(token));

        // Setup initial configuration
        _setupInitialConfig(token);

        vm.stopBroadcast();

        // Log deployment info
        _logDeploymentInfo(address(token));
    }

    function _setupInitialConfig(MyToken token) internal {
        // Set base URI
        token.setBaseURI(INITIAL_BASE_URI);
        console.log("Base URI set to:", INITIAL_BASE_URI);

        // Add initial whitelist addresses
        for (uint i = 0; i < INITIAL_WHITELIST.length; i++) {
            token.updateWhitelist(INITIAL_WHITELIST[i], true);
        }
        console.log("Added", INITIAL_WHITELIST.length, "addresses to whitelist");

        // Note: Keeping minting disabled initially for safety
        // Enable with separate transaction when ready
        // token.setPublicMintEnabled(true);
    }

    function _logDeploymentInfo(address tokenAddress) internal view {
        console.log("\n=== Deployment Info ===");
        console.log("Network:", block.chainid);
        console.log("Contract:", tokenAddress);
        console.log("Block:", block.number);
        console.log("Timestamp:", block.timestamp);
        console.log("Gas Price:", tx.gasprice);
    }
}