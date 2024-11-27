// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../src/examples/FlashLender.sol";
import "../../src/examples/ArbitrageFlashBorrower.sol";
import "../../src/examples/FlashLoanExample.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Mock Token for testing
contract MockToken is ERC20 {
    constructor() ERC20("Mock Token", "MTK") {
        _mint(msg.sender, 1000000 * 10**decimals());
    }
}

// Mock DEX Pair for testing
contract MockDEXPair {
    IERC20 public token0;
    IERC20 public token1;
    uint112 private reserve0;
    uint112 private reserve1;

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function setReserves(uint112 _reserve0, uint112 _reserve1) external {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    function getReserves() external view returns (uint112, uint112, uint32) {
        return (reserve0, reserve1, uint32(block.timestamp));
    }

    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata) external {
        if (amount0Out > 0) {
            token0.transfer(to, amount0Out);
        }
        if (amount1Out > 0) {
            token1.transfer(to, amount1Out);
        }
    }
}

contract FlashLoanTest is Test {
    FlashLender public lender;
    ArbitrageFlashBorrower public borrower;
    FlashLoanExample public example;
    MockToken public token;
    MockDEXPair public dexPairA;
    MockDEXPair public dexPairB;
    MockToken public tokenB; // Second token for DEX pairs

    address public owner;
    address public user;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        // Setup accounts
        owner = makeAddr("owner");
        user = makeAddr("user");
        vm.startPrank(owner);

        // Deploy tokens
        token = new MockToken();
        tokenB = new MockToken();
        
        // Setup DEX pairs
        dexPairA = new MockDEXPair(address(token), address(tokenB));
        dexPairB = new MockDEXPair(address(token), address(tokenB));

        // Setup flash loan contracts
        address[] memory tokens = new address[](1);
        tokens[0] = address(token);
        lender = new FlashLender(tokens);
        
        borrower = new ArbitrageFlashBorrower(
            address(lender),
            address(dexPairA),
            address(dexPairB)
        );

        // Fund contracts
        token.transfer(address(lender), 1000 * 10**18);
        token.transfer(address(dexPairA), 1000 * 10**18);
        token.transfer(address(dexPairB), 1000 * 10**18);

        // Approve tokens for DEX pairs
        token.approve(address(dexPairA), type(uint256).max);
        token.approve(address(dexPairB), type(uint256).max);
        tokenB.approve(address(dexPairA), type(uint256).max);
        tokenB.approve(address(dexPairB), type(uint256).max);

        vm.stopPrank();
    }

    function testInitialState() public {
        assertEq(address(lender.owner()), owner);
        assertTrue(lender.supportedTokens(address(token)));
        assertEq(token.balanceOf(address(lender)), 1000 * 10**18);
    }

    function testAddSupportedToken() public {
        address newToken = address(new MockToken());
        
        vm.prank(owner);
        lender.addSupportedToken(newToken);
        
        assertTrue(lender.supportedTokens(newToken));
    }

    function testRemoveSupportedToken() public {
        vm.prank(owner);
        lender.removeSupportedToken(address(token));
        
        assertFalse(lender.supportedTokens(address(token)));
    }

    function testFlashLoanMaxAmount() public {
        uint256 maxLoan = lender.maxFlashLoan(address(token));
        assertEq(maxLoan, 1000 * 10**18);
    }

    function testFlashLoanFee() public {
        uint256 amount = 100 * 10**18;
        uint256 fee = lender.flashFee(address(token), amount);
        // Fee should be 0.09% (9 basis points)
        assertEq(fee, (amount * 9) / 10000);
    }

    function testFailFlashLoanUnsupportedToken() public {
        address unsupportedToken = address(new MockToken());
        vm.prank(owner);
        borrower.executeArbitrage(unsupportedToken, 100 * 10**18);
    }

    function testFailFlashLoanInsufficientBalance() public {
        uint256 tooMuch = 2000 * 10**18; // More than lender balance
        vm.prank(owner);
        borrower.executeArbitrage(address(token), tooMuch);
    }

    function testWithdrawToken() public {
        uint256 amount = 100 * 10**18;
        uint256 initialOwnerBalance = token.balanceOf(owner);
        
        vm.startPrank(owner);
        lender.withdrawToken(address(token), amount);
        
        assertEq(
            token.balanceOf(owner),
            initialOwnerBalance + amount,
            "Owner balance should increase by withdrawn amount"
        );
        vm.stopPrank();
    }

    function testFailNonOwnerWithdraw() public {
        vm.prank(user);
        lender.withdrawToken(address(token), 100 * 10**18);
    }

    function testFailExpiredLoan() public {
        // Warp to future timestamp
        vm.warp(block.timestamp + 2 days);
        
        vm.prank(owner);
        borrower.executeArbitrage(address(token), 100 * 10**18);
    }
}