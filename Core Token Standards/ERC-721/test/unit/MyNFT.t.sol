// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/examples/MyNFT.sol";
import "../../src/interfaces/IERC721.sol";

contract MyNFTTest is Test {
    MyNFT public nft;
    address public owner;
    address public user1;
    address public user2;
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
    
    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        nft = new MyNFT();
    }

    function testTokenMetadata() public {
        assertEq(nft.name(), "MyNFT");
        assertEq(nft.symbol(), "MNFT");
    }

    function testMint() public {
        uint256 tokenId = nft.mint();
        assertEq(tokenId, 1);
        assertEq(nft.balanceOf(owner), 1);
        assertEq(nft.ownerOf(tokenId), owner);
    }

    function testMintIncrements() public {
        uint256 firstToken = nft.mint();
        uint256 secondToken = nft.mint();
        assertEq(firstToken, 1);
        assertEq(secondToken, 2);
    }

    function testMintEmitsTransferEvent() public {
        vm.expectEmit(true, true, true, true);
        emit Transfer(address(0), owner, 1);
        nft.mint();
    }

    function testTransfer() public {
        uint256 tokenId = nft.mint();
        nft.transferFrom(owner, user1, tokenId);
        
        assertEq(nft.balanceOf(owner), 0);
        assertEq(nft.balanceOf(user1), 1);
        assertEq(nft.ownerOf(tokenId), user1);
    }

    function testApprove() public {
        uint256 tokenId = nft.mint();
        nft.approve(user1, tokenId);
        
        assertEq(nft.getApproved(tokenId), user1);
    }

    function testApproveEmitsEvent() public {
        uint256 tokenId = nft.mint();
        
        vm.expectEmit(true, true, true, true);
        emit Approval(owner, user1, tokenId);
        
        nft.approve(user1, tokenId);
    }

    function testFailTransferUnownedToken() public {
        nft.transferFrom(owner, user1, 1);
    }

    function testFailTransferUnauthorized() public {
        uint256 tokenId = nft.mint();
        vm.prank(user1);
        nft.transferFrom(owner, user2, tokenId);
    }

    function testFailTransferToZeroAddress() public {
        uint256 tokenId = nft.mint();
        nft.transferFrom(owner, address(0), tokenId);
    }

    function testFailGetApprovedUnminted() public {
        nft.getApproved(1);
    }

    function testFailApproveUnminted() public {
        nft.approve(user1, 1);
    }

    
}