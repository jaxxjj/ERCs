// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC6372 {
  function clock() external view returns (uint48);
  function CLOCK_MODE() external view returns (string memory);
}