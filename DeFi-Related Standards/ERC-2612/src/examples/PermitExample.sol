// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./PermitToken.sol";

contract PermitExample {
    PermitToken public token;
    
    constructor(address _token) {
        token = PermitToken(_token);
    }

    /**
     * @dev Transfers tokens using a permit signature
     */
    function transferWithPermit(
        address from,
        address to,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        // First use the permit
        token.permit(from, address(this), amount, deadline, v, r, s);
        
        // Then transfer the tokens
        token.transferFrom(from, to, amount);
    }

    /**
     * @dev Example of batched transfers using a single permit
     */
    function batchTransferWithPermit(
        address from,
        address[] calldata recipients,
        uint256[] calldata amounts,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(recipients.length == amounts.length, "Length mismatch");
        
        // Calculate total amount needed
        uint256 totalAmount;
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }
        
        // Use permit for total amount
        token.permit(from, address(this), totalAmount, deadline, v, r, s);
        
        // Perform transfers
        for (uint256 i = 0; i < recipients.length; i++) {
            token.transferFrom(from, recipients[i], amounts[i]);
        }
    }
}