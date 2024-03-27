// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "forge-tests/BaseTestRunner.sol";
import "forge-tests/helpers/events/RWAHubInstantMintEvents.sol";
import "contracts/RWAHubInstantMints.sol";

abstract contract Test_RWAHub_InstantMinting is
  BaseTestRunner,
  RWAHubInstantMintEvents
{
  RWAHubInstantMints rwaHubInstantMint;

  uint256 public instantMintPriceId;
  uint256 public instantRedemptionPriceId;

  function _setRwaHubInstantMint(address _rwaHubInstantMint) internal {
    rwaHubInstantMint = RWAHubInstantMints(_rwaHubInstantMint);
    vm.startPrank(managerAdmin);
    rwaHubInstantMint.unpauseInstantMint();
    rwaHubInstantMint.unpauseInstantRedemption();
    vm.stopPrank();
  }

  function test_rwaHubInstantMint_initialization() public {
    assertEq(
      rwaHubInstantMint.instantMintAssetManager(),
      instantMintAssetManager
    );
    assertEq(rwaHubInstantMint.instantMintFee(), 10);
    assertEq(rwaHubInstantMint.instantRedemptionFee(), 10);
    assertEq(rwaHubInstantMint.resetInstantMintDuration(), 0);
    assertEq(rwaHubInstantMint.lastResetInstantMintTime(), block.timestamp);
    assertEq(rwaHubInstantMint.instantMintLimit(), 0);
    assertEq(rwaHubInstantMint.currentInstantMintAmount(), 0);
    assertEq(rwaHubInstantMint.resetInstantRedemptionDuration(), 0);
    assertEq(
      rwaHubInstantMint.lastResetInstantRedemptionTime(),
      block.timestamp
    );
    assertEq(rwaHubInstantMint.instantRedemptionLimit(), 0);
    assertEq(rwaHubInstantMint.currentInstantRedemptionAmount(), 0);
  }

  /*//////////////////////////////////////////////////////////////
                             Setters
  //////////////////////////////////////////////////////////////*/

  function test_rwaHubInstantMint_setInstantMintAssetManager_fail_ac() public {
    vm.expectRevert(
      _formatACRevert(address(this), rwaHubInstantMint.MANAGER_ADMIN())
    );
    rwaHubInstantMint.setInstantMintAssetManager(address(this));
  }

  function test_rwaHubInstantMint_setIntantMintAssetManager() public {
    vm.prank(managerAdmin);
    vm.expectEmit(true, true, true, true);
    emit InstantMintAssetManagerSet(instantMintAssetManager, address(this));
    rwaHubInstantMint.setInstantMintAssetManager(address(this));
  }

  function test_rwaHubInstantMint_setInstantMintFee_fail_ac() public {
    vm.expectRevert(
      _formatACRevert(address(this), rwaHubInstantMint.MANAGER_ADMIN())
    );
    rwaHubInstantMint.setInstantMintFee(100);
  }

  function test_rwaHubInstantMint_setInstantMintFee_fail_tooLarge() public {
    vm.prank(managerAdmin);
    vm.expectRevert(IRWAHub.FeeTooLarge.selector);
    rwaHubInstantMint.setInstantMintFee(10001);
  }

  function test_rwaHubInstantMint_setInstantMintFee() public {
    vm.prank(managerAdmin);
    vm.expectEmit(true, true, true, true);
    emit InstantMintFeeSet(10, 100);
    rwaHubInstantMint.setInstantMintFee(100);
    assertEq(rwaHubInstantMint.instantMintFee(), 100);
  }

  function test_rwaHubInstantMint_setInstantRedemptionFee_fail_ac() public {
    vm.expectRevert(
      _formatACRevert(address(this), rwaHubInstantMint.MANAGER_ADMIN())
    );
    rwaHubInstantMint.setInstantRedemptionFee(100);
  }

  function test_rwaHubInstantMint_setInstantRedemptionFee_fail_tooLarge()
    public
  {
    vm.prank(managerAdmin);
    vm.expectRevert(IRWAHub.FeeTooLarge.selector);
    rwaHubInstantMint.setInstantRedemptionFee(10001);
  }

  function test_rwaHubInstantMint_setInstantRedemptionFee() public {
    vm.prank(managerAdmin);
    vm.expectEmit(true, true, true, true);
    emit InstantRedemptionFeeSet(10, 100);
    rwaHubInstantMint.setInstantRedemptionFee(100);
    assertEq(rwaHubInstantMint.instantRedemptionFee(), 100);
  }

  function test_rwaHubInstantMint_setInstantMintPriceId_fail_ac() public {
    vm.expectRevert(
      _formatACRevert(address(this), rwaHubInstantMint.PRICE_ID_SETTER_ROLE())
    );
    rwaHubInstantMint.setInstantMintPriceId(1);
  }

  function test_rwaHubInstantMint_setInstantMintPriceId() public {
    vm.prank(managerAdmin);
    vm.expectEmit(true, true, true, true);
    emit PriceIdSetForInstantMint(1);
    rwaHubInstantMint.setInstantMintPriceId(1);
    assertEq(rwaHubInstantMint.instantMintPriceId(), 1);
  }

  function test_rwaHubInstantMint_setInstantRedemptionPriceId_fail_ac() public {
    vm.expectRevert(
      _formatACRevert(address(this), rwaHubInstantMint.PRICE_ID_SETTER_ROLE())
    );
    rwaHubInstantMint.setInstantRedemptionPriceId(1);
  }

  function test_rwaHubInstantMint_setInstantRedemptionPriceId() public {
    vm.prank(managerAdmin);
    vm.expectEmit(true, true, true, true);
    emit PriceIdSetForInstantRedemption(1);
    rwaHubInstantMint.setInstantRedemptionPriceId(1);
    assertEq(rwaHubInstantMint.instantRedemptionPriceId(), 1);
  }

  function test_rwaHubInstantMint_pauseInstantMint_fail_ac() public {
    vm.expectRevert(
      _formatACRevert(address(this), rwaHubInstantMint.PAUSER_ADMIN())
    );
    rwaHubInstantMint.pauseInstantMint();
  }

  function test_rwaHubInstantMint_pauseInstantMint() public {
    vm.prank(pauser);
    vm.expectEmit(true, true, true, true);
    emit InstantMintPaused(pauser);
    rwaHubInstantMint.pauseInstantMint();
    assertTrue(rwaHubInstantMint.instantMintPaused());
  }

  function test_rwaHubInstantMint_unpauseInstantMint_fail_ac() public {
    vm.expectRevert(
      _formatACRevert(address(this), rwaHubInstantMint.MANAGER_ADMIN())
    );
    rwaHubInstantMint.unpauseInstantMint();
  }

  function test_rwaHubInstantMint_unpauseInstantMint() public {
    test_rwaHubInstantMint_pauseInstantMint();
    vm.prank(managerAdmin);
    vm.expectEmit(true, true, true, true);
    emit InstantMintUnpaused(managerAdmin);
    rwaHubInstantMint.unpauseInstantMint();
    assertFalse(rwaHubInstantMint.instantMintPaused());
  }

  function test_rwaHubInstantMint_pauseInstantRedemption_fail_ac() public {
    vm.expectRevert(
      _formatACRevert(address(this), rwaHubInstantMint.PAUSER_ADMIN())
    );
    rwaHubInstantMint.pauseInstantRedemption();
  }

  function test_rwaHubInstantMint_pauseInstantRedemption() public {
    vm.prank(pauser);
    vm.expectEmit(true, true, true, true);
    emit InstantRedemptionPaused(pauser);
    rwaHubInstantMint.pauseInstantRedemption();
    assertTrue(rwaHubInstantMint.instantRedemptionPaused());
  }

  function test_rwaHubInstantMint_unpauseInstantRedemption_fail_ac() public {
    vm.expectRevert(
      _formatACRevert(address(this), rwaHubInstantMint.MANAGER_ADMIN())
    );
    rwaHubInstantMint.unpauseInstantRedemption();
  }

  function test_rwaHubInstantMint_unpauseInstantRedemption() public {
    test_rwaHubInstantMint_pauseInstantRedemption();
    vm.prank(managerAdmin);
    vm.expectEmit(true, true, true, true);
    emit InstantRedemptionUnpaused(managerAdmin);
    rwaHubInstantMint.unpauseInstantRedemption();
    assertFalse(rwaHubInstantMint.instantRedemptionPaused());
  }

  function test_rwaHubInstantMint_setInstantMintLimit_fail_ac() public {
    vm.expectRevert(
      _formatACRevert(address(this), rwaHubInstantMint.MANAGER_ADMIN())
    );
    rwaHubInstantMint.setInstantMintLimit(100e18);
  }

  function test_rwaHubInstantMint_setInstantMintLimit() public {
    vm.prank(managerAdmin);
    vm.expectEmit(true, true, true, true);
    emit InstantMintLimitSet(100e18);
    rwaHubInstantMint.setInstantMintLimit(100e18);
    assertEq(rwaHubInstantMint.instantMintLimit(), 100e18);
  }

  function test_rwaHubInstantMint_setInstantRedemptionLimit_fail_ac() public {
    vm.expectRevert(
      _formatACRevert(address(this), rwaHubInstantMint.MANAGER_ADMIN())
    );
    rwaHubInstantMint.setInstantRedemptionLimit(100e18);
  }

  function test_rwaHubInstantMint_setInstantRedemptionLimit() public {
    vm.prank(managerAdmin);
    vm.expectEmit(true, true, true, true);
    emit InstantRedemptionLimitSet(100e18);
    rwaHubInstantMint.setInstantRedemptionLimit(100e18);
    assertEq(rwaHubInstantMint.instantRedemptionLimit(), 100e18);
  }

  function test_rwaHubInstantMint_setInstantMintLimitDuration_fail_ac() public {
    vm.expectRevert(
      _formatACRevert(address(this), rwaHubInstantMint.MANAGER_ADMIN())
    );
    rwaHubInstantMint.setInstantMintLimitDuration(100);
  }

  function test_rwaHubInstantMint_setInstantMintLimitDuration() public {
    vm.prank(managerAdmin);
    vm.expectEmit(true, true, true, true);
    emit InstantMintLimitDurationSet(100);
    rwaHubInstantMint.setInstantMintLimitDuration(100);
    assertEq(rwaHubInstantMint.resetInstantMintDuration(), 100);
  }

  function test_rwaHubInstantMint_setInstantRedemptionLimitDuration_fail_ac()
    public
  {
    vm.expectRevert(
      _formatACRevert(address(this), rwaHubInstantMint.MANAGER_ADMIN())
    );
    rwaHubInstantMint.setInstantRedemptionLimitDuration(100);
  }

  function test_rwaHubInstantMint_setInstantRedemptionLimitDuration() public {
    vm.prank(managerAdmin);
    vm.expectEmit(true, true, true, true);
    emit InstantRedemptionLimitDurationSet(100);
    rwaHubInstantMint.setInstantRedemptionLimitDuration(100);
    assertEq(rwaHubInstantMint.resetInstantRedemptionDuration(), 100);
  }

  /*//////////////////////////////////////////////////////////////
                       Instant Mint Functions
  //////////////////////////////////////////////////////////////*/

  function test_rwaHubInstantMint_instantMint_fail_mintPaused() public {
    vm.prank(pauser);
    rwaHubInstantMint.pauseInstantMint();
    vm.prank(alice);
    vm.expectRevert(IRWAHub.FeaturePaused.selector);
    rwaHubInstantMint.instantMint(100e6);
  }

  function test_rwaHubInstantMint_instantMint_fail_depositTooSmall() public {
    vm.expectRevert(IRWAHub.DepositTooSmall.selector);
    rwaHubInstantMint.instantMint(100);
  }

  function test_rwaHubInstantMint_instantMint_fail_priceIdNotSet() public {
    vm.expectRevert(IRWAHub.PriceIdNotSet.selector);
    rwaHubInstantMint.instantMint(100e6);
  }

  function test_rwaHubInstantMint_instantMint_fail_zeroMintLimit() public {
    vm.prank(managerAdmin);
    rwaHubInstantMint.setInstantMintPriceId(1);

    vm.startPrank(alice);
    _seedWithCollateral(alice, 10_000e6);
    USDC.approve(address(rwaHubInstantMint), 10_000e6);
    vm.expectRevert("RateLimit: Mint exceeds rate limit");
    rwaHubInstantMint.instantMint(10_000e6);
    vm.stopPrank();
  }

  function test_rwaHubInstantMint_instantMint() public initializeInstantMints {
    _seedWithCollateral(alice, 10_000e6);
    vm.startPrank(alice);
    USDC.approve(address(rwaHubInstantMint), 10_000e6);
    vm.expectEmit(true, true, true, true);
    emit InstantMintCompleted(
      alice,
      10_000e6,
      9990e6,
      10e6,
      9990e18,
      pricer.getPrice(instantMintPriceId)
    );
    rwaHubInstantMint.instantMint(10_000e6);
    vm.stopPrank();

    assertEq(USDC.balanceOf(instantMintAssetManager), 10_000e6);
    assertEq(rwa.balanceOf(alice), 9990e18);
    assertEq(rwaHubInstantMint.currentInstantMintAmount(), 9990e18);
  }

  function test_rwaHubInstantMint_instantMint_secondMint_noLimit() public {
    test_rwaHubInstantMint_instantMint();

    vm.prank(managerAdmin);
    rwaHubInstantMint.setInstantMintLimitDuration(0);

    _seedWithCollateral(alice, 10_000e6);
    vm.startPrank(alice);
    USDC.approve(address(rwaHubInstantMint), 10_000e6);
    rwaHubInstantMint.instantMint(10_000e6);
    vm.stopPrank();

    assertEq(USDC.balanceOf(instantMintAssetManager), 20_000e6);
    assertEq(rwa.balanceOf(alice), 19_980e18);
    assertEq(rwaHubInstantMint.currentInstantMintAmount(), 9990e18);
  }

  function test_rwaHubInstantMint_instantMint_secondMint_fail_limit() public {
    test_rwaHubInstantMint_instantMint();

    _seedWithCollateral(alice, 10_000e6);
    vm.startPrank(alice);
    USDC.approve(address(rwaHubInstantMint), 10_000e6);
    vm.expectRevert("RateLimit: Mint exceeds rate limit");
    rwaHubInstantMint.instantMint(10_000e6);
    vm.stopPrank();
  }

  function test_rwaHubInstantMint_instantMint_secondMint() public {
    test_rwaHubInstantMint_instantMint();

    vm.warp(block.timestamp + 1 days);
    _seedWithCollateral(alice, 10_000e6);
    vm.startPrank(alice);
    USDC.approve(address(rwaHubInstantMint), 10_000e6);
    rwaHubInstantMint.instantMint(10_000e6);
    vm.stopPrank();

    assertEq(USDC.balanceOf(instantMintAssetManager), 20_000e6);
    assertEq(rwa.balanceOf(alice), 19_980e18);
    assertEq(rwaHubInstantMint.currentInstantMintAmount(), 9990e18);
  }

  /*//////////////////////////////////////////////////////////////
                       Instant Redeem Functions
  //////////////////////////////////////////////////////////////*/

  function test_rwaHubInstantMint_instantRedemption_fail_redeemPaused() public {
    vm.prank(pauser);
    rwaHubInstantMint.pauseInstantRedemption();
    vm.prank(alice);
    vm.expectRevert(IRWAHub.FeaturePaused.selector);
    rwaHubInstantMint.instantRedemption(10_000e18);
  }

  function test_rwaHubInstantMint_instantRedemption_fail_redemptionTooSmall()
    public
  {
    vm.expectRevert(IRWAHub.RedemptionTooSmall.selector);
    rwaHubInstantMint.instantRedemption(100);
  }

  function test_rwaHubInstantMint_instantRedemption_fail_priceIdNotSet()
    public
  {
    vm.expectRevert(IRWAHub.PriceIdNotSet.selector);
    rwaHubInstantMint.instantRedemption(10_000e18);
  }

  function test_rwaHubInstantMint_instantRedemption_fail_zeroRedemptionLimit()
    public
  {
    vm.prank(managerAdmin);
    rwaHubInstantMint.setInstantRedemptionPriceId(1);

    vm.prank(alice);
    vm.expectRevert("RateLimit: Redemption exceeds rate limit");
    rwaHubInstantMint.instantRedemption(10_000e18);
  }

  function test_rwaHubInstantMint_instantRedemption()
    public
    initializeInstantRedemptions
  {
    _mintRWAToUser(alice, 10_000e18);

    vm.startPrank(alice);
    rwa.approve(address(rwaHubInstantMint), 10_000e18);
    vm.expectEmit(true, true, true, true);
    emit InstantRedemptionCompleted(
      alice,
      10_000e18,
      9990e6,
      10e6,
      pricer.getPrice(instantRedemptionPriceId),
      instantRedemptionPriceId
    );
    rwaHubInstantMint.instantRedemption(10_000e18);
    vm.stopPrank();

    assertEq(rwa.balanceOf(alice), 0);
    assertEq(rwa.totalSupply(), 0);
    assertEq(USDC.balanceOf(alice), 9990e6);
    assertEq(USDC.balanceOf(instantMintAssetManager), 10e6);
    assertEq(rwaHubInstantMint.currentInstantRedemptionAmount(), 10_000e18);
  }

  function test_rwaHubInstantMint_instantRedemption_secondRedeem_noLimit()
    public
  {
    test_rwaHubInstantMint_instantRedemption();

    _mintRWAToUser(alice, 10_000e18);

    // Seed instantMintAssetManager for redemption
    // balance doesn't transfer over so adding extra 10 here
    _seedWithCollateral(instantMintAssetManager, 10_010e6);
    vm.prank(instantMintAssetManager);
    USDC.approve(address(rwaHubInstantMint), 10_000e6);

    vm.prank(managerAdmin);
    rwaHubInstantMint.setInstantRedemptionLimitDuration(0);

    vm.startPrank(alice);
    rwa.approve(address(rwaHubInstantMint), 10_000e18);
    rwaHubInstantMint.instantRedemption(10_000e18);
    vm.stopPrank();

    assertEq(rwa.balanceOf(alice), 0);
    assertEq(rwa.totalSupply(), 0);
    assertEq(USDC.balanceOf(alice), 19_980e6);
    assertEq(USDC.balanceOf(instantMintAssetManager), 20e6);
    assertEq(rwaHubInstantMint.currentInstantRedemptionAmount(), 10_000e18);
  }

  function test_rwaHubInstantMint_instantRedemption_fail_limit() public {
    test_rwaHubInstantMint_instantRedemption();

    _mintRWAToUser(alice, 10_000e18);

    vm.startPrank(alice);
    rwa.approve(address(rwaHubInstantMint), 10_000e18);
    vm.expectRevert("RateLimit: Redemption exceeds rate limit");
    rwaHubInstantMint.instantRedemption(10_000e18);
    vm.stopPrank();
  }

  function test_rwaHubInstantMint_instantRedemption_secondRedeem() public {
    test_rwaHubInstantMint_instantRedemption();

    _mintRWAToUser(alice, 10_000e18);

    // Seed instantMintAssetManager for redemption
    // balance doesn't transfer over so adding extra 10 here
    _seedWithCollateral(instantMintAssetManager, 10_010e6);
    vm.prank(instantMintAssetManager);
    USDC.approve(address(rwaHubInstantMint), 10_000e6);

    vm.warp(block.timestamp + 1 days);

    vm.startPrank(alice);
    rwa.approve(address(rwaHubInstantMint), 10_000e18);
    rwaHubInstantMint.instantRedemption(10_000e18);
    vm.stopPrank();

    assertEq(rwa.balanceOf(alice), 0);
    assertEq(rwa.totalSupply(), 0);
    assertEq(USDC.balanceOf(alice), 19_980e6);
    assertEq(USDC.balanceOf(instantMintAssetManager), 20e6);
    assertEq(rwaHubInstantMint.currentInstantRedemptionAmount(), 10_000e18);
  }

  /*//////////////////////////////////////////////////////////////
                             Modifiers
  //////////////////////////////////////////////////////////////*/

  modifier initializeInstantMints() {
    vm.startPrank(managerAdmin);
    rwaHubInstantMint.setInstantMintPriceId(1);
    instantMintPriceId = 1;
    rwaHubInstantMint.setInstantMintLimit(10_000e18);
    rwaHubInstantMint.setInstantMintLimitDuration(1 days);
    vm.stopPrank();
    _;
  }

  modifier initializeInstantRedemptions() {
    vm.startPrank(managerAdmin);
    rwaHubInstantMint.setInstantRedemptionPriceId(1);
    instantRedemptionPriceId = 1;
    rwaHubInstantMint.setInstantRedemptionLimit(10_000e18);
    rwaHubInstantMint.setInstantRedemptionLimitDuration(1 days);
    vm.stopPrank();
    _seedWithCollateral(instantMintAssetManager, 10_000e6);
    vm.prank(instantMintAssetManager);
    USDC.approve(address(rwaHubInstantMint), 10_000e6);
    _;
  }
}
