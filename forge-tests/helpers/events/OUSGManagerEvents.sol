pragma solidity 0.8.16;

contract OUSGManagerEvents {
  event RedemptionProofAdded(
    bytes32 indexed txHash,
    address indexed user,
    uint256 rwaAmountBurned,
    uint256 timestamp
  );
}
