// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script,console} from "forge-std/Script.sol";
import {RentableNFT} from "../src/examples/RentableNFT.sol";

contract DeployRentableNFT is Script {
    function setUp() public {}

    function run() public returns (RentableNFT) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy RentableNFT
        RentableNFT nft = new RentableNFT();
        
        // Optional: Mint some initial NFTs if needed
        // nft.mint(msg.sender, 1);
        // nft.mint(msg.sender, 2);
        
        vm.stopBroadcast();

        // Log the deployment
        console.log("RentableNFT deployed at:", address(nft));
        
        return nft;
    }
}