// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/examples/MyNFT.sol";
import "../../src/interfaces/IERC721.sol";

contract MyNFTFuzzTest is Test {
    MyNFT public nft;
    address public owner;
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

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
        nft = new MyNFT();
    }

    function testFuzzMintToEOA(address to) public {
        vm.assume(to != address(0));
        vm.assume(!_isContract(to));
        
        uint256 tokenId = nft.mint();
        nft.transferFrom(owner, to, tokenId);
        
        assertEq(nft.ownerOf(tokenId), to);
        assertEq(nft.balanceOf(to), 1);
    }

    function testFuzzApproval(address to, address spender) public {
        vm.assume(to != address(0));
        vm.assume(spender != address(0));
        vm.assume(to != spender);
        
        uint256 tokenId = nft.mint();
        nft.transferFrom(owner, to, tokenId);
        
        vm.prank(to);
        nft.approve(spender, tokenId);
        
        assertEq(nft.getApproved(tokenId), spender);
    }

    function testFuzzTransferFrom(address from, address to) public {
        vm.assume(from != address(0));
        vm.assume(to != address(0));
        vm.assume(from != to);
        vm.assume(!_isContract(to));
        
        uint256 tokenId = nft.mint();
        nft.transferFrom(owner, from, tokenId);
        
        // Track initial states
        uint256 fromBalanceBefore = nft.balanceOf(from);
        uint256 toBalanceBefore = nft.balanceOf(to);
        
        // Approve test contract for transfer
        vm.prank(from);
        nft.approve(address(this), tokenId);
        
        // Perform transfer
        nft.transferFrom(from, to, tokenId);
        
        // Verify final state
        assertEq(nft.ownerOf(tokenId), to);
        assertEq(nft.balanceOf(from), fromBalanceBefore - 1);
        assertEq(nft.balanceOf(to), toBalanceBefore + 1);
        assertEq(nft.getApproved(tokenId), address(0));
    }

    function testFuzzApprovalForAll(address owner, address operator, bool approved) public {
        vm.assume(owner != address(0));
        vm.assume(operator != address(0));
        vm.assume(owner != operator);
        
        vm.prank(owner);
        nft.setApprovalForAll(operator, approved);
        
        assertEq(nft.isApprovedForAll(owner, operator), approved);
    }

    function testFuzzMultipleTransfers(address[3] memory recipients) public {
        for(uint i = 0; i < recipients.length; i++) {
            vm.assume(recipients[i] != address(0));
            vm.assume(!_isContract(recipients[i]));
            
            uint256 tokenId = nft.mint();
            nft.transferFrom(owner, recipients[i], tokenId);
            
            assertEq(nft.ownerOf(tokenId), recipients[i]);
            assertEq(nft.balanceOf(recipients[i]), 1);
        }
    }

    function testFailFuzzTransferUnauthorized(address from, address to, uint256 tokenId) public {
        vm.assume(from != address(0));
        vm.assume(to != address(0));
        
        vm.prank(from);
        nft.transferFrom(from, to, tokenId);
    }

    // Helper function to check if address is a contract
    function _isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
}