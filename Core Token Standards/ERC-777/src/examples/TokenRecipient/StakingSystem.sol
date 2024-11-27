// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "../../interfaces/IERC777Recipient.sol";
import "../../interfaces/IERC1820Registry.sol";
import "../../interfaces/IERC777.sol";
contract StakingSystem is IERC777Recipient {
    IERC777 public stakingToken;
    mapping(address => uint256) public stakedBalance;
    mapping(address => uint256) public stakingTime;
    
    // reward rate
    uint256 public constant REWARD_RATE = 100; // 10%

    constructor(address tokenAddress) {
        stakingToken = IERC777(tokenAddress);
        // register ERC1820
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
        require(msg.sender == address(stakingToken), "Invalid token");
        // auto stake
        stakedBalance[from] += amount;
        stakingTime[from] = block.timestamp;
    }

    function calculateRewards(address user) public view returns (uint256) {
        uint256 timeStaked = block.timestamp - stakingTime[user];
        return (stakedBalance[user] * REWARD_RATE * timeStaked) / (365 days * 1000);
    }
}