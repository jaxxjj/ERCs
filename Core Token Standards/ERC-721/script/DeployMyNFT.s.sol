// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/examples/MyNFT.sol";

contract DeployMyNFT is Script {
    function setUp() public {}

    function run() public returns (MyNFT) {
        vm.startBroadcast();
        
        MyNFT nft = new MyNFT();
        
        console.log("MyNFT deployed to:", address(nft));
        console.log("Name:", nft.name());
        console.log("Symbol:", nft.symbol());
        console.log("Chain ID:", block.chainid);
        
        vm.stopBroadcast();
        
        return nft;
    }
}