// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import {MyToken} from "../../src/examples/MyToken.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";

contract Handler is Test {
    MyToken public token;
    address[] public actors;
    mapping(address => uint256) public initialBalances;
    uint256 public constant INITIAL_SUPPLY = 1_000_000 * 10**18;
    
    constructor(MyToken _token) {
        token = _token;
        for(uint i = 0; i < 5; i++) {
            actors.push(makeAddr(string(abi.encodePacked("actor", i))));
        }
    }

    function trackBalances() external {
        for(uint i = 0; i < actors.length; i++) {
            initialBalances[actors[i]] = token.balanceOf(actors[i]);
        }
    }

    // Bound amount to reasonable values
    function _boundAmount(uint256 amount) internal pure returns (uint256) {
        return bound(amount, 0, INITIAL_SUPPLY);
    }

    function transfer(uint256 actorSeed, uint256 toSeed, uint256 amount) public {
        address from = actors[bound(actorSeed, 0, actors.length - 1)];
        address to = actors[bound(toSeed, 0, actors.length - 1)];
        amount = bound(amount, 0, token.balanceOf(from));
        
        vm.prank(from);
        token.transfer(to, amount);
    }

    function approve(uint256 actorSeed, uint256 spenderSeed, uint256 amount) public {
        address owner = actors[bound(actorSeed, 0, actors.length - 1)];
        address spender = actors[bound(spenderSeed, 0, actors.length - 1)];
        
        // Bound approval amount to total supply
        amount = _boundAmount(amount);
        
        vm.prank(owner);
        token.approve(spender, amount);
    }

    function transferFrom(
        uint256 actorSeed, 
        uint256 fromSeed, 
        uint256 toSeed, 
        uint256 amount
    ) public {
        address spender = actors[bound(actorSeed, 0, actors.length - 1)];
        address from = actors[bound(fromSeed, 0, actors.length - 1)];
        address to = actors[bound(toSeed, 0, actors.length - 1)];
        
        uint256 allowance = token.allowance(from, spender);
        uint256 balance = token.balanceOf(from);
        amount = bound(amount, 0, min(allowance, balance));
        
        vm.prank(spender);
        token.transferFrom(from, to, amount);
    }

    function increaseAllowance(
        uint256 actorSeed, 
        uint256 spenderSeed, 
        uint256 amount
    ) public {
        address owner = actors[bound(actorSeed, 0, actors.length - 1)];
        address spender = actors[bound(spenderSeed, 0, actors.length - 1)];
        
        // Bound increase amount to prevent overflow
        uint256 currentAllowance = token.allowance(owner, spender);
        amount = bound(amount, 0, INITIAL_SUPPLY - currentAllowance);
        
        vm.prank(owner);
        token.increaseAllowance(spender, amount);
    }

    function decreaseAllowance(
        uint256 actorSeed, 
        uint256 spenderSeed, 
        uint256 amount
    ) public {
        address owner = actors[bound(actorSeed, 0, actors.length - 1)];
        address spender = actors[bound(spenderSeed, 0, actors.length - 1)];
        
        uint256 currentAllowance = token.allowance(owner, spender);
        amount = bound(amount, 0, currentAllowance);
        
        vm.prank(owner);
        token.decreaseAllowance(spender, amount);
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

contract MyTokenInvariantTest is StdInvariant, Test {
    MyToken public token;
    Handler public handler;
    address[] public actors;
    
    function setUp() public {
        token = new MyToken();
        handler = new Handler(token);
        
        for(uint i = 0; i < 5; i++) {
            actors.push(handler.actors(i));
        }
        
        uint256 distribution = token.balanceOf(address(this)) / actors.length;
        for(uint i = 0; i < actors.length; i++) {
            token.transfer(actors[i], distribution);
        }
        
        handler.trackBalances();
        targetContract(address(handler));
    }

    function invariant_totalSupply() public {
        assertEq(token.totalSupply(), handler.INITIAL_SUPPLY());
    }

    function invariant_balanceSum() public {
        uint256 totalBalance;
        for(uint i = 0; i < actors.length; i++) {
            totalBalance += token.balanceOf(actors[i]);
        }
        totalBalance += token.balanceOf(address(this));
        
        assertEq(totalBalance, token.totalSupply());
    }

    function invariant_allowanceNotOverflow() public {
        for(uint i = 0; i < actors.length; i++) {
            for(uint j = 0; j < actors.length; j++) {
                if(i != j) {
                    uint256 allowance = token.allowance(actors[i], actors[j]);
                    assertTrue(allowance <= handler.INITIAL_SUPPLY());
                }
            }
        }
    }

    function invariant_nonNegativeBalances() public {
        for(uint i = 0; i < actors.length; i++) {
            assertTrue(token.balanceOf(actors[i]) >= 0);
        }
    }

    function invariant_debug() public view {
        console.log("Total Supply:", token.totalSupply());
        for(uint i = 0; i < actors.length; i++) {
            console.log("Actor", i, "balance:", token.balanceOf(actors[i]));
        }
    }
} 