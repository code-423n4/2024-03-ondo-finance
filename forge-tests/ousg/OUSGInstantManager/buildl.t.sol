pragma solidity 0.8.16;
import "forge-tests/OUSG_BasicDeployment.t.sol";
import "forge-tests/ousg/OUSGInstantManager/buidl_helper.sol";

contract Test_OUSGInstant_buidl_ETH is OUSG_BasicDeployment, BUIDLHelper {
  function setUp() public override {
    super.setUp();
    _whitelistBUIDLWallet(address(ousgInstantManager));
    // Deviates from real world, this is a "pretend" Redeemer contract, as we don't have the real one yet
    _whitelistBUIDLWallet(address(mockBUIDLRedeemer));
  }

  /*//////////////////////////////////////////////////////////////
                        Sanity checks with BUIDL
  //////////////////////////////////////////////////////////////*/

  function test_add_wallet_to_registry() public {
    // Done in `setUp()`
    assertTrue(
      IBUIDLRegistryService(BUIDL_REGISTRY_SERVICE).isWallet(
        address(ousgInstantManager)
      )
    );
    // Already done at block #
    assertTrue(
      IBUIDLRegistryService(BUIDL_REGISTRY_SERVICE).isWallet(
        address(BUIDL_WHALE)
      )
    );
    // Already done at block #
    assertTrue(
      IBUIDLRegistryService(BUIDL_REGISTRY_SERVICE).isInvestor(
        BUIDL_WHALE_INVESTOR_ID
      )
    );
  }

  function test_buidl_transfer_to_instant_manager() public {
    uint256 initialBalance = IERC20(BUIDL).balanceOf(
      address(ousgInstantManager)
    );
    // Transfer 10 BUIDL to random holder
    vm.prank(BUIDL_WHALE);
    IERC20(BUIDL).transfer(address(ousgInstantManager), 10e6);
    uint256 finalBalance = IERC20(BUIDL).balanceOf(address(ousgInstantManager));
    assertEq(finalBalance, initialBalance + 10e6);
  }

  function test_buidl_transfer_to_random_holder() public {
    address randomBUIDLHolder = 0x12c0de58D3b720024324d5B216DDFE8B29adB0b4;
    IBUIDLRegistryService registry = IBUIDLRegistryService(
      BUIDL_REGISTRY_SERVICE
    );
    // this account has owned BUIDL and is not associated with Ondo.
    assertTrue(registry.isWallet(randomBUIDLHolder));

    uint256 initialBalance = IERC20(BUIDL).balanceOf(randomBUIDLHolder);
    // Transfer 10 BUIDL to random holder
    vm.prank(BUIDL_WHALE);
    IERC20(BUIDL).transfer(randomBUIDLHolder, 10e6);
    uint256 finalBalance = IERC20(BUIDL).balanceOf(randomBUIDLHolder);
    assertEq(finalBalance, initialBalance + 10e6);
  }

  // function test_redeem_from_ondo_ILP() public {
  //   uint256 initialBalance = IERC20(USDC).balanceOf(BUIDL_WHALE);
  //   console.log("init balance BUIDL_WHALE: ", BUIDL.balanceOf(BUIDL_WHALE));
  //   vm.startPrank(BUIDL_WHALE);
  //   IERC20(BUIDL).approve(BUIDL_REDEEMER, 10000e6);
  //   IBUIDLRedeemer(BUIDL_REDEEMER).redeem(100e6);
  //   // [FAIL. Reason: revert: Settlement: exceeds allowed amount] test_redeem() (gas: 491290)
  //   // TODO WHY?!!!
  //   uint256 finalBalance = IERC20(USDC).balanceOf(BUIDL_WHALE);
  //   console.log("USDC balance change: ", finalBalance - initialBalance);
  // }

  // function test_redeem_from_prev_redeemer() public {
  //   // this address has performed a redemption before
  //   address prevRedeemer = 0x1e695A689CF29c8fE0AF6848A957e3f84B61Fe69;
  //   uint256 initialBalance = IERC20(USDC).balanceOf(prevRedeemer);
  //   vm.startPrank(prevRedeemer);
  //   IERC20(BUIDL).approve(BUIDL_REDEEMER, 1e6);
  //   IBUIDLRedeemer(BUIDL_REDEEMER).redeem(1e6);
  //   vm.stopPrank();
  //   // [FAIL. Reason: revert: Settlement: exceeds allowed amount] test_redeem() (gas: 491290)
  //   // TODO WHY?!!!
  //   uint256 finalBalance = IERC20(USDC).balanceOf(prevRedeemer);
  //   console.log("USDC balance change: ", finalBalance - initialBalance);
  // }
}
