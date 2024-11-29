// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
// Example frontend integration
interface IPaymentExecutor {
    function executeFromURL(string calldata url) external payable;
    function createPaymentRequest(uint256 amount, bool isToken, address token) external view returns (string memory);
}
// Example usage flow:
contract PaymentExample {
    IPaymentExecutor public executor;
    
    constructor(address _executor) {
        executor = IPaymentExecutor(_executor);
    }
    
    function processPayment() external {
        // 1. Create payment request
        string memory url = executor.createPaymentRequest(1 ether, false, address(0));
        
        // 2. Execute payment (this would normally be done by the payer's wallet)
        executor.executeFromURL{value: 1 ether}(url);
    }
}