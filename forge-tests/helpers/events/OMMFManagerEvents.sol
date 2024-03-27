pragma solidity 0.8.16;

contract OMMFManagerEvents {
  event WrappedMintCompleted(
    address indexed user,
    bytes32 indexed depositId,
    uint256 rwaAmountOut,
    uint256 wRWAAmountOut,
    uint256 collateralAmountDeposited,
    uint256 exchangeRate
  );

  event RedemptionProofAdded(
    bytes32 indexed txHash,
    address indexed user,
    uint256 rwaAmountBurned,
    uint256 timestamp
  );

  event WrappedRedemptionRequested(
    address indexed user,
    bytes32 indexed redemptionId,
    uint256 rwaAmountIn,
    uint256 wrappedCashAmountIn
  );
}
