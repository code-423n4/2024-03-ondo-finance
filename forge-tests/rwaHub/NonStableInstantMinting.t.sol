pragma solidity 0.8.16;

import "forge-tests/BaseTestRunner.sol";
import "forge-tests/helpers/events/RWAHubNonStableInstantMintEvents.sol";
import "contracts/RWAHubNonStableInstantMints.sol";

abstract contract Test_RWAHub_InstantMinting_NonStable is
  BaseTestRunner,
  RWAHubNonStableInstantMintEvents
{
  RWAHubNonStableInstantMints rwaNonStable;

  function _setRWAHubInstantMint(address _rwaNonStable) internal {
    rwaNonStable = RWAHubNonStableInstantMints(_rwaNonStable);
  }

  function test_rwaHubNonStableMint_initialization() public {
    assertEq(rwaNonStable.instantMintAssetManager(), instantMintAssetManager);
    assertEq(rwaNonStable.instantMintFee(), 10);
    assertEq(rwaNonStable.resetInstantMintDuration(), 0);
    assertEq(rwaNonStable.lastResetInstantMintTime(), block.timestamp);
    assertEq(rwaNonStable.currentInstantMintAmount(), 0);
  }

  function test_rwaHubNonStableMint_setInstantMintAssetManager_fail_ac()
    public
  {
    vm.expectRevert(
      _formatACRevert(address(this), rwaNonStable.MANAGER_ADMIN())
    );
    rwaNonStable.setInstantMintAssetManager(address(this));
  }

  function test_rwaHubNonStableMint_setIntantMintAssetManager() public {
    vm.prank(managerAdmin);
    vm.expectEmit(true, true, true, true);
    emit InstantMintAssetManagerSet(instantMintAssetManager, address(this));
    rwaNonStable.setInstantMintAssetManager(address(this));
  }

  function test_rwaHubNonStableMint_setInstantMintFee_fail_ac() public {
    vm.expectRevert(
      _formatACRevert(address(this), rwaNonStable.MANAGER_ADMIN())
    );
    rwaNonStable.setInstantMintFee(100);
  }

  function test_rwaHubNonStableMint_setInstantMintFee_fail_tooLarge() public {
    vm.prank(managerAdmin);
    vm.expectRevert(IRWAHub.FeeTooLarge.selector);
    rwaNonStable.setInstantMintFee(10001);
  }

  function test_rwaHubNonStableMint_setInstantMintFee() public {
    vm.prank(managerAdmin);
    vm.expectEmit(true, true, true, true);
    emit InstantMintFeeSet(10, 100);
    rwaNonStable.setInstantMintFee(100);
    assertEq(rwaNonStable.instantMintFee(), 100);
  }

  function test_rwaHubNonStableMint_pauseInstantMint_fail_ac() public {
    vm.expectRevert(
      _formatACRevert(address(this), rwaNonStable.PAUSER_ADMIN())
    );
    rwaNonStable.pauseInstantMint();
  }

  function test_rwaHubNonStableMint_pauseInstantMint() public {
    vm.prank(pauser);
    vm.expectEmit(true, true, true, true);
    emit InstantMintPaused(pauser);
    rwaNonStable.pauseInstantMint();
    assertTrue(rwaNonStable.instantMintPaused());
  }

  function test_rwaHubNonStableMint_unpauseInstantMint_fail_ac() public {
    vm.expectRevert(
      _formatACRevert(address(this), rwaNonStable.MANAGER_ADMIN())
    );
    rwaNonStable.unpauseInstantMint();
  }

  function test_rwaHubNonStableMint_unpauseInstantMint() public {
    test_rwaHubNonStableMint_pauseInstantMint();
    vm.prank(managerAdmin);
    vm.expectEmit(true, true, true, true);
    emit InstantMintUnpaused(managerAdmin);
    rwaNonStable.unpauseInstantMint();
    assertFalse(rwaNonStable.instantMintPaused());
  }

  function test_rwaHubNonStableMint_pauseClaimExcess_fail_ac() public {
    vm.expectRevert(
      _formatACRevert(address(this), rwaNonStable.PAUSER_ADMIN())
    );
    rwaNonStable.pauseClaimExcess();
  }

  function test_rwaHubNonStableMint_pauseClaimableExcess() public {
    vm.prank(pauser);
    vm.expectEmit(true, true, true, true);
    emit ClaimExcessPaused(pauser);
    rwaNonStable.pauseClaimExcess();
    assertTrue(rwaNonStable.claimExcessPaused());
  }

  function test_rwaHubNonStableMint_unpauseClaimExcess_fail_ac() public {
    vm.expectRevert(
      _formatACRevert(address(this), rwaNonStable.MANAGER_ADMIN())
    );
    rwaNonStable.unpauseClaimExcess();
  }

  function test_rwaHubNonStableMint_unpauseClaimExcess() public {
    test_rwaHubNonStableMint_pauseClaimableExcess();
    vm.prank(managerAdmin);
    vm.expectEmit(true, true, true, true);
    emit ClaimExcessUnpaused(managerAdmin);
    rwaNonStable.unpauseClaimExcess();
    assertFalse(rwaNonStable.claimExcessPaused());
  }

  function test_rwaHubNonStableMint_setInstantMintLimit_fail_ac() public {
    vm.expectRevert(
      _formatACRevert(address(this), rwaNonStable.MANAGER_ADMIN())
    );
    rwaNonStable.setInstantMintLimit(100e18);
  }

  function test_rwaHubNonStableMint_setInstantMintLimit() public {
    vm.prank(managerAdmin);
    vm.expectEmit(true, true, true, true);
    emit InstantMintLimitSet(100e18);
    rwaNonStable.setInstantMintLimit(100e18);
    assertEq(rwaNonStable.instantMintLimit(), 100e18);
  }

  function test_rwaHubNonStableMint_setInstantMintLimitDuration_fail_ac()
    public
  {
    vm.expectRevert(
      _formatACRevert(address(this), rwaNonStable.MANAGER_ADMIN())
    );
    rwaNonStable.setInstantMintLimitDuration(100);
  }

  function test_rwaHubNonStableMint_setInstantMintLimitDuration() public {
    vm.prank(managerAdmin);
    vm.expectEmit(true, true, true, true);
    emit InstantMintLimitDurationSet(100);
    rwaNonStable.setInstantMintLimitDuration(100);
    assertEq(rwaNonStable.resetInstantMintDuration(), 100);
  }

  function test_rwaHubNonStableMint_setInstantMintAmount_fail_ac() public {
    vm.prank(alice);
    vm.expectRevert(
      _formatACRevert(address(this), rwaNonStable.MANAGER_ADMIN())
    );
    rwaNonStable.setInstantMintAmount(8500);
  }

  function test_rwaHubNonStableMint_setInstantMintAmount_fail_tooLarge()
    public
  {
    vm.prank(managerAdmin);
    vm.expectRevert(IRWAHub.FeeTooLarge.selector);
    rwaNonStable.setInstantMintAmount(10001);
  }

  function test_rwaHubNonStableMint_setInstantMintAmount() public {
    vm.prank(managerAdmin);
    vm.expectEmit(true, true, true, true);
    emit InstantMintAmountSet(9000, 8500);
    rwaNonStable.setInstantMintAmount(8500);
    assertEq(rwaNonStable.instantMintAmountBps(), 8500);
  }

  /*//////////////////////////////////////////////////////////////
                       Instant Mint Functions
  //////////////////////////////////////////////////////////////*/
  function test_rwaHubNonStableMint_instantMint_fail_mintPaused() public {
    vm.prank(pauser);
    rwaNonStable.pauseInstantMint();
    vm.prank(alice);
    vm.expectRevert(IRWAHub.FeaturePaused.selector);
    rwaNonStable.instantMint(100e6);
  }

  function test_rwaHubNonStableMint_instantMint_fail_depositTooSmall()
    public
    initializeInstantMints
  {
    vm.expectRevert(IRWAHub.DepositTooSmall.selector);
    rwaNonStable.instantMint(100);
  }

  function test_rwaHubNonStableMint_instantMint_fail_zeroMintLimit()
    public
    initializeInstantMints
  {
    vm.startPrank(alice);
    _seedWithCollateral(alice, 20_000e6);
    USDC.approve(address(rwaNonStable), 20_000e6);
    vm.expectRevert("RateLimit: Mint exceeds rate limit");
    rwaNonStable.instantMint(20_000e6);
    vm.stopPrank();
  }

  function test_rwaHubNonStableMint_instantMint()
    public
    initializeInstantMints
  {
    _seedWithCollateral(alice, 10_000e6);
    vm.startPrank(alice);
    USDC.approve(address(rwaNonStable), 10_000e6);
    uint256 rwaOwed = (9990e6 *
      1e12 *
      rwaNonStable.instantMintAmountBps() *
      1e18) / (10_000 * pricer.getLatestPrice());
    vm.expectEmit(true, true, true, true);
    emit InstantMint(
      alice,
      10_000e6,
      9990e6,
      10e6,
      rwaOwed,
      100e18,
      FIRST_DEPOSIT_ID
    );
    rwaNonStable.instantMint(10_000e6);
    vm.stopPrank();

    assertEq(USDC.balanceOf(instantMintAssetManager), 10_000e6);
    assertEq(rwa.balanceOf(alice), rwaOwed);
    assertEq(rwaNonStable.currentInstantMintAmount(), rwaOwed);
  }

  function test_rwaHubNonStableMint_instantMint_secondMint_noLimit() public {
    test_rwaHubNonStableMint_instantMint();

    vm.prank(managerAdmin);
    rwaNonStable.setInstantMintLimitDuration(0);

    _seedWithCollateral(alice, 10_000e6);
    vm.startPrank(alice);
    USDC.approve(address(rwaNonStable), 10_000e6);
    rwaNonStable.instantMint(10_000e6);
    vm.stopPrank();
    uint256 rwaOwed = (9990e6 *
      1e12 *
      rwaNonStable.instantMintAmountBps() *
      1e18) / (10_000 * pricer.getLatestPrice());

    assertEq(USDC.balanceOf(instantMintAssetManager), 20_000e6);
    assertEq(rwa.balanceOf(alice), rwaOwed * 2);
    assertEq(rwaNonStable.currentInstantMintAmount(), rwaOwed);
  }

  function test_rwaHubNonStableMint_instantMint_secondMint_fail_limit() public {
    test_rwaHubNonStableMint_instantMint();

    _seedWithCollateral(alice, 10_000e6);
    vm.startPrank(alice);
    USDC.approve(address(rwaNonStable), 10_000e6);
    vm.expectRevert("RateLimit: Mint exceeds rate limit");
    rwaNonStable.instantMint(10_000e6);
    vm.stopPrank();
  }

  function test_rwaHubNonStableMint_instantMint_secondMint() public {
    test_rwaHubNonStableMint_instantMint();

    vm.warp(block.timestamp + 1 days);
    _seedWithCollateral(alice, 10_000e6);
    vm.startPrank(alice);
    USDC.approve(address(rwaNonStable), 10_000e6);
    rwaNonStable.instantMint(10_000e6);
    vm.stopPrank();
    uint256 rwaOwed = (9990e6 *
      1e12 *
      rwaNonStable.instantMintAmountBps() *
      1e18) / (10_000 * pricer.getLatestPrice());

    assertEq(USDC.balanceOf(instantMintAssetManager), 20_000e6);
    assertEq(rwa.balanceOf(alice), rwaOwed * 2);
    assertEq(rwaNonStable.currentInstantMintAmount(), rwaOwed);
  }

  /*//////////////////////////////////////////////////////////////
                       Claim Excess Functions
  //////////////////////////////////////////////////////////////*/

  function test_rwaHubNonStableMint_claimExcess() public {
    test_rwaHubNonStableMint_instantMint();

    depositIds.push(FIRST_DEPOSIT_ID);
    priceIds.push(1);

    vm.prank(managerAdmin);
    rwaNonStable.setPriceIdForDeposits(depositIds, priceIds);

    vm.prank(alice);
    rwaNonStable.claimExcess(depositIds);

    assertEq(rwa.balanceOf(alice), 99.9e18);
  }

  function test_cannot_claim_others_excess() public {
    test_rwaHubNonStableMint_instantMint();

    depositIds.push(FIRST_DEPOSIT_ID);
    priceIds.push(1);

    vm.prank(managerAdmin);
    rwaNonStable.setPriceIdForDeposits(depositIds, priceIds);

    vm.prank(bob);
    rwaNonStable.claimExcess(depositIds);

    assertEq(rwa.balanceOf(alice), 99.9e18);
  }

  function test_rwaHubNonStableMint_claimExcess_priceChange() public {
    test_rwaHubNonStableMint_instantMint();

    uint256 tsBefore = rwa.totalSupply();

    depositIds.push(FIRST_DEPOSIT_ID);
    priceIds.push(2);

    pricer.addPrice(105e18, block.timestamp);

    uint256 given = rwaNonStable.depositIdToInstantMintAmount(FIRST_DEPOSIT_ID);
    (, uint256 credited, ) = rwaNonStable.depositIdToDepositor(
      FIRST_DEPOSIT_ID
    );
    uint256 owedAtSetPrice = ((1e18 * credited * 1e12) /
      pricer.getLatestPrice());
    uint256 excessToClaim = owedAtSetPrice - given;

    vm.prank(managerAdmin);
    rwaNonStable.setPriceIdForDeposits(depositIds, priceIds);

    vm.prank(alice);
    rwaNonStable.claimExcess(depositIds);
    uint256 tsAfter = rwa.totalSupply();

    assertEq(rwa.balanceOf(alice), owedAtSetPrice);
    assertEq(tsAfter - tsBefore, excessToClaim);
  }

  function test_fuzz_rwaHubNonStableMint_claimExcess_varyPrice(
    uint32 change
  ) public {
    if (change == 0) change += 1;
    uint256 rate = 100e18 + change;
    test_rwaHubNonStableMint_instantMint();

    uint256 tsBefore = rwa.totalSupply();

    depositIds.push(FIRST_DEPOSIT_ID);
    priceIds.push(2);

    pricer.addPrice(rate, block.timestamp);

    uint256 given = rwaNonStable.depositIdToInstantMintAmount(FIRST_DEPOSIT_ID);
    (, uint256 credited, ) = rwaNonStable.depositIdToDepositor(
      FIRST_DEPOSIT_ID
    );
    uint256 owedAtSetPrice = ((1e18 * credited * 1e12) /
      pricer.getLatestPrice());
    uint256 excessToClaim = owedAtSetPrice - given;

    vm.prank(managerAdmin);
    rwaNonStable.setPriceIdForDeposits(depositIds, priceIds);

    vm.prank(alice);
    rwaNonStable.claimExcess(depositIds);
    uint256 tsAfter = rwa.totalSupply();

    assertEq(rwa.balanceOf(alice), owedAtSetPrice);
    assertEq(tsAfter - tsBefore, excessToClaim);
  }

  function test_rwaHubNonStableMint_claimExcess_fail_paused() public {
    test_rwaHubNonStableMint_instantMint();

    priceIds.push(1);
    depositIds.push(FIRST_DEPOSIT_ID);

    vm.prank(managerAdmin);
    rwaNonStable.setPriceIdForDeposits(depositIds, priceIds);
    vm.prank(pauser);
    rwaNonStable.pauseClaimExcess();

    vm.prank(alice);
    vm.expectRevert(IRWAHub.FeaturePaused.selector);
    rwaNonStable.claimExcess(depositIds);
  }

  function test_rwaHubNonStableMint_claimMint_fail() public {
    test_rwaHubNonStableMint_instantMint();

    priceIds.push(1);
    depositIds.push(FIRST_DEPOSIT_ID);

    vm.prank(managerAdmin);
    rwaNonStable.setPriceIdForDeposits(depositIds, priceIds);

    vm.prank(alice);
    vm.expectRevert(IRWAHubNonStableInstantMint.CannotClaimMint.selector);
    rwaNonStable.claimMint(depositIds);
  }

  /*//////////////////////////////////////////////////////////////
                             Modifiers
  //////////////////////////////////////////////////////////////*/

  modifier initializeInstantMints() {
    vm.startPrank(managerAdmin);
    rwaNonStable.unpauseClaimExcess();
    rwaNonStable.unpauseInstantMint();
    rwaNonStable.setInstantMintLimit(100e18);
    rwaNonStable.setInstantMintLimitDuration(1 days);
    vm.stopPrank();
    _;
  }

  modifier pauseClaimExcess() {
    vm.prank(pauser);
    rwaNonStable.pauseClaimExcess();
    _;
  }
}
