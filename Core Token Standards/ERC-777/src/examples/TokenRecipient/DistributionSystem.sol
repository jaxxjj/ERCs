// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../../interfaces/IERC777Recipient.sol";
import "../../interfaces/IERC1820Registry.sol";
import "../../interfaces/IERC777.sol";

contract DistributionSystem is IERC777Recipient {
    IERC777 public token;
    address[] public distributors;
    mapping(address => uint256) public shares;
    
    constructor(address tokenAddress, address[] memory _distributors, uint256[] memory _shares) {
        token = IERC777(tokenAddress);
        require(_distributors.length == _shares.length, "Length mismatch");
        
        distributors = _distributors;
        uint256 totalShares;
        for(uint i = 0; i < _distributors.length; i++) {
            shares[_distributors[i]] = _shares[i];
            totalShares += _shares[i];
        }
        require(totalShares == 100, "Total must be 100");
        
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24)
            .setInterfaceImplementer(
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
        require(msg.sender == address(token), "Invalid token");
        
        // auto distribute
        for(uint i = 0; i < distributors.length; i++) {
            uint256 share = (amount * shares[distributors[i]]) / 100;
            token.send(distributors[i], share, "");
        }
    }
}