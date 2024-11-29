// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {ERC681Parser} from "../base/ERC681Parser.sol";
import {ERC681Generator} from "../base/ERC681Generator.sol";

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract PaymentExecutor is ERC681Generator {
    ERC681Parser public parser;
    mapping(bytes32 => bool) public executedTransactions;

    event PaymentExecuted(address from, address to, uint256 value);
    event ContractCallExecuted(address contract_, string functionName, bytes params);

    constructor() {
        parser = new ERC681Parser();
    }

    function createPaymentRequest(
        uint256 amount, 
        bool isToken, 
        address token
    ) external view returns (string memory) {
        if (isToken) {
            return string(
                abi.encodePacked(
                    "ethereum:",
                    toHexString(token),
                    "/transfer?to=",
                    toHexString(address(this)),
                    "&amount=",
                    uint2str(amount)
                )
            );
        } else {
            return generatePaymentURL(address(this), amount, 21000);
        }
    }

    function executeFromURL(string calldata url) external payable {
        ERC681Parser.TransactionRequest memory request = parser.parseURL(url);
        
        bytes32 txHash = keccak256(abi.encodePacked(url, msg.sender));
        require(!executedTransactions[txHash], "Transaction already executed");
        
        if (request.isContract) {
            if (equals(request.functionName, "transfer")) {
                // Parse parameters from URL instead of using request.parameters
                (address to, uint256 amount) = parseTransferParams(url);
                IERC20(request.targetAddress).transferFrom(msg.sender, to, amount);
                
                // Encode parameters for event
                bytes memory params = abi.encode(to, amount);
                emit ContractCallExecuted(request.targetAddress, "transfer", params);
            }
        } else {
            require(msg.value == request.value, "Incorrect ETH value");
            (bool success,) = request.targetAddress.call{value: request.value}("");
            require(success, "ETH transfer failed");
            emit PaymentExecuted(msg.sender, request.targetAddress, request.value);
        }
        
        executedTransactions[txHash] = true;
    }

    // Helper function to parse transfer parameters from URL
    function parseTransferParams(string memory url) internal pure returns (address to, uint256 amount) {
        // Find "to=" and "amount=" in URL
        bytes memory urlBytes = bytes(url);
        uint256 toStart = indexOf(urlBytes, "to=") + 3;
        uint256 amountStart = indexOf(urlBytes, "amount=") + 7;
        
        // Parse address
        string memory toStr = substring(url, toStart, 42); // "0x" + 40 hex chars
        to = parseAddress(toStr);
        
        // Parse amount
        string memory amountStr = substring(url, amountStart, bytes(url).length - amountStart);
        amount = parseAmount(amountStr);
    }

    // Helper functions for string manipulation
    function indexOf(bytes memory data, string memory search) internal pure returns (uint256) {
        bytes memory searchBytes = bytes(search);
        for (uint i = 0; i < data.length - searchBytes.length; i++) {
            bool found = true;
            for (uint j = 0; j < searchBytes.length; j++) {
                if (data[i + j] != searchBytes[j]) {
                    found = false;
                    break;
                }
            }
            if (found) return i;
        }
        revert("String not found");
    }

    function substring(string memory str, uint256 startIndex, uint256 length) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(length);
        for(uint i = 0; i < length; i++) {
            result[i] = strBytes[startIndex + i];
        }
        return string(result);
    }

    function parseAddress(string memory _address) internal pure returns (address) {
        bytes memory tmp = bytes(_address);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 40; i++) {
            iaddr *= 16;
            b1 = uint160(uint8(tmp[i]));
            if ((b1 >= 97) && (b1 <= 102)) b1 -= 87;
            else if ((b1 >= 65) && (b1 <= 70)) b1 -= 55;
            else if ((b1 >= 48) && (b1 <= 57)) b1 -= 48;
            iaddr += b1;
        }
        return address(iaddr);
    }

    function parseAmount(string memory _amount) internal pure returns (uint256) {
        bytes memory tmp = bytes(_amount);
        uint256 amount = 0;
        for (uint i = 0; i < tmp.length; i++) {
            uint8 digit = uint8(tmp[i]) - 48;
            require(digit <= 9, "Invalid amount format");
            amount = amount * 10 + digit;
        }
        return amount;
    }

    function equals(string memory a, string memory b) private pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    receive() external payable {}
}



