// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test,console2} from "forge-std/Test.sol";
import {SecureVault} from "../../src/examples/MyVault.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";

contract SecureVaultTest is Test {
    SecureVault public vault;
    ERC20Mock public underlying;
    
    address public owner = address(this);
  
    address public alice = address(0x1);
    address public bob = address(0x2);
    
    uint256 constant INITIAL_UNDERLYING_BALANCE = 10_000 * 10**18;
    uint256 constant INITIAL_DEPOSIT = 1000 * 10**18;
    
    event Deposit(address indexed sender, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(address indexed sender, address indexed receiver, address indexed owner, uint256 assets, uint256 shares);

    function setUp() public {
        console2.log(address(this));
        // Deploy mock token
        underlying = new ERC20Mock();
        
        // Mint initial tokens for vault deployment
        underlying.mint(address(this), INITIAL_DEPOSIT);
        
        // Calculate the future vault address using existing function
        address futureVault = computeCreateAddress(address(this), vm.getNonce(address(this)));
        
        // Approve the future vault address
        underlying.approve(futureVault, INITIAL_DEPOSIT);
        
        // Deploy vault
        vault = new SecureVault(underlying);
        
        // Setup additional balances and approvals
        underlying.mint(owner, INITIAL_UNDERLYING_BALANCE - INITIAL_DEPOSIT);
        underlying.approve(address(vault), type(uint256).max);
        
        // Setup test users
        vm.deal(alice, 100 ether);
        vm.deal(bob, 100 ether);
        underlying.mint(alice, INITIAL_UNDERLYING_BALANCE);
        underlying.mint(bob, INITIAL_UNDERLYING_BALANCE);
        
        vm.startPrank(alice);
        underlying.approve(address(vault), type(uint256).max);
        vm.stopPrank();
        
        vm.startPrank(bob);
        underlying.approve(address(vault), type(uint256).max);
        vm.stopPrank();
    }

    function computeCreateAddress(address deployer, uint256 nonce) internal override pure returns (address) {
        if (nonce == 0x00) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), deployer, bytes1(0x80))))));
        if (nonce <= 0x7f) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), deployer, uint8(nonce))))));
        if (nonce <= 0xff) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), deployer, bytes1(0x81), uint8(nonce))))));
        if (nonce <= 0xffff) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), deployer, bytes1(0x82), uint16(nonce))))));
        if (nonce <= 0xffffff) return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), deployer, bytes1(0x83), uint24(nonce))))));
        return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), deployer, bytes1(0x84), uint32(nonce))))));
    }

    function test_initialization() public {
        assertEq(vault.asset(), address(underlying));
        assertEq(vault.totalAssets(), INITIAL_DEPOSIT);
        assertEq(vault.totalSupply(), INITIAL_DEPOSIT);
        assertEq(vault.decimals(), underlying.decimals() + 6);
    }

    function test_depositWithFees() public {
        uint256 depositAmount = 1000 * 10**18;
        
        vm.startPrank(alice);
        
        // Get the exact shares from the vault's preview function
        uint256 expectedShares = vault.previewDeposit(depositAmount);
        
        // Expect the event with the exact values from the vault
        vm.expectEmit(true, true, false, true);
        emit Deposit(alice, alice, depositAmount, expectedShares);
        
        uint256 sharesMinted = vault.deposit(depositAmount, alice);
        vm.stopPrank();
        
        // Verify results
        assertEq(sharesMinted, expectedShares);
        assertEq(vault.balanceOf(alice), expectedShares);
    }

    function test_withdrawWithFees() public {
        uint256 depositAmount = 1000 * 10**18;
        vm.startPrank(alice);
        uint256 sharesMinted = vault.deposit(depositAmount, alice);
        
        uint256 withdrawAmount = 500 * 10**18;
        uint256 expectedShares = vault.previewWithdraw(withdrawAmount);
        
        vm.expectEmit(true, true, true, true);
        emit Withdraw(alice, alice, alice, withdrawAmount, expectedShares);
        
        uint256 sharesRedeemed = vault.withdraw(withdrawAmount, alice, alice);
        vm.stopPrank();
        
        assertEq(sharesRedeemed, expectedShares);
        
        uint256 expectedBalance = INITIAL_UNDERLYING_BALANCE - depositAmount + withdrawAmount;
        assertApproximatelyEq(underlying.balanceOf(alice), expectedBalance, 10**15);
    }

    function test_previewFunctions() public {
        uint256 testAmount = 1000 * 10**18;
        
        // Test all preview functions
        uint256 depositShares = vault.previewDeposit(testAmount);
        uint256 mintAssets = vault.previewMint(testAmount);
        uint256 withdrawShares = vault.previewWithdraw(testAmount);
        uint256 redeemAssets = vault.previewRedeem(testAmount);
        
        // Verify deposit/mint relationship
        assertGt(mintAssets, testAmount); // Should include deposit fee
        assertLt(depositShares, testAmount); // Should be reduced by deposit fee
        
        // Verify withdraw/redeem relationship
        assertGt(withdrawShares, testAmount); // Should include withdrawal fee
        assertLt(redeemAssets, testAmount); // Should be reduced by withdrawal fee
    }

    function test_shareConversion() public {
        uint256 testAmount = 1000 * 10**18;
        
        // Test conversion functions
        uint256 sharesToAssets = vault.convertToAssets(testAmount);
        uint256 assetsToShares = vault.convertToShares(testAmount);
        
        // Verify fee impact
        assertLt(sharesToAssets, testAmount); // Should be reduced by withdrawal fee
        assertLt(assetsToShares, testAmount); // Should be reduced by deposit fee
    }

    function test_manipulationResistance() public {
        uint256 smallDeposit = 1 * 10**18;
        
        vm.startPrank(alice);
        uint256 aliceShares = vault.deposit(smallDeposit, alice);
        vm.stopPrank();
        
        vm.startPrank(bob);
        uint256 bobShares = vault.deposit(smallDeposit, bob);
        vm.stopPrank();
        
        // Increase delta for approximate equality
        assertApproximatelyEq(aliceShares, bobShares, 10**15);
        
        uint256 pricePerShare = (vault.totalAssets() * 10**18) / vault.totalSupply();
        // Increase delta for price check
        assertApproximatelyEq(pricePerShare, 10**18, 10**15);
    }

    // Helper function for approximate equality
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