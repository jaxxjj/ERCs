// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC1155} from "../base/ERC1155.sol";

contract GameItems is ERC1155 {
    // Token type IDs
    uint256 public constant HEALTH_POTION = 0;
    uint256 public constant MANA_POTION = 1;
    uint256 public constant LEGENDARY_SWORD = 2;
    uint256 public constant DRAGON_SCALE_ARMOR = 3;
    uint256 public constant MAGIC_SCROLL = 4;

    // Price in wei for each item
    mapping(uint256 => uint256) public itemPrices;
    
    // Item supply caps
    mapping(uint256 => uint256) public supplyCaps;
    
    // Current supply tracking
    mapping(uint256 => uint256) private _currentSupply;

    constructor() ERC1155("https://game.example/api/item/{id}.json") {
        // Set initial supply caps
        supplyCaps[HEALTH_POTION] = 10000;
        supplyCaps[MANA_POTION] = 10000;
        supplyCaps[LEGENDARY_SWORD] = 100;
        supplyCaps[DRAGON_SCALE_ARMOR] = 50;
        supplyCaps[MAGIC_SCROLL] = 500;

        // Set prices in wei
        itemPrices[HEALTH_POTION] = 0.01 ether;
        itemPrices[MANA_POTION] = 0.01 ether;
        itemPrices[LEGENDARY_SWORD] = 0.5 ether;
        itemPrices[DRAGON_SCALE_ARMOR] = 1 ether;
        itemPrices[MAGIC_SCROLL] = 0.1 ether;

        // Mint initial supplies
        _mint(msg.sender, HEALTH_POTION, 1000, "");
        _mint(msg.sender, MANA_POTION, 1000, "");
        _mint(msg.sender, LEGENDARY_SWORD, 10, "");
        _mint(msg.sender, DRAGON_SCALE_ARMOR, 5, "");
        _mint(msg.sender, MAGIC_SCROLL, 50, "");
    }

    // Override _mint to add supply tracking
    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual override {
        _currentSupply[id] += amount;
        super._mint(to, id, amount, data);
    }

    // Override _mintBatch to add supply tracking
    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        for (uint256 i = 0; i < ids.length; i++) {
            _currentSupply[ids[i]] += amounts[i];
        }
        super._mintBatch(to, ids, amounts, data);
    }

    // Public minting function with payment
    function mintItem(uint256 itemId, uint256 amount) public payable {
        require(itemPrices[itemId] > 0, "Item does not exist");
        require(msg.value >= itemPrices[itemId] * amount, "Insufficient payment");
        require(_currentSupply[itemId] + amount <= supplyCaps[itemId], "Exceeds supply cap");

        _mint(msg.sender, itemId, amount, "");
    }

    // Batch minting with payment
    function mintBatch(uint256[] memory ids, uint256[] memory amounts) public payable {
        require(ids.length == amounts.length, "Length mismatch");
        
        uint256 totalPayment = 0;
        for (uint256 i = 0; i < ids.length; i++) {
            require(itemPrices[ids[i]] > 0, "Item does not exist");
            require(_currentSupply[ids[i]] + amounts[i] <= supplyCaps[ids[i]], "Exceeds supply cap");
            totalPayment += itemPrices[ids[i]] * amounts[i];
        }
        
        require(msg.value >= totalPayment, "Insufficient payment");
        _mintBatch(msg.sender, ids, amounts, "");
    }

    // Get current supply of an item
    function getCurrentSupply(uint256 itemId) public view returns (uint256) {
        return _currentSupply[itemId];
    }

    // Get remaining supply of an item
    function getRemainingSupply(uint256 itemId) public view returns (uint256) {
        return supplyCaps[itemId] - _currentSupply[itemId];
    }

    // Withdraw contract balance (only owner)
    function withdraw() public {
        uint256 balance = address(this).balance;
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Withdrawal failed");
    }

    // Override _beforeTokenTransfer to add custom logic
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
        
        // Add custom transfer restrictions or logic here
        for (uint256 i = 0; i < ids.length; i++) {
            require(ids[i] <= MAGIC_SCROLL, "Invalid item ID");
        }
    }

    // Receive function to accept ETH payments
    receive() external payable {}
}