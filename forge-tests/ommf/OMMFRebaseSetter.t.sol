pragma solidity 0.8.16;

import "forge-tests/OMMF_BasicDeployment.sol";
import "contracts/ommf/ommf_token/OMMFRebaseSetter.sol";

contract Test_OMMF_RebaseSetter is OMMF_BasicDeployment {
  OMMFRebaseSetter rebaseSetter;

  function setUp() public override {
    super.setUp();
    _deployOMMFRebaseSetter();
    _setOracle(address(rebaseSetter));
  }

  function _deployOMMFRebaseSetter() internal {
    rebaseSetter = new OMMFRebaseSetter(guardian, address(this), address(ommf));
    oracle = address(rebaseSetter);
  }

  function test_ommfRebaser_setup() public {
    assertTrue(
      rebaseSetter.hasRole(rebaseSetter.DEFAULT_ADMIN_ROLE(), guardian)
    );
    assertTrue(rebaseSetter.hasRole(rebaseSetter.SETTER_ROLE(), address(this)));
    assertEq(ommf.depositedCash(), 0);
  }

  function test_ommfRebaser_setup_initializedOMMF() public {
    _mintRWAToUser(alice, 1000e18);
    rebaseSetter = new OMMFRebaseSetter(guardian, guardian, address(ommf));
    assertEq(ommf.depositedCash(), 1000e18);
  }

  function test_ommfRebaser_setRWAUnderlying_fail_accessControl() public {
    vm.expectRevert(_formatACRevert(alice, rebaseSetter.SETTER_ROLE()));
    vm.prank(alice);
    rebaseSetter.setRWAUnderlying(0, 100e18);
  }

  function test_ommfRebaser_setRWAUnderlying_fail_negative() public {
    vm.expectRevert(OMMFRebaseSetter.InvalidPrice.selector);
    rebaseSetter.setRWAUnderlying(0, -1);
  }

  function test_ommfRebaser_setRWAUnderlying_fail_zero() public {
    vm.expectRevert(OMMFRebaseSetter.InvalidPrice.selector);
    rebaseSetter.setRWAUnderlying(0, 0);
  }

  function test_ommfRebaser_setRWAUnderlying_fail_tooSoon() public {
    vm.expectRevert(OMMFRebaseSetter.PriceUpdateWindowViolation.selector);
    rebaseSetter.setRWAUnderlying(0, 100e18);
  }

  function test_ommfRebaser_setRWAUnderlying_fail_zeroVal() public {
    vm.warp(block.timestamp + rebaseSetter.MIN_PRICE_UPDATE_WINDOW());
    vm.expectRevert();
    rebaseSetter.setRWAUnderlying(0, 100e18);
  }

  function test_ommfRebaser_setRWAUnderlying_fail_tooLarge()
    public
    initializeOMMF
  {
    vm.warp(block.timestamp + rebaseSetter.MIN_PRICE_UPDATE_WINDOW());
    vm.expectRevert(
      OMMFRebaseSetter.DeltaDifferenceConstraintViolation.selector
    );
    rebaseSetter.setRWAUnderlying(100e18, 102e18);
  }

  function test_ommfRebaser_setRWAUnderlying_fail_tooSmall()
    public
    initializeOMMF
  {
    vm.warp(block.timestamp + rebaseSetter.MIN_PRICE_UPDATE_WINDOW());
    vm.expectRevert(
      OMMFRebaseSetter.DeltaDifferenceConstraintViolation.selector
    );
    rebaseSetter.setRWAUnderlying(100e18, 98e18);
  }

  function test_ommfRebaser_setRWAUnderlying() public initializeOMMF {
    vm.warp(block.timestamp + rebaseSetter.MIN_PRICE_UPDATE_WINDOW());
    vm.expectEmit(true, true, true, true);
    emit RWAUnderlyingSet(100e18, 100.5e18, block.timestamp);
    rebaseSetter.setRWAUnderlying(100e18, 100.5e18);
    assertEq(ommf.depositedCash(), 100.5e18);
  }

  function test_ommfRebaser_setRWAUnderlying_maxDeviationPositive()
    public
    initializeOMMF
  {
    vm.warp(block.timestamp + rebaseSetter.MIN_PRICE_UPDATE_WINDOW());
    rebaseSetter.setRWAUnderlying(100e18, 100.5e18);
    assertEq(ommf.depositedCash(), 100.5e18);
  }

  function test_ommfRebaser_setRWAUnderlying_maxDeviationNegative()
    public
    initializeOMMF
  {
    vm.warp(block.timestamp + rebaseSetter.MIN_PRICE_UPDATE_WINDOW());
    rebaseSetter.setRWAUnderlying(100e18, 99.5e18);
    assertEq(ommf.depositedCash(), 99.5e18);
  }

  function test_ommfRebaser_setRWAUnderlying_ommfIncrease()
    public
    initializeOMMF
  {
    _mintRWAToUser(alice, 100e18);
    vm.warp(block.timestamp + rebaseSetter.MIN_PRICE_UPDATE_WINDOW());

    // ommf cash is now 200e18, so we can set underlying at 202
    rebaseSetter.setRWAUnderlying(200e18, 200.5e18);
    assertEq(ommf.depositedCash(), 200.5e18);
  }

  function test_ommfRebaser_setRWAUnderlying_ommfDecrease()
    public
    initializeOMMF
  {
    vm.prank(guardian);
    ommf.adminBurn(alice, 50e18);
    vm.warp(block.timestamp + rebaseSetter.MIN_PRICE_UPDATE_WINDOW());

    // ommf cash is now at 50e18, so we can set underlying at 49.5
    rebaseSetter.setRWAUnderlying(50e18, 50e18);
    assertEq(ommf.depositedCash(), 50e18);
  }

  function test_ommfRebaser_setRWAUnderlying_fail_oldUnderlyingMismatch()
    public
    initializeOMMF
  {
    vm.warp(block.timestamp + rebaseSetter.MIN_PRICE_UPDATE_WINDOW());

    // Alice frontruns the rebase setter
    vm.prank(guardian);
    ommf.adminBurn(alice, 50e18);

    // OMMF cash is now at 50e18, but we think it's at 100e18 still
    vm.expectRevert(OMMFRebaseSetter.OldUnderlyingMismatch.selector);
    rebaseSetter.setRWAUnderlying(100e18, 49.5e18);
  }

  function test_ommfRebaser_setRWAUnderlyingOps_fail_accessControl() public {
    vm.expectRevert(_formatACRevert(alice, rebaseSetter.OPS_SETTER_ROLE()));
    vm.prank(alice);
    rebaseSetter.setRWAUnderlyingOps(0, 100e18);
  }

  function test_ommfRebaser_setRWAUnderlyingOps_fail_negative() public {
    vm.expectRevert();
    rebaseSetter.setRWAUnderlyingOps(0, -1);
  }

  function test_ommfRebaser_setRWAUnderlyingOps_fail_zero() public {
    vm.expectRevert();
    rebaseSetter.setRWAUnderlyingOps(0, 0);
  }

  function test_ommfRebaser_setRWAUnderlyingOps_fail_tooSoon() public {
    vm.expectRevert();
    rebaseSetter.setRWAUnderlyingOps(0, 100e18);
  }

  function test_ommfRebaser_setRWAUnderlyingOps_fail_zeroVal() public {
    vm.warp(block.timestamp + rebaseSetter.MIN_PRICE_UPDATE_WINDOW());
    vm.expectRevert();
    rebaseSetter.setRWAUnderlyingOps(0, 100e18);
  }

  function test_ommfRebaser_setRWAUnderlyingOps_fail_tooLarge()
    public
    initializeOMMF
  {
    vm.warp(block.timestamp + rebaseSetter.MIN_PRICE_UPDATE_WINDOW());
    vm.expectRevert(
      OMMFRebaseSetter.DeltaDifferenceConstraintViolation.selector
    );
    rebaseSetter.setRWAUnderlyingOps(100e18, 101e18);
  }

  function test_ommfRebaser_setRWAUnderlyingOps_fail_tooSmall()
    public
    initializeOMMF
  {
    vm.warp(block.timestamp + rebaseSetter.MIN_PRICE_UPDATE_WINDOW());
    vm.expectRevert(
      OMMFRebaseSetter.DeltaDifferenceConstraintViolation.selector
    );
    rebaseSetter.setRWAUnderlyingOps(100e18, 99e18);
  }

  function test_ommfRebaser_setRWAUnderlyingOps() public initializeOMMF {
    vm.warp(block.timestamp + rebaseSetter.MIN_PRICE_UPDATE_WINDOW());
    vm.expectEmit(true, true, true, true);
    emit RWAUnderlyingSet(100e18, 100.003e18, block.timestamp);
    rebaseSetter.setRWAUnderlyingOps(100e18, 100.003e18);
    assertEq(ommf.depositedCash(), 100.003e18);
  }

  function test_ommfRebaser_setRWAUnderlyingOps_maxDeviationPositive()
    public
    initializeOMMF
  {
    vm.warp(block.timestamp + rebaseSetter.MIN_PRICE_UPDATE_WINDOW());
    rebaseSetter.setRWAUnderlyingOps(100e18, 100.003e18);
    assertEq(ommf.depositedCash(), 100.003e18);
  }

  function test_ommfRebaser_setRWAUnderlyingOps_maxDeviationNegative()
    public
    initializeOMMF
  {
    vm.warp(block.timestamp + rebaseSetter.MIN_PRICE_UPDATE_WINDOW());
    rebaseSetter.setRWAUnderlyingOps(100e18, 99.997e18);
    assertEq(ommf.depositedCash(), 99.997e18);
  }

  function test_ommfRebaser_setRWAUnderlyingOps_ommfIncrease()
    public
    initializeOMMF
  {
    _mintRWAToUser(alice, 100e18);
    vm.warp(block.timestamp + rebaseSetter.MIN_PRICE_UPDATE_WINDOW());

    // ommf cash is now 200e18, so we can set underlying at 202
    rebaseSetter.setRWAUnderlyingOps(200e18, 200.003e18);
    assertEq(ommf.depositedCash(), 200.003e18);
  }

  function test_ommfRebaser_setRWAUnderlyingOps_ommfDecrease()
    public
    initializeOMMF
  {
    vm.prank(guardian);
    ommf.adminBurn(alice, 50e18);
    vm.warp(block.timestamp + rebaseSetter.MIN_PRICE_UPDATE_WINDOW());

    // ommf cash is now at 50e18, so we can set underlying at 49.5
    rebaseSetter.setRWAUnderlyingOps(50e18, 49.997e18);
    assertEq(ommf.depositedCash(), 49.997e18);
  }

  function test_ommfRebaser_setRWAUnderlyingOps_fail_oldUnderlyingMismatch()
    public
    initializeOMMF
  {
    vm.warp(block.timestamp + rebaseSetter.MIN_PRICE_UPDATE_WINDOW());

    // Alice frontruns the rebase setter
    vm.prank(guardian);
    ommf.adminBurn(alice, 50e18);

    // OMMF cash is now at 50e18, but we think it's at 100e18 still
    vm.expectRevert(OMMFRebaseSetter.OldUnderlyingMismatch.selector);
    rebaseSetter.setRWAUnderlyingOps(100e18, 100.003e18);
  }

  modifier initializeOMMF() {
    _mintRWAToUser(alice, 100e18);
    _;
  }

  event RWAUnderlyingSet(
    int256 oldRwaUnderlying,
    int256 newRwaUnderlying,
    uint256 timestamp
  );
}
