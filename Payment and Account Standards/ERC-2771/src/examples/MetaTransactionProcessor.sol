// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC2771Forwarder} from "../base/ERC2771Forwarder.sol";

/**
 * @title MetaTransactionProcessor
 * @dev Example contract demonstrating how to use ERC2771Forwarder for meta-transactions
 */
contract MetaTransactionProcessor {
    ERC2771Forwarder public immutable forwarder;
    
    // Events
    event MetaTransactionExecuted(address indexed from, address indexed to, bool success);

    constructor(address _forwarder) {
        forwarder = ERC2771Forwarder(_forwarder);
    }

    /**
     * @dev Processes a meta transaction
     * @param req The forward request containing transaction details
     * @param signature The signature of the request by the sender
     */
    function processMetaTransaction(
        ERC2771Forwarder.ForwardRequestData calldata req,
        bytes calldata signature
    ) external payable {
        // Verify the forwarded request
        bool success = forwarder.verify(req);
        require(success, "Invalid forward request");

        // Execute the meta-transaction
        forwarder.execute{value: msg.value}(req);
        
        emit MetaTransactionExecuted(req.from, req.to, success);
    }

    /**
     * @dev Helper to create a meta-transaction request
     * @param from The sender address
     * @param to The target contract address
     * @param value The ETH value to send
     * @param gas The gas limit for the transaction
     * @param data The transaction data
     * @param deadline The deadline for executing the transaction
     */
    function createMetaTransaction(
        address from,
        address to,
        uint256 value,
        uint256 gas,
        bytes memory data,
        uint48 deadline
    ) external pure returns (ERC2771Forwarder.ForwardRequestData memory) {
        return ERC2771Forwarder.ForwardRequestData({
            from: from,
            to: to,
            value: value,
            gas: gas,
            deadline: deadline,
            data: data,
            signature: "" // Signature needs to be added by the sender
        });
    }

    /**
     * @dev Receive function to accept ETH
     */
    receive() external payable {}
}
