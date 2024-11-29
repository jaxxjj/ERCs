// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/base/ERC1967Proxy.sol";
import "../src/examples/ExampleImplementationV2.sol";

contract UpgradeScript is Script {
    function run() external {
        // Read deployment addresses
        string memory deploymentFile = vm.readFile(".env.deployments");
        address proxyAddress = _parseAddress(deploymentFile, "PROXY_ADDRESS=");
        address adminAddress = _parseAddress(deploymentFile, "ADMIN_ADDRESS=");
        
        console.log("Proxy address:", proxyAddress);
        console.log("Admin address:", adminAddress);

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        require(deployer == adminAddress, "Deployer is not admin");

        vm.startBroadcast(deployerPrivateKey);

        // Get proxy instance
        ERC1967Proxy proxy = ERC1967Proxy(payable(proxyAddress));

        // Deploy new implementation
        ExampleImplementationV2 implementationV2 = new ExampleImplementationV2();
        console.log("ImplementationV2 deployed at:", address(implementationV2));

        // Initialize V2 implementation
        implementationV2.initializeV2();

        // Upgrade proxy to V2 (no initialization needed as we already initialized)
        proxy.upgradeTo(address(implementationV2));
        console.log("Proxy upgraded to V2");

        // Verify upgrade
        address newImpl = proxy.getImplementation();
        require(newImpl == address(implementationV2), "Upgrade failed");

        vm.stopBroadcast();

        // Update deployment addresses
        string memory deploymentData = string(
            abi.encodePacked(
                deploymentFile,
                "IMPLEMENTATION_V2_ADDRESS=", vm.toString(address(implementationV2)), "\n"
            )
        );
        vm.writeFile(".env.deployments", deploymentData);
    }

    function _parseAddress(string memory file, string memory key) internal pure returns (address) {
        // Find the key in the file
        bytes memory fileBytes = bytes(file);
        bytes memory keyBytes = bytes(key);
        
        uint256 start;
        for (uint256 i = 0; i < fileBytes.length - keyBytes.length; i++) {
            bool found = true;
            for (uint256 j = 0; j < keyBytes.length; j++) {
                if (fileBytes[i + j] != keyBytes[j]) {
                    found = false;
                    break;
                }
            }
            if (found) {
                start = i + keyBytes.length;
                break;
            }
        }
        
        // Read until newline
        bytes memory valueBytes = new bytes(42); // Address is 42 chars with 0x
        for (uint256 i = 0; i < 42; i++) {
            valueBytes[i] = fileBytes[start + i];
        }
        
        return _hexToAddress(string(valueBytes));
    }

    function _hexToAddress(string memory s) internal pure returns (address) {
        bytes memory ss = bytes(s);
        require(ss.length == 42 && ss[0] == '0' && ss[1] == 'x', "Invalid address format");
        
        uint160 result = 0;
        for (uint256 i = 2; i < ss.length; i++) {
            uint8 digit;
            if (uint8(ss[i]) >= 48 && uint8(ss[i]) <= 57) {
                digit = uint8(ss[i]) - 48;
            } else if (uint8(ss[i]) >= 65 && uint8(ss[i]) <= 70) {
                digit = uint8(ss[i]) - 55;
            } else if (uint8(ss[i]) >= 97 && uint8(ss[i]) <= 102) {
                digit = uint8(ss[i]) - 87;
            } else {
                revert("Invalid hex character");
            }
            result = result * 16 + digit;
        }
        return address(result);
    }
} 