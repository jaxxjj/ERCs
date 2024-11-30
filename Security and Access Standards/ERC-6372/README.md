# ERC-6372: Contract Clock Standard

## Introduction

ERC-6372 defines a standard interface for time tracking in smart contracts. It provides a unified way to handle both block-based and timestamp-based timing mechanisms, enabling consistent time handling across different contracts and protocols.

## Overview

The standard introduces two key functions:
- `clock()`: Returns the current timepoint
- `CLOCK_MODE()`: Describes the timing mechanism being used

## Specification

### Clock Function
```solidity
function clock() external view returns (uint48);
```
- Returns the current timepoint according to the contract's timing mode
- Must be gas efficient (< 30,000 gas)
- Returns either block number or timestamp
- Uses uint48 to save gas while supporting long timeframes

### Clock Mode
```solidity
function CLOCK_MODE() external view returns (string memory);
```
- Returns a machine-readable string describing the clock mode
- Two standard modes:
  - `"mode=timestamp"`: Uses block.timestamp
  - `"mode=block"`: Uses block.number

## Use Cases

### 1. Governance Systems
- Voting period tracking
- Proposal timing
- Execution delays
- Timelock mechanisms

### 2. Token Vesting
- Vesting period tracking
- Release schedules
- Time-based unlocks

### 3. Staking Contracts
- Staking durations
- Reward calculations
- Lock periods
- Cooldown timers

## Implementation Considerations

### 1. Timestamp Mode
```solidity
function clock() public view returns (uint48) {
    return uint48(block.timestamp);
}

function CLOCK_MODE() public pure returns (string memory) {
    return "mode=timestamp";
}
```

### 2. Block Number Mode
```solidity
function clock() public view returns (uint48) {
    return uint48(block.number);
}

function CLOCK_MODE() public pure returns (string memory) {
    return "mode=block";
}
```

## Best Practices

### 1. Mode Selection
- **Timestamp Mode**
  - Better for human-readable timing
  - Suitable for longer durations
  - Less precise due to block time variations
  
- **Block Number Mode**
  - More precise timing
  - Better for short durations
  - Consistent across networks

### 2. Gas Optimization
- Use uint48 for time values
- Minimize storage operations
- Batch time-based operations

### 3. Security Considerations
- Account for block time variations
- Handle potential timestamp manipulation
- Consider cross-chain compatibility

## Integration Guidelines

### 1. Governance Integration
```solidity
require(clock() >= proposal.startTime, "Not started");
require(clock() <= proposal.endTime, "Ended");
```

### 2. Vesting Integration
```solidity
uint48 vestingStart = clock();
uint48 vestingEnd = vestingStart + vestingDuration;
```

### 3. Staking Integration
```solidity
uint48 stakingTime = clock();
uint48 unlockTime = stakingTime + lockPeriod;
```

## Common Patterns

### 1. Time Tracking
- Store timepoints as uint48
- Use consistent comparison logic
- Handle time transitions

### 2. Duration Calculations
- Safe arithmetic for time math
- Duration bounds checking
- Overflow prevention

### 3. Mode Compatibility
- Check CLOCK_MODE before integration
- Handle mode-specific logic
- Support mode transitions

## Benefits

1. **Standardization**
   - Consistent time handling
   - Cross-contract compatibility
   - Clear timing semantics

2. **Flexibility**
   - Multiple timing modes
   - Easy mode switching
   - Network adaptability

3. **Gas Efficiency**
   - Optimized storage
   - Minimal computation
   - Reduced transaction costs

## Testing Recommendations

1. **Mode Testing**
   - Verify mode consistency
   - Test mode transitions
   - Validate time calculations

2. **Edge Cases**
   - Zero timepoints
   - Maximum timepoints
   - Mode transitions

3. **Integration Testing**
   - Cross-contract timing
   - Mode compatibility
   - Time synchronization

## References

- [EIP-6372](https://eips.ethereum.org/EIPS/eip-6372)
- [Ethereum Yellow Paper](https://ethereum.github.io/yellowpaper/paper.pdf)
- [Block vs Timestamp](https://ethereum.stackexchange.com/questions/413/can-a-contract-safely-rely-on-block-timestamp)

## License

MIT
