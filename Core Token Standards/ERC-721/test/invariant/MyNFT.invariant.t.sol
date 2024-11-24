// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/examples/MyNFT.sol";

contract NFTHandler {
    MyNFT public nft;
    address[] public users;
    mapping(uint256 => bool) public tokenExists;
    mapping(address => uint256[]) internal userTokens;
    
    constructor(MyNFT _nft) {
        nft = _nft;
        for(uint i = 0; i < 5; i++) {
            users.push(address(uint160(i + 1)));
        }
    }
    
    function getUserTokenCount(address user) public view returns (uint256) {
        return userTokens[user].length;
    }
    
    function getUserTokenAt(address user, uint256 index) public view returns (uint256) {
        require(index < userTokens[user].length, "Index out of bounds");
        return userTokens[user][index];
    }
    
    function mint() public {
        uint256 tokenId = nft.mint();
        tokenExists[tokenId] = true;
        userTokens[msg.sender].push(tokenId);
    }
    
    function transfer(uint256 userSeed, uint256 tokenIndex) public {
        if (getUserTokenCount(msg.sender) == 0) return;
        if (users.length == 0) return;
        
        uint256 tokenId = getUserTokenAt(msg.sender, tokenIndex % getUserTokenCount(msg.sender));
        address to = users[userSeed % users.length];
        
        nft.transferFrom(msg.sender, to, tokenId);
        
        userTokens[to].push(tokenId);
        removeTokenFromUser(msg.sender, tokenId);
    }
    
    function removeTokenFromUser(address user, uint256 tokenId) internal {
        uint256[] storage tokens = userTokens[user];
        for (uint i = 0; i < tokens.length; i++) {
            if (tokens[i] == tokenId) {
                tokens[i] = tokens[tokens.length - 1];
                tokens.pop();
                break;
            }
        }
    }
}

contract MyNFTInvariantTest is Test {
    MyNFT public nft;
    NFTHandler public handler;
    
    function setUp() public {
        nft = new MyNFT();
        handler = new NFTHandler(nft);
        targetContract(address(handler));
    }
    
    function invariant_balanceEqualsTokenCount() public {
        for(uint i = 0; i < 5; i++) {
            address user = address(uint160(i + 1));
            assertEq(
                nft.balanceOf(user),
                handler.getUserTokenCount(user),
                "Balance should equal owned token count"
            );
        }
    }
    
    function invariant_tokenHasOneOwner() public {
        for(uint256 tokenId = 1; tokenId <= 100; tokenId++) {
            if (handler.tokenExists(tokenId)) {
                address owner = nft.ownerOf(tokenId);
                uint256 ownerCount = 0;
                
                for(uint i = 0; i < 5; i++) {
                    address user = address(uint160(i + 1));
                    for(uint j = 0; j < handler.getUserTokenCount(user); j++) {
                        if (handler.getUserTokenAt(user, j) == tokenId) {
                            ownerCount++;
                            assertEq(owner, user, "Token owner mismatch");
                        }
                    }
                }
                
                assertEq(ownerCount, 1, "Token must have exactly one owner");
            }
        }
    }
    
    function invariant_approvalStateConsistency() public {
        for(uint256 tokenId = 1; tokenId <= 100; tokenId++) {
            if (handler.tokenExists(tokenId)) {
                address approved = nft.getApproved(tokenId);
                if (approved != address(0)) {
                    address owner = nft.ownerOf(tokenId);
                    assertTrue(
                        approved != owner,
                        "Owner cannot be approved for their own token"
                    );
                }
            }
        }
    }
}