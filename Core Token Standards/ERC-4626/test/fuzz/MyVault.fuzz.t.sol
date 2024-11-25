// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SecureVault} from "../../src/examples/MyVault.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract SecureVaultFuzzTest is Test {
    SecureVault public vault;
    ERC20Mock public underlying;
    
    address public owner = address(this);
    address public alice = address(0x1);
    address public bob = address(0x2);
    
    uint256 constant INITIAL_UNDERLYING_BALANCE = 10_000 * 10**18;
    uint256 constant INITIAL_DEPOSIT = 1000 * 10**18;

    function setUp() public {
        underlying = new ERC20Mock();
        underlying.mint(owner, INITIAL_UNDERLYING_BALANCE);
        
        address futureVault = computeCreateAddress(address(this), vm.getNonce(address(this)));
        underlying.approve(futureVault, INITIAL_DEPOSIT);
        
        vault = new SecureVault(underlying);
        underlying.approve(address(vault), type(uint256).max);
        
        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);
        underlying.mint(alice, INITIAL_UNDERLYING_BALANCE);
        underlying.mint(bob, INITIAL_UNDERLYING_BALANCE);
        
        vm.prank(alice);
        underlying.approve(address(vault), type(uint256).max);
        
        vm.prank(bob);
        underlying.approve(address(vault), type(uint256).max);
    }

    function testFuzz_deposit(uint256 assets) public {
        // Bound assets to prevent overflow and unrealistic values
        assets = bound(assets, 1, INITIAL_UNDERLYING_BALANCE);
        
        vm.startPrank(alice);
        uint256 previewedShares = vault.previewDeposit(assets);
        uint256 sharesMinted = vault.deposit(assets, alice);
        
        assertEq(sharesMinted, previewedShares);
        assertEq(vault.balanceOf(alice), sharesMinted);
        assertEq(vault.totalAssets(), INITIAL_DEPOSIT + assets);
    }



    function testFuzz_manipulationResistance(uint256 amount1, uint256 amount2) public {
        amount1 = bound(amount1, 1 * 10**18, 100 * 10**18);
        amount2 = bound(amount2, 1 * 10**18, 100 * 10**18);
        
        vm.prank(alice);
        uint256 aliceShares = vault.deposit(amount1, alice);
        
        vm.prank(bob);
        uint256 bobShares = vault.deposit(amount2, bob);
        
        uint256 aliceAssetsPerShare = (amount1 * 10**18) / aliceShares;
        uint256 bobAssetsPerShare = (amount2 * 10**18) / bobShares;
        
        // Assert share prices remain within 1% of each other
        assertApproximatelyEq(aliceAssetsPerShare, bobAssetsPerShare, 10**16);
    }

    // Helper function
    function assertApproximatelyEq(uint256 a, uint256 b, uint256 maxDelta) internal {
        uint256 delta = a > b ? a - b : b - a;
        if (delta > maxDelta) {
            emit log("Error: Values are not approximately equal");
            emit log_named_uint("      Left", a);
            emit log_named_uint("     Right", b);
            emit log_named_uint("     Delta", delta);
            emit log_named_uint("  MaxDelta", maxDelta);
            fail();
        }
    }
}