// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {GameItems} from "../../src/examples/GameItems.sol";
import {IERC1155Receiver} from "../../src/interfaces/IERC1155Receiver.sol";

contract GameItemsTest is Test, IERC1155Receiver {
    GameItems public gameItems;
    address public owner;
    address public user1;
    address public user2;

    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );
    
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    function setUp() public {
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        // Deploy contract as owner
        vm.prank(owner);
        gameItems = new GameItems();
        
        // Fund test accounts
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
    }

    // Required IERC1155Receiver implementation
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    ) external pure override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId;
    }

    // Constructor Tests
    function test_InitialSetup() public {
        // Check initial supply for owner address
        console.log("Owner balance of health potion: %s", gameItems.balanceOf(owner, gameItems.HEALTH_POTION()));
        console.log("Owner balance of legendary sword: %s", gameItems.balanceOf(owner, gameItems.LEGENDARY_SWORD()));
        assertEq(gameItems.balanceOf(owner, gameItems.HEALTH_POTION()), 1000);
        assertEq(gameItems.balanceOf(owner, gameItems.LEGENDARY_SWORD()), 10);
        
        // Check supply caps
        assertEq(gameItems.supplyCaps(gameItems.HEALTH_POTION()), 10000);
        assertEq(gameItems.itemPrices(gameItems.LEGENDARY_SWORD()), 0.5 ether);
        
        // Check current supply
        assertEq(gameItems.getCurrentSupply(gameItems.HEALTH_POTION()), 1000);
        assertEq(gameItems.getCurrentSupply(gameItems.LEGENDARY_SWORD()), 10);
    }

    // Minting Tests
    function test_MintItem() public {
        vm.startPrank(user1);
        uint256 itemId = gameItems.HEALTH_POTION();
        uint256 amount = 5;
        uint256 price = gameItems.itemPrices(itemId) * amount;
        
        uint256 balanceBefore = user1.balance;
        gameItems.mintItem{value: price}(itemId, amount);
        
        assertEq(gameItems.balanceOf(user1, itemId), amount);
        assertEq(user1.balance, balanceBefore - price);
        assertEq(gameItems.getCurrentSupply(itemId), 1005); // Initial 1000 + 5
    }

    function test_MintBatch() public {
        vm.startPrank(user1);
        
        uint256[] memory ids = new uint256[](2);
        ids[0] = gameItems.HEALTH_POTION();
        ids[1] = gameItems.MANA_POTION();
        
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 3;
        amounts[1] = 2;
        
        uint256 totalPrice = (gameItems.itemPrices(ids[0]) * amounts[0]) + 
                            (gameItems.itemPrices(ids[1]) * amounts[1]);
        
        gameItems.mintBatch{value: totalPrice}(ids, amounts);
        
        assertEq(gameItems.balanceOf(user1, ids[0]), amounts[0]);
        assertEq(gameItems.balanceOf(user1, ids[1]), amounts[1]);
    }

    // Supply Cap Tests
    function testFail_ExceedSupplyCap() public {
        vm.startPrank(user1);
        uint256 itemId = gameItems.DRAGON_SCALE_ARMOR();
        uint256 amount = gameItems.supplyCaps(itemId) + 1;
        uint256 price = gameItems.itemPrices(itemId) * amount;
        
        gameItems.mintItem{value: price}(itemId, amount);
    }

    // Payment Tests
    function testFail_InsufficientPayment() public {
        vm.startPrank(user1);
        uint256 itemId = gameItems.HEALTH_POTION();
        uint256 amount = 1;
        uint256 price = gameItems.itemPrices(itemId) * amount;
        
        gameItems.mintItem{value: price - 1}(itemId, amount);
    }

    // Withdrawal Tests
    function test_Withdraw() public {
        vm.startPrank(user1);
        gameItems.mintItem{value: 0.01 ether}(gameItems.HEALTH_POTION(), 1);
        vm.stopPrank();
        
        uint256 balanceBefore = owner.balance;
        
        vm.prank(owner);
        gameItems.withdraw();
        
        assertEq(owner.balance, balanceBefore + 0.01 ether);
    }

    // Transfer Tests
    function test_SafeTransfer() public {
        // First mint some tokens
        vm.startPrank(user1);
        uint256 itemId = gameItems.HEALTH_POTION();
        gameItems.mintItem{value: 0.01 ether}(itemId, 1);
        
        // Then transfer
        gameItems.safeTransferFrom(user1, user2, itemId, 1, "");
        
        assertEq(gameItems.balanceOf(user1, itemId), 0);
        assertEq(gameItems.balanceOf(user2, itemId), 1);
        vm.stopPrank();
    }

    // Receive function test
    receive() external payable {}
}