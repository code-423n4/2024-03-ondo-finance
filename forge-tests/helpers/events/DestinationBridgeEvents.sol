pragma solidity 0.8.16;

contract DestinationBridgeEvents {
  event ApproverRemoved(address approver);
  event ApproverAdded(address approver);
  event ChainIdSupported(string indexed srcChain, string approvedSource);
  event ThresholdSet(
    string indexed chain,
    uint256[] amounts,
    uint256[] numOfApprovers
  );
  event BridgeCompleted(address indexed user, uint256 amount);
  event InstantMintLimitSet(uint256 instantMintLimit);
  event InstantRedemptionLimitSet(uint256 instantRedemptionLimit);
  event InstantMintLimitDurationSet(uint256 instantMintLimitDuration);
  event InstantRedemptionLimitDurationSet(uint256 redemptionLimitDuration);
  event Paused(address account);
  event Unpaused(address account);
  event MintLimitSet(uint256 mintLimit);
  event MintLimitDurationSet(uint256 instantMintLimitDuration);
  event TransactionApproved(
    bytes32 indexed txnHash,
    address approver,
    uint256 numApprovers,
    uint256 thresholdRequirement
  );
  event MessageReceived(
    bytes32 indexed txnHash,
    string indexed srcChain,
    address indexed srcSender,
    uint256 amt,
    uint256 nonce
  );
  event Transfer(address indexed from, address indexed to, uint256 value);
}
