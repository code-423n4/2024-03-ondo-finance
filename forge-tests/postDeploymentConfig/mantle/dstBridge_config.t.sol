pragma solidity 0.8.16;

import {PROD_BRIDGE_MANTLE} from "forge-tests/postDeploymentConfig/prod_constants.t.sol";
import "forge-tests/USDY_BasicDeployment.sol";
import "contracts/bridge/DestinationBridge.sol";

contract ASSERT_FORK_DST_BRIDGE_PROD_MNT is
  PROD_BRIDGE_MANTLE,
  USDY_BasicDeployment
{
  /**
   * @notice INPUT ADDRESSES TO CHECK CONFIG OF BELOW
   *
   * USDY Deployment: 10/26/23
   * Passing on block: 17692828
   */
  address dstBridgeAddr = 0xd5235958c1F8a40641847A0E3BD51d04EFe9eC28;

  struct Threshold {
    uint256 amount;
    uint256 numberOfApprovalsNeeded;
  }

  DestinationBridge dstBridge;

  function setUp() public override {
    dstBridge = DestinationBridge(dstBridgeAddr);
  }

  function test_print_current_block() public view {
    console.log("The Current Block is: ", block.number);
  }

  function test_fork_assert_config_dst_bridge() public {
    // Assert the owner
    assertEq(dstBridge.owner(), PROD_BRIDGE_MANTLE.dst_owner);
    // Assert the gateway
    assertEq(
      address(dstBridge.AXELAR_GATEWAY()),
      PROD_BRIDGE_MANTLE.dst_axelar_gateway
    );
    // Assert the allowlist if applicable
    assertEq(address(dstBridge.ALLOWLIST()), PROD_BRIDGE_MANTLE.dst_allowlist);
    // Assert the token
    assertEq(address(dstBridge.TOKEN()), PROD_BRIDGE_MANTLE.dst_bridge_token);
    // Assert the chain approved sender
    assertEq(
      dstBridge.chainToApprovedSender(PROD_BRIDGE_MANTLE.dst_approved_chain),
      keccak256(abi.encode(PROD_BRIDGE_MANTLE.dst_approved_sender))
    );
    // Assert the approvers
    for (uint256 i; i < PROD_BRIDGE_MANTLE.approvers.length; i++) {
      assertEq(dstBridge.approvers(PROD_BRIDGE_MANTLE.approvers[i]), true);
    }
    // Assert the thresholds amt
    for (uint256 i; i < PROD_BRIDGE_MANTLE.threshold_amounts.length; i++) {
      (uint256 amount, uint256 approvals) = dstBridge.chainToThresholds(
        PROD_BRIDGE_MANTLE.dst_approved_chain,
        i
      );
      assertEq(amount, PROD_BRIDGE_MANTLE.threshold_amounts[i]);
      assertEq(approvals, PROD_BRIDGE_MANTLE.threshold_approvers[i]);
    }

    assertEq(dstBridge.mintLimit(), PROD_BRIDGE_MANTLE.mint_limit);
    assertEq(dstBridge.resetMintDuration(), 1 days);
  }
}
