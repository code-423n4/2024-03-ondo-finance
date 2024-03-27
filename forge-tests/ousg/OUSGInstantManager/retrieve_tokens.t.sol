pragma solidity 0.8.16;
import "forge-tests/OUSG_BasicDeployment.t.sol";
import "forge-tests/ousg/OUSGInstantManager/buidl_helper.sol";

contract Test_OUSGInstant_retrieve_tokens_ETH is
  OUSG_BasicDeployment,
  BUIDLHelper
{
  function setUp() public override {
    super.setUp();
    _whitelistBUIDLWallet(address(ousgInstantManager));
    // Deviates from real world, this is a "pretend" Redeemer contract, as we don't have the real one yet
    _whitelistBUIDLWallet(address(mockBUIDLRedeemer));
    assertEq(ousg.balanceOf(alice), 0);
    assertEq(USDC.balanceOf(alice), 0);
    oracleCheckHarnessOUSG.setPrice(150e18);
    vm.startPrank(OUSG_GUARDIAN);
    // 10m USDC
    ousgInstantManager.setInstantMintLimit(10_000_000e6);
    // 10m USDC
    ousgInstantManager.setInstantRedemptionLimit(10_000_000e6);
    vm.stopPrank();
  }

  function test_rescue_tokens() public {
    uint256 buidlAmount = 10_000e6;
    vm.prank(BUIDL_WHALE);
    BUIDL.transfer(address(ousgInstantManager), buidlAmount);

    uint256 buidlWhaleBalance = BUIDL.balanceOf(BUIDL_WHALE);

    assertEq(BUIDL.balanceOf(address(ousgInstantManager)), buidlAmount);

    vm.startPrank(OUSG_GUARDIAN);
    ousgInstantManager.retrieveTokens(address(BUIDL), BUIDL_WHALE, buidlAmount);

    assertEq(BUIDL.balanceOf(address(ousgInstantManager)), 0);
    assertEq(BUIDL.balanceOf(BUIDL_WHALE), buidlAmount + buidlWhaleBalance);
  }

  function test_rescue_tokens__fail_AC() public {
    uint256 buidlAmount = 10_000e6;
    vm.prank(BUIDL_WHALE);
    BUIDL.transfer(address(ousgInstantManager), buidlAmount);

    assertEq(BUIDL.balanceOf(address(ousgInstantManager)), buidlAmount);

    vm.expectRevert(
      _formatACRevert(alice, ousgInstantManager.DEFAULT_ADMIN_ROLE())
    );
    vm.prank(alice);
    ousgInstantManager.retrieveTokens(address(BUIDL), alice, buidlAmount);
  }
}
