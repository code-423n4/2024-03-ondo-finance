pragma solidity 0.8.16;

import {PROD_BRIDGE_MAINNET} from "forge-tests/postDeploymentConfig/prod_constants.t.sol";
import "forge-tests/USDY_BasicDeployment.sol";
import "contracts/bridge/SourceBridge.sol";

contract ASSERT_FORK_SRC_BRIDGE_PROD_ETH is
  PROD_BRIDGE_MAINNET,
  USDY_BasicDeployment
{
  /**
   * @notice INPUT ADDRESSES TO CHECK CONFIG OF BELOW
   *
   * USDY Deployment: 10/26/2023
   * Passing on block: 18436094
   */
  address srcBridgeAddr = 0xD89655ECf4800251880f8f6BA9038970AD9813dB;

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
    assertEq(srcBridge.owner(), PROD_BRIDGE_MAINNET.src_owner);
    // Assert the bridge token
    assertEq(address(srcBridge.TOKEN()), PROD_BRIDGE_MAINNET.src_bridge_token);
    // Assert the chain Id
    assertEq(uint256(srcBridge.CHAIN_ID()), PROD_BRIDGE_MAINNET.chainId);
    // Assert the approved Chain
    assertEq(
      srcBridge.destChainToContractAddr(PROD_BRIDGE_MAINNET.src_approved_chain),
      PROD_BRIDGE_MAINNET.src_approved_contract_address
    );
    // Assert the paused state
    assertEq(srcBridge.paused(), PROD_BRIDGE_MAINNET.paused);
    // Assert the Axelar Gateway
    assertEq(
      address(srcBridge.AXELAR_GATEWAY()),
      PROD_BRIDGE_MAINNET.src_bridge_axelar_gateway
    );
    // Assert the Axelar Gas Service
    assertEq(
      address(srcBridge.GAS_RECEIVER()),
      PROD_BRIDGE_MAINNET.src_bridge_gas_receiver
    );
  }
}
