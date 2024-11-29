// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ERC681Parser {
    struct TransactionRequest {
        address targetAddress;
        uint256 value;
        uint256 gasLimit;
        string functionName;
        bytes parameters;
        bool isContract;
    }

    function parseURL(string memory url) public pure returns (TransactionRequest memory) {
        // Example URLs:
        // Simple payment: ethereum:0x123...?value=100&gas=21000
        // Contract call: ethereum:0x123.../transfer?address=0x456&uint256=100
        
        bytes memory urlBytes = bytes(url);
        require(urlBytes.length > 0, "Invalid URL");

        TransactionRequest memory request;
        
        // Skip "ethereum:" prefix
        uint256 start = 9; // length of "ethereum:"
        
        // Parse target address (ends at '?' or '/')
        uint256 addrEnd = findChar(urlBytes, start, "?/");
        require(addrEnd > start, "Invalid address");
        request.targetAddress = parseAddress(substring(url, start, addrEnd));

        // Check if it's a contract call
        uint256 pos = addrEnd;
        if (pos < urlBytes.length && urlBytes[pos] == '/') {
            request.isContract = true;
            // Parse function name
            start = pos + 1;
            pos = findChar(urlBytes, start, "?");
            request.functionName = substring(url, start, pos);
        }

        // Parse parameters
        if (pos < urlBytes.length && urlBytes[pos] == '?') {
            parseParams(substring(url, pos + 1, urlBytes.length), request);
        }

        return request;
    }

    // Helper function to find character position
    function findChar(bytes memory str, uint256 start, string memory chars) private pure returns (uint256) {
        bytes memory searchChars = bytes(chars);
        for (uint256 i = start; i < str.length; i++) {
            for (uint256 j = 0; j < searchChars.length; j++) {
                if (str[i] == searchChars[j]) {
                    return i;
                }
            }
        }
        return str.length;
    }

    // Helper to get substring
    function substring(string memory str, uint256 start, uint256 end) private pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(end - start);
        for(uint i = start; i < end; i++) {
            result[i - start] = strBytes[i];
        }
        return string(result);
    }

    // Parse address from hex string
    function parseAddress(string memory hexString) private pure returns (address) {
        bytes memory tmp = bytes(hexString);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 40; i += 2) {
            b1 = uint160(hexCharToUint(uint8(tmp[i])));
            b2 = uint160(hexCharToUint(uint8(tmp[i + 1])));
            iaddr = iaddr * 256 + ((b1 * 16 + b2));
        }
        return address(iaddr);
    }

    // Convert hex character to uint
    function hexCharToUint(uint8 c) private pure returns (uint8) {
        if (c >= 48 && c <= 57) return c - 48; // 0-9
        if (c >= 97 && c <= 102) return c - 87; // a-f
        if (c >= 65 && c <= 70) return c - 55; // A-F
        revert("Invalid hex character");
    }

    // Parse URL parameters
    function parseParams(string memory params, TransactionRequest memory request) private pure {
        bytes memory paramBytes = bytes(params);
        uint256 pos = 0;
        
        while (pos < paramBytes.length) {
            // Find parameter name end
            uint256 nameEnd = findChar(paramBytes, pos, "=");
            string memory name = substring(params, pos, nameEnd);
            
            // Find parameter value end
            pos = nameEnd + 1;
            uint256 valueEnd = findChar(paramBytes, pos, "&");
            string memory value = substring(params, pos, valueEnd);

            // Set appropriate parameter
            if (equals(name, "value")) {
                request.value = parseUint(value);
            } else if (equals(name, "gas")) {
                request.gasLimit = parseUint(value);
            }
            
            pos = valueEnd + 1;
        }
    }

    // Compare strings
    function equals(string memory a, string memory b) private pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    // Parse uint from string
    function parseUint(string memory s) private pure returns (uint256) {
        bytes memory b = bytes(s);
        uint256 result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            require(uint8(b[i]) >= 48 && uint8(b[i]) <= 57, "Invalid number");
            result = result * 10 + (uint8(b[i]) - 48);
        }
        return result;
    }
}