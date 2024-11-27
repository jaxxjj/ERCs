// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {MyNFT} from "../src/examples/MyNFT.sol";


contract DeployMyNFT is Script {
    // Configuration
    string constant NFT_NAME = "My NFT Collection";
    string constant NFT_SYMBOL = "MNFT";
    string constant BASE_URI = "ipfs://QmYourBaseURI/";
    uint96 constant ROYALTY_FEE = 500; // 5%

    function setUp() public {}

    function run() public {
        // Get deployment private key
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        
        // Get royalty receiver from env or use deployer
        address royaltyReceiver = vm.envOr("ROYALTY_RECEIVER", deployer);

        console.log("Deploying MyNFT from:", deployer);
        console.log("Network:", block.chainid);
        console.log("Royalty Receiver:", royaltyReceiver);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy contract
        MyNFT nft = new MyNFT(
            NFT_NAME,
            NFT_SYMBOL,
            BASE_URI,
            royaltyReceiver,
            ROYALTY_FEE
        );

        // Enable minting if specified in environment
        if (vm.envOr("ENABLE_MINTING", false)) {
            nft.setMintingEnabled(true);
            console.log("Minting enabled");
        }

        vm.stopBroadcast();

        _logDeploymentInfo(address(nft));
        _logNetworkInfo();
    }

    function _logDeploymentInfo(address nftAddress) internal view {
        console.log("\n=== Deployment Info ===");
        console.log("NFT Contract:", nftAddress);
        console.log("Name:", NFT_NAME);
        console.log("Symbol:", NFT_SYMBOL);
        console.log("Base URI:", BASE_URI);
        console.log("Royalty Fee:", ROYALTY_FEE, "basis points");
    }

    function _logNetworkInfo() internal view {
        console.log("\n=== Network Info ===");
        console.log("Chain ID:", block.chainid);
        console.log("Network:", _getNetworkName());
        console.log("Block:", block.number);
        console.log("Timestamp:", block.timestamp);
    }

    function _getNetworkName() internal view returns (string memory) {
        if (block.chainid == 1) return "Ethereum Mainnet";
        if (block.chainid == 5) return "Goerli";
        if (block.chainid == 11155111) return "Sepolia";
        if (block.chainid == 137) return "Polygon";
        if (block.chainid == 80001) return "Mumbai";
        if (block.chainid == 42161) return "Arbitrum One";
        if (block.chainid == 421613) return "Arbitrum Goerli";
        return "Unknown";
    }
}