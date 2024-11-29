// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockERC20Malicious {
    function transferFrom(address, address, uint256) external pure returns (bool) {
        return false;
    }
}

contract MockERC20 {
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }
    
    function mint(address to, uint256 amount) public {
        balanceOf[to] += amount;
    }
    
    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }
    
    function transfer(address to, uint256 amount) public returns (bool) {
        return _transfer(msg.sender, to, amount);
    }
    
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(allowance[from][msg.sender] >= amount, "Insufficient allowance");
        allowance[from][msg.sender] -= amount;
        return _transfer(from, to, amount);
    }
    
    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}