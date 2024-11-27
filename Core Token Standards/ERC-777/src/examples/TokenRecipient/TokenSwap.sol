// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../../interfaces/IERC777Recipient.sol";
import "../../interfaces/IERC1820Registry.sol";
import "../../interfaces/IERC777.sol";

contract TokenSwap is IERC777Recipient {
    IERC777 public tokenA;
    IERC777 public tokenB;
    uint256 public rateAtoB; // tokenA:tokenB = 1:rateAtoB
    
    constructor(address _tokenA, address _tokenB, uint256 _rateAtoB) {
        tokenA = IERC777(_tokenA);
        tokenB = IERC777(_tokenB);
        rateAtoB = _rateAtoB;
        
        IERC1820Registry registry = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
        registry.setInterfaceImplementer(
            address(this),
            keccak256("ERC777TokensRecipient"),
            address(this)
        );
    }
    
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external override {
        if(msg.sender == address(tokenA)) {
            // receive tokenA, send tokenB
            uint256 amountB = amount * rateAtoB;
            require(tokenB.balanceOf(address(this)) >= amountB, "Insufficient B");
            tokenB.send(from, amountB, "");
        }
        else if(msg.sender == address(tokenB)) {
            // receive tokenB, send tokenA
            uint256 amountA = amount / rateAtoB;
            require(tokenA.balanceOf(address(this)) >= amountA, "Insufficient A");
            tokenA.send(from, amountA, "");
        }
    }
}