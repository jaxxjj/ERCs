// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MyNFT} from "../../src/examples/MyNFT.sol";

contract MyNFTTest is Test {
    MyNFT public nft;
    
    address public owner;
    address public user1;
    address public user2;
    address public royaltyReceiver;
    
    uint96 constant ROYALTY_FEE = 500; // 5%
    string constant NAME = "My NFT";
    string constant SYMBOL = "MNFT";
    string constant BASE_URI = "ipfs://QmTest/";
    
    event MintingEnabled(bool enabled);
    event BaseURIUpdated(string newBaseURI);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event RoyaltySet(uint256 indexed tokenId, address indexed receiver, uint96 feeNumerator);

    function setUp() public {
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        royaltyReceiver = makeAddr("royaltyReceiver");
        
        vm.startPrank(owner);
        nft = new MyNFT(
            NAME,
            SYMBOL,
            BASE_URI,
            royaltyReceiver,
            ROYALTY_FEE
        );
        nft.setMintingEnabled(true);
        vm.stopPrank();
        
        // Fund test accounts
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
    }

    // Basic Functionality Tests
    function test_InitialState() public {
        assertEq(nft.name(), NAME);
        assertEq(nft.symbol(), SYMBOL);
        assertEq(nft.owner(), owner);
        assertEq(nft.totalSupply(), 0);
        assertEq(nft.maxSupply(), 10000);
        assertTrue(nft.mintingEnabled());
        
        (address receiver, uint96 fee) = nft.getDefaultRoyaltyInfo();
        assertEq(receiver, royaltyReceiver);
        assertEq(fee, ROYALTY_FEE);
    }

    function test_SingleMint() public {
        vm.prank(user1);
        nft.mint{value: 0.1 ether}();
        
        assertEq(nft.totalSupply(), 1);
        assertEq(nft.ownerOf(1), user1);
        assertEq(nft.balanceOf(user1), 1);
    }

    function test_BatchMint() public {
        vm.startPrank(user1);
        nft.mintBatch{value: 0.5 ether}(5);
        vm.stopPrank();
        
        assertEq(nft.totalSupply(), 5);
        assertEq(nft.balanceOf(user1), 5);
        for(uint i = 1; i <= 5; i++) {
            assertEq(nft.ownerOf(i), user1);
        }
    }

    // Royalty Tests
    function test_RoyaltyCalculation() public {
        vm.prank(user1);
        nft.mint{value: 0.1 ether}();
        
        (address receiver, uint256 royaltyAmount) = nft.royaltyInfo(1, 1 ether);
        assertEq(receiver, royaltyReceiver);
        assertEq(royaltyAmount, 0.05 ether); // 5% of 1 ether
    }

    // Owner Function Tests
    function test_SetMintingEnabled() public {
        vm.startPrank(owner);
        nft.setMintingEnabled(false);
        vm.stopPrank();
        
        vm.expectRevert("Minting is not enabled");
        vm.prank(user1);
        nft.mint{value: 0.1 ether}();
    }

    function test_SetBaseURI() public {
        string memory newURI = "ipfs://QmNewTest/";
        
        vm.prank(owner);
        nft.setBaseURI(newURI);
        
        vm.prank(user1);
        nft.mint{value: 0.1 ether}();
        // Note: Add tokenURI test if you implement it
    }

    function test_Withdraw() public {
        // Mint a token to add funds to contract
        vm.prank(user1);
        nft.mint{value: 0.1 ether}();
        
        uint256 initialBalance = owner.balance;
        
        vm.prank(owner);
        nft.withdraw();
        
        assertEq(owner.balance, initialBalance + 0.1 ether);
        assertEq(address(nft).balance, 0);
    }

    // Error Cases
    function testFail_MintWithoutPayment() public {
        vm.prank(user1);
        nft.mint{value: 0.09 ether}();
    }

    function testFail_MintWhenDisabled() public {
        vm.prank(owner);
        nft.setMintingEnabled(false);
        
        vm.prank(user1);
        nft.mint{value: 0.1 ether}();
    }

    function testFail_ExceedMaxSupply() public {
        vm.startPrank(user1);
        for(uint i = 0; i <= 10000; i++) {
            nft.mint{value: 0.1 ether}();
        }
        vm.stopPrank();
    }

    // Access Control Tests
    function testFail_NonOwnerSetMintingEnabled() public {
        vm.prank(user1);
        nft.setMintingEnabled(false);
    }

    function testFail_NonOwnerSetBaseURI() public {
        vm.prank(user1);
        nft.setBaseURI("ipfs://QmHack/");
    }

    function testFail_NonOwnerWithdraw() public {
        vm.prank(user1);
        nft.withdraw();
    }

    // Event Tests
    function test_MintingEnabledEvent() public {
        vm.expectEmit(true, true, true, true);
        emit MintingEnabled(false);
        
        vm.prank(owner);
        nft.setMintingEnabled(false);
    }

    function test_BaseURIUpdatedEvent() public {
        string memory newURI = "ipfs://QmNewTest/";
        
        vm.expectEmit(true, true, true, true);
        emit BaseURIUpdated(newURI);
        
        vm.prank(owner);
        nft.setBaseURI(newURI);
    }

    // Gas Tests
    function test_MintGasUsage() public {
        uint256 gasBefore = gasleft();
        vm.prank(user1);
        nft.mint{value: 0.1 ether}();
        uint256 gasUsed = gasBefore - gasleft();
        console.log("Gas used for single mint:", gasUsed);
    }

    function test_BatchMintGasUsage() public {
        uint256 gasBefore = gasleft();
        vm.prank(user1);
        nft.mintBatch{value: 0.5 ether}(5);
        uint256 gasUsed = gasBefore - gasleft();
        console.log("Gas used for batch mint of 5:", gasUsed);
    }

    // Receive function to allow contract to receive ETH
    receive() external payable {}
}