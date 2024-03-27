pragma solidity 0.8.16;

import {PROD_BRIDGE_MANTLE} from "forge-tests/postDeploymentConfig/prod_constants.t.sol";
import "forge-tests/USDY_BasicDeployment.sol";
import "contracts/bridge/SourceBridge.sol";

contract ASSERT_FORK_SRC_BRIDGE_PROD_MNT is
  PROD_BRIDGE_MANTLE,
  USDY_BasicDeployment
{
  /**
   * @notice INPUT ADDRESSES TO CHECK CONFIG OF BELOW
   *
   * USDY Deployment: 10/26/2023
   * Passing on block: 17693847
   */
  address srcBridgeAddr = 0x8Cbb8dB5CE28CF072776866F701368BBcf81F087;

  SourceBridge srcBridge;
  bytes32 impl_slot =
    bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
  bytes32 admin_slot = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

  function setUp() public override {
    srcBridge = SourceBridge(srcBridgeAddr);
  }

  function test_print_current_block() public view {
    console.log("The Current Block is: ", block.number);
  }

  function test_fork_assert_config_src_bridge() public {
    // Assert the owner
    assertEq(srcBridge.owner(), PROD_BRIDGE_MANTLE.src_owner);
    // Assert the bridge token
    assertEq(address(srcBridge.TOKEN()), PROD_BRIDGE_MANTLE.src_bridge_token);
    // Assert the chain Id
    assertEq(uint256(srcBridge.CHAIN_ID()), PROD_BRIDGE_MANTLE.chainId);
    // Assert the approved Chain
    assertEq(
      srcBridge.destChainToContractAddr(PROD_BRIDGE_MANTLE.src_approved_chain),
      PROD_BRIDGE_MANTLE.src_approved_contract_address
    );
    // Assert the paused state
    assertEq(srcBridge.paused(), PROD_BRIDGE_MANTLE.paused);
    // Assert the Axelar Gateway
    assertEq(
      address(srcBridge.AXELAR_GATEWAY()),
      PROD_BRIDGE_MANTLE.src_bridge_axelar_gateway
    );
    // Assert the Axelar Gas Service
    assertEq(
      address(srcBridge.GAS_RECEIVER()),
      PROD_BRIDGE_MANTLE.src_bridge_gas_receiver
    );
  }
}
