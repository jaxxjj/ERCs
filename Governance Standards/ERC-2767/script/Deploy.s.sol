// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script,console2} from "forge-std/Script.sol";
import {ERC2767Governance} from "../src/base/ERC2767.sol";
import {MockToken} from "../test/unit/ERC2767.t.sol";

contract DeployERC2767 is Script {
    // Configuration
    uint256 public constant INITIAL_QUORUM = 70; // 70% quorum requirement
    uint256 public constant GOVERNOR_POWER = 40; // Equal voting power for each governor

    function run() external {
        // Get deployment private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Start broadcast
        vm.startBroadcast(deployerPrivateKey);

        // Deploy mock token first (for testing)
        MockToken token = new MockToken();

        // Setup initial governors (example with 3 governors)
        address[] memory governors = new address[](3);
        governors[0] = vm.envAddress("GOVERNOR_1");
        governors[1] = vm.envAddress("GOVERNOR_2");
        governors[2] = vm.envAddress("GOVERNOR_3");

        // Setup initial voting powers
        uint256[] memory powers = new uint256[](3);
        powers[0] = GOVERNOR_POWER;
        powers[1] = GOVERNOR_POWER;
        powers[2] = GOVERNOR_POWER;

        // Deploy governance contract
        ERC2767Governance governance = new ERC2767Governance(
            governors,
            powers,
            INITIAL_QUORUM,
            address(token)
        );

        // End broadcast
        vm.stopBroadcast();

        // Log deployment information
        console2.log("Deployment Summary:");
        console2.log("------------------");
        console2.log("Token deployed to:", address(token));
        console2.log("Governance deployed to:", address(governance));
        console2.log("Initial governors:");
        console2.log("- Governor 1:", governors[0]);
        console2.log("- Governor 2:", governors[1]);
        console2.log("- Governor 3:", governors[2]);
        console2.log("Quorum requirement:", INITIAL_QUORUM);
        console2.log("Individual voting power:", GOVERNOR_POWER);
    }
}