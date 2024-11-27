// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script,console} from "forge-std/Script.sol";
import {SecureVault} from "../src/examples/MyVault.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";


contract DeploySecureVault is Script {
    uint256 constant INITIAL_UNDERLYING_BALANCE = 10_000 * 10**18;
    uint256 constant INITIAL_DEPOSIT = 1000 * 10**18;
    bytes32 public constant SALT = bytes32(uint256(1));

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        vm.startBroadcast();

        // Deploy mock token
        ERC20Mock underlying = new ERC20Mock();
        
        // Compute vault deployment address
        bytes memory initCode = abi.encodePacked(
            type(SecureVault).creationCode,
            abi.encode(address(underlying))
        );
        address computedAddress = vm.computeCreate2Address(
            SALT,
            keccak256(initCode),
            deployer
        );
        
        // Deploy vault using create2
        SecureVault vault = new SecureVault{salt: SALT}(underlying);
        
        // Verify create2 deployment
        require(address(vault) == computedAddress, "Create2: deployment address mismatch");

        // Mint initial tokens
        underlying.mint(deployer, INITIAL_UNDERLYING_BALANCE);
        
        // Approve for initial deposit
        underlying.approve(address(vault), INITIAL_DEPOSIT);
        
        vm.stopBroadcast();

        // Log deployment info
        console.log("Underlying Token:", address(underlying));
        console.log("Secure Vault:", address(vault));
        
        // Verify deployment
        require(vault.asset() == address(underlying), "Invalid underlying");
        require(vault.totalAssets() == INITIAL_DEPOSIT, "Invalid initial deposit");
        require(vault.totalSupply() == INITIAL_DEPOSIT, "Invalid initial supply");
    }
}