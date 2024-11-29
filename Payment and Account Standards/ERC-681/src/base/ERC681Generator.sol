// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ERC681Generator {
    function generatePaymentURL(
        address recipient,
        uint256 value,
        uint256 gasLimit
    ) public pure returns (string memory) {
        return string(
            abi.encodePacked(
                "ethereum:",
                toHexString(recipient),
                "?value=",
                uint2str(value),
                gasLimit > 0 ? string(abi.encodePacked("&gas=", uint2str(gasLimit))) : ""
            )
        );
    }

    // Convert address to hex string
    function toHexString(address addr) internal pure returns (string memory) {
        bytes memory buffer = new bytes(40);
        for(uint256 i = 0; i < 20; i++) {
            bytes1 b = bytes1(uint8(uint160(addr) / (2**(8*(19 - i)))));
            buffer[i*2] = bytes1(uint8(b) / 16 >= 10 ? uint8(b) / 16 + 87 : uint8(b) / 16 + 48);
            buffer[i*2+1] = bytes1(uint8(b) % 16 >= 10 ? uint8(b) % 16 + 87 : uint8(b) % 16 + 48);
        }
        return string(abi.encodePacked("0x", buffer));
    }

    // Convert uint to string
    function uint2str(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint256 k = length;
        j = _i;
        while (j != 0) {
            bstr[--k] = bytes1(uint8(48 + j % 10));
            j /= 10;
        }
        return string(bstr);
    }

    // Encode parameters to URL format
    function _encodeParams(bytes memory params) internal pure returns (string memory) {
        bytes memory encoded = new bytes(params.length * 2);
        bytes memory HEX = "0123456789abcdef";

        for(uint i = 0; i < params.length; i++) {
            encoded[i*2] = HEX[uint8(params[i]) >> 4];
            encoded[i*2+1] = HEX[uint8(params[i]) & 0x0f];
        }

        return string(encoded);
    }

    // Generate contract interaction URL
    function generateContractURL(
        address contract_,
        string memory functionName,
        bytes memory params
    ) public pure returns (string memory) {
        return string(
            abi.encodePacked(
                "ethereum:",
                toHexString(contract_),
                "/",
                functionName,
                "?",
                _encodeParams(params)
            )
        );
    }
}