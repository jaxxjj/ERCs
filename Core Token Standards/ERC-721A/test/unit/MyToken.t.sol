// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {MyToken} from "../../src/examples/MyToken.sol";

contract MyTokenTest is Test {
    MyToken public token;
    address public owner;
    address public user1;
    address public user2;
    address public user3;

    uint256 public constant PRICE = 0.08 ether;
    uint256 public constant MAX_PER_MINT = 5;
    
    event PublicMintToggled(bool isEnabled);
    event BaseURIUpdated(string newBaseURI);
    event WhitelistUpdated(address indexed user, bool isWhitelisted);
    event TokensMinted(address indexed to, uint256 quantity);

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        user3 = makeAddr("user3");
        
        token = new MyToken();
        
        // Fund test accounts
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
        vm.deal(user3, 100 ether);
    }

    // Configuration Tests
    function test_InitialState() public {
        assertEq(token.name(), "MyToken");
        assertEq(token.symbol(), "MTK");
        assertEq(token.PRICE(), 0.08 ether);
        assertEq(token.MAX_SUPPLY(), 10000);
        assertEq(token.MAX_PER_MINT(), 5);
        assertEq(token.MAX_PER_WALLET(), 10);
        assertFalse(token.isPublicMintEnabled());
    }

    // Public Mint Tests
    function test_PublicMint() public {
        token.setPublicMintEnabled(true);
        
        vm.prank(user1);
        token.mint{value: PRICE}(1);
        
        assertEq(token.balanceOf(user1), 1);
        assertEq(token.ownerOf(0), user1);
    }

    function test_PublicMintBatch() public {
        token.setPublicMintEnabled(true);
        
        vm.prank(user1);
        token.mint{value: PRICE * 3}(3);
        
        assertEq(token.balanceOf(user1), 3);
        assertEq(token.getMintedCount(user1), 3);
    }

    function testFail_PublicMintDisabled() public {
        vm.prank(user1);
        token.mint{value: PRICE}(1);
    }

    function testFail_InsufficientPayment() public {
        token.setPublicMintEnabled(true);
        
        vm.prank(user1);
        token.mint{value: PRICE - 0.01 ether}(1);
    }

    // Whitelist Tests
    function test_WhitelistMint() public {
        token.updateWhitelist(user1, true);
        
        vm.prank(user1);
        token.whitelistMint{value: PRICE}(1);
        
        assertEq(token.balanceOf(user1), 1);
    }

    function test_BatchWhitelist() public {
        address[] memory users = new address[](2);
        users[0] = user1;
        users[1] = user2;
        
        token.batchUpdateWhitelist(users, true);
        
        assertTrue(token.isWhitelisted(user1));
        assertTrue(token.isWhitelisted(user2));
    }

    function testFail_NonWhitelistedMint() public {
        vm.prank(user1);
        token.whitelistMint{value: PRICE}(1);
    }

    // Limit Tests
    function testFail_ExceedMaxPerMint() public {
        token.setPublicMintEnabled(true);
        
        vm.prank(user1);
        token.mint{value: PRICE * (MAX_PER_MINT + 1)}(MAX_PER_MINT + 1);
    }

    function testFail_ExceedMaxPerWallet() public {
        token.setPublicMintEnabled(true);
        
        vm.startPrank(user1);
        token.mint{value: PRICE * 5}(5);
        token.mint{value: PRICE * 5}(5);
        token.mint{value: PRICE * 1}(1); // Should fail on 11th mint
        vm.stopPrank();
    }

    // URI Tests
    function test_TokenURI() public {
        token.setPublicMintEnabled(true);
        token.setBaseURI("ipfs://QmTest/");
        
        vm.prank(user1);
        token.mint{value: PRICE}(1);
        
        assertEq(token.tokenURI(0), "ipfs://QmTest/0");
    }

    function testFail_URIQueryNonexistent() public {
        token.tokenURI(0);
    }

    // Withdrawal Tests
    function test_Withdrawal() public {
        token.setPublicMintEnabled(true);
        
        vm.prank(user1);
        token.mint{value: PRICE * 2}(2);
        
        uint256 initialBalance = address(owner).balance;
        token.withdraw();
        
        assertEq(
            address(owner).balance - initialBalance,
            PRICE * 2
        );
    }

    // Owner Function Tests
    function test_TogglePublicMint() public {
        assertFalse(token.isPublicMintEnabled());
        
        vm.expectEmit(true, true, true, true);
        emit PublicMintToggled(true);
        
        token.setPublicMintEnabled(true);
        assertTrue(token.isPublicMintEnabled());
    }

    function testFail_NonOwnerToggle() public {
        vm.prank(user1);
        token.setPublicMintEnabled(true);
    }

    // Gas Tests
    function test_MintGasUsage() public {
        token.setPublicMintEnabled(true);
        
        uint256 gasBefore = gasleft();
        vm.prank(user1);
        token.mint{value: PRICE}(1);
        uint256 gasUsed = gasBefore - gasleft();
        
        console.log("Gas used for single mint:", gasUsed);
    }

    function test_BatchMintGasUsage() public {
        token.setPublicMintEnabled(true);
        
        uint256 gasBefore = gasleft();
        vm.prank(user1);
        token.mint{value: PRICE * 5}(5);
        uint256 gasUsed = gasBefore - gasleft();
        
        console.log("Gas used for batch mint of 5:", gasUsed);
    }

    // Fuzz Tests
    function testFuzz_MintQuantity(uint256 quantity) public {
        vm.assume(quantity > 0 && quantity <= MAX_PER_MINT);
        token.setPublicMintEnabled(true);
        
        vm.prank(user1);
        token.mint{value: PRICE * quantity}(quantity);
        
        assertEq(token.balanceOf(user1), quantity);
    }

    // Invariant Tests
    function invariant_TotalSupplyCheck() public {
        assertTrue(token.totalSupply() <= token.MAX_SUPPLY());
    }

    receive() external payable {}
}