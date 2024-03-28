pragma solidity 0.8.16;
import "forge-tests/OUSG_BasicDeployment.t.sol";
import "forge-tests/ousg/OUSGInstantManager/buidl_helper.sol";

contract Test_OUSGInstant_redeem_ETH is OUSG_BasicDeployment, BUIDLHelper {
  function setUp() public override {
    super.setUp();
    _whitelistBUIDLWallet(address(ousgInstantManager));
    // Deviates from real world, this is a "pretend" Redeemer contract, as we don't have the real one yet
    _whitelistBUIDLWallet(address(mockBUIDLRedeemer));
    assertEq(ousg.balanceOf(alice), 0);
    assertEq(rOUSGToken.balanceOf(alice), 0);
    assertEq(USDC.balanceOf(alice), 0);
    oracleCheckHarnessOUSG.setPrice(150e18);
    vm.startPrank(OUSG_GUARDIAN);
    // 10m USDC
    ousgInstantManager.setInstantMintLimit(10_000_000e6);
    // 10m USDC
    ousgInstantManager.setInstantRedemptionLimit(10_000_000e6);
    vm.stopPrank();
  }

  /*//////////////////////////////////////////////////////////////
                    Tests for redeeming OUSG
  //////////////////////////////////////////////////////////////*/
  function test_instant_redeem()
    public
    setupSecuritize(1_000_000e6, 1_000_000e6)
    dealAliceOUSG(5000e18)
  {
    uint256 managerBuidlBalance = BUIDL.balanceOf(address(ousgInstantManager));
    uint256 redeemerBuidlBalance = BUIDL.balanceOf(address(mockBUIDLRedeemer));
    uint256 redeemerUSDCBalance = USDC.balanceOf(address(mockBUIDLRedeemer));

    uint256 ousgTotalSupply = ousg.totalSupply();
    uint256 ousgRedeemAmount = 5000e18;
    uint256 usdcAmount = 750_000e6;
    vm.startPrank(alice);
    ousg.approve(address(ousgInstantManager), (ousgRedeemAmount));
    ousgInstantManager.redeem(ousgRedeemAmount);
    vm.stopPrank();
    // The correct amount of OUSG has been burned
    assertEq(ousg.totalSupply(), ousgTotalSupply - ousgRedeemAmount);
    // Alice has redeemed all of her OUSG
    assertEq(ousg.balanceOf(alice), 0);
    // the correct of amount of BUILD has been removed from `ousgInstant Manager`
    assertEq(
      BUIDL.balanceOf(address(ousgInstantManager)),
      managerBuidlBalance - usdcAmount
    );
    // the correct amount of BUILD has been sent to the redeemer
    assertEq(
      BUIDL.balanceOf(address(mockBUIDLRedeemer)),
      redeemerBuidlBalance + usdcAmount
    );
    // the correct amount of USDC has been taken from the redeemer
    assertEq(
      USDC.balanceOf(address(mockBUIDLRedeemer)),
      redeemerUSDCBalance - usdcAmount
    );
    // Alice has received the correct amount of USDC
    assertEq(USDC.balanceOf(alice), usdcAmount);
  }

  function test_instant_redeem_fees()
    public
    setupSecuritize(1_000_000e6, 1_000_000e6)
    dealAliceOUSG(5000e18)
  {
    vm.prank(OUSG_GUARDIAN);
    // 1% fee, specified in BPS
    ousgInstantManager.setRedeemFee(100);

    vm.startPrank(alice);
    ousg.approve(address(ousgInstantManager), 5000e18);
    ousgInstantManager.redeem(5000e18);
    vm.stopPrank();

    assertEq(USDC.balanceOf(ousgInstantManager.feeReceiver()), 7_500e6);
    assertEq(USDC.balanceOf(alice), 742_500e6);
  }

  function test_instant_redeem__fail_paused() public {
    vm.prank(OUSG_GUARDIAN);
    ousgInstantManager.pauseRedeem();

    deal(address(ousg), alice, 100_000e6);
    vm.startPrank(alice);
    ousg.approve(address(ousgInstantManager), 100_000e6);
    vm.expectRevert(bytes("OUSGInstantManager: Redeem paused"));
    ousgInstantManager.redeem(100_000e6);
    vm.stopPrank();
  }

  function test_instant_redeem__fail_not_kycd() public {
    vm.prank(OUSG_GUARDIAN);
    _restrictOUSGUser(alice);

    deal(address(ousg), alice, 100_000e6);
    vm.startPrank(alice);
    ousg.approve(address(ousgInstantManager), 100_000e6);
    vm.expectRevert(
      bytes(
        "CashKYCSenderReceiver: `from` address must be KYC'd to send tokens"
      )
    );
    ousgInstantManager.redeem(100_000e6);
    vm.stopPrank();
  }

  function test_instant_redeem__fail_too_small()
    public
    setupSecuritize(1_000_000e6, 1_000_000e6)
  {
    deal(address(ousg), alice, 100_000e18);
    assertEq(ousgInstantManager.minimumRedemptionAmount(), 50_000e6);

    uint256 ousgAmount = 333333333333333333333; // 50k usdc / 150 ousg per usdc

    vm.startPrank(alice);
    ousg.approve(address(ousgInstantManager), ousgAmount);
    vm.expectRevert(
      bytes("OUSGInstantManager::_redeem: Redemption amount too small")
    );
    ousgInstantManager.redeem(ousgAmount);
    vm.stopPrank();
  }

  function test_instant_redeem__succeed_minimum()
    public
    setupSecuritize(1_000_000e6, 1_000_000e6)
  {
    deal(address(ousg), alice, 100_000e18);
    assertEq(ousgInstantManager.minimumRedemptionAmount(), 50_000e6);

    uint256 ousgAmount = 333333333333333333334; // (50k usdc / 150 ousg per usdc) + 1 wei
    uint256 ousgPrice = ousgInstantManager.getOUSGPrice();
    uint256 usdcOwed = (ousgAmount * ousgPrice) / 1e18 / 1e12;

    vm.startPrank(alice);
    ousg.approve(address(ousgInstantManager), ousgAmount);
    ousgInstantManager.redeem(ousgAmount);
    vm.stopPrank();

    assertEq(USDC.balanceOf(alice), usdcOwed);
  }

  /*//////////////////////////////////////////////////////////////
                    Tests for redeeming Rebasing OUSG
  //////////////////////////////////////////////////////////////*/
  function test_instant_redeemROUSG()
    public
    setupSecuritize(1_000_000e6, 1_000_000e6)
    dealAliceROUSG(5000e18)
  {
    uint256 managerBuidlBalance = BUIDL.balanceOf(address(ousgInstantManager));
    uint256 aliceROUSGBalance = rOUSGToken.balanceOf(alice);
    console.log("Alice rOUSG balance", aliceROUSGBalance);
    uint256 redeemerBuidlBalance = BUIDL.balanceOf(address(mockBUIDLRedeemer));
    uint256 redeemerUSDCBalance = USDC.balanceOf(address(mockBUIDLRedeemer));
    // this is taken from live
    uint256 ousgTotalSupply = ousg.totalSupply();
    uint256 usdcAmount = 750_000e6;
    assertEq(rOUSGToken.totalSupply(), 750_000e18);

    vm.startPrank(alice);
    rOUSGToken.approve(address(ousgInstantManager), (aliceROUSGBalance));
    ousgInstantManager.redeemRebasingOUSG(aliceROUSGBalance);
    vm.stopPrank();
    console.log("OUSg total supply after", ousg.totalSupply());
    // The correct amount of OUSG has been burned
    assertEq(ousg.totalSupply(), ousgTotalSupply - 5000e18);
    // There are no more rOUSG Tokens in circulation
    assertEq(rOUSGToken.totalSupply(), 0);
    // Alice does not have any OUSG
    assertEq(ousg.balanceOf(alice), 0);
    // The correct of amount of BUILD has been removed from `ousgInstant Manager`
    assertEq(
      BUIDL.balanceOf(address(ousgInstantManager)),
      managerBuidlBalance - usdcAmount
    );
    // The correct amount of BUILD has been sent to the redeemer
    assertEq(
      BUIDL.balanceOf(address(mockBUIDLRedeemer)),
      redeemerBuidlBalance + usdcAmount
    );
    // The correct amount of USDC has been taken from the redeemer
    assertEq(
      USDC.balanceOf(address(mockBUIDLRedeemer)),
      redeemerUSDCBalance - usdcAmount
    );
    // // Alice has received the correct amount of USDC
    assertEq(USDC.balanceOf(alice), usdcAmount);
    // Alice has no rOUSG
    assertEq(rOUSGToken.balanceOf(alice), 0);
  }

  function test_instant_redeemROUSG_fees()
    public
    setupSecuritize(1_000_000e6, 1_000_000e6)
    dealAliceROUSG(5000e18)
  {
    uint256 aliceROUSGBalance = rOUSGToken.balanceOf(alice);

    vm.prank(OUSG_GUARDIAN);
    // 1% fee, specified in BPS
    ousgInstantManager.setRedeemFee(100);

    vm.startPrank(alice);
    rOUSGToken.approve(address(ousgInstantManager), aliceROUSGBalance);
    ousgInstantManager.redeemRebasingOUSG(aliceROUSGBalance);
    vm.stopPrank();

    assertEq(USDC.balanceOf(ousgInstantManager.feeReceiver()), 7_500e6);
    assertEq(USDC.balanceOf(alice), 742_500e6);
  }

  function test_instant_redeem__fail_not_kycd_rousg()
    public
    setupSecuritize(1_000_000e6, 1_000_000e6)
    dealAliceROUSG(5000e18)
  {
    vm.prank(OUSG_GUARDIAN);
    _restrictOUSGUser(alice);

    vm.startPrank(alice);
    rOUSGToken.approve(address(ousgInstantManager), 100_000e6);
    vm.expectRevert(bytes("rOUSG: 'from' address not KYC'd"));
    ousgInstantManager.redeemRebasingOUSG(100_000e6);
    vm.stopPrank();
  }

  function test_instant_redeem__fail_too_small_rousg()
    public
    setupSecuritize(1_000_000e6, 1_000_000e6)
    dealAliceROUSG(5000e18)
  {
    assertEq(ousgInstantManager.minimumRedemptionAmount(), 50_000e6);

    uint256 ousgAmount = 333333333333333333333; // 50k usdc / 150 ousg per usdc
    uint256 ousgPrice = ousgInstantManager.getOUSGPrice();
    uint256 rousgAmount = (ousgAmount * ousgPrice) / 1e18;

    vm.startPrank(alice);
    rOUSGToken.approve(address(ousgInstantManager), rousgAmount);
    vm.expectRevert(
      bytes("OUSGInstantManager::_redeem: Redemption amount too small")
    );
    ousgInstantManager.redeemRebasingOUSG(ousgAmount);
    vm.stopPrank();
  }

  function test_instant_redeem__succeed_minimum_rousg()
    public
    setupSecuritize(1_000_000e6, 1_000_000e6)
    dealAliceROUSG(5000e18)
  {
    assertEq(ousgInstantManager.minimumRedemptionAmount(), 50_000e6);

    uint256 ousgAmount = 333333333333333333334; // (50k usdc / 150 ousg per usdc) + 1 wei
    uint256 ousgPrice = ousgInstantManager.getOUSGPrice();
    uint256 rousgAmount = (ousgAmount * ousgPrice) / 1e18;
    uint256 usdcOwed = (ousgAmount * ousgPrice) / 1e18 / 1e12;

    vm.startPrank(alice);
    rOUSGToken.approve(address(ousgInstantManager), rousgAmount);
    ousgInstantManager.redeemRebasingOUSG(rousgAmount);
    vm.stopPrank();

    assertEq(USDC.balanceOf(alice), usdcOwed);
  }

  function test_instant_redeem__fail_too_large()
    public
    setupSecuritize(1_000_000e6, 1_000_000e6)
  {
    vm.prank(OUSG_GUARDIAN);
    ousgInstantManager.setInstantRedemptionLimit(100_000e6);

    // (100k usdc / 150 ousg per usdc) + 1 wei
    // slightly inaccurate due to rounding
    uint256 ousgAmount = 666_666666700000000000;

    deal(address(ousg), alice, 100_001e18);

    vm.startPrank(alice);
    ousg.approve(address(ousgInstantManager), ousgAmount);
    vm.expectRevert(bytes("RateLimit: Redemption exceeds rate limit"));
    ousgInstantManager.redeem(ousgAmount);
    vm.stopPrank();
  }

  modifier setupSecuritize(uint256 buidlAmount, uint256 usdcAmount) {
    vm.prank(BUIDL_WHALE);
    BUIDL.transfer(address(ousgInstantManager), buidlAmount);
    deal(address(USDC), address(mockBUIDLRedeemer), usdcAmount);
    _;
  }

  modifier dealAliceROUSG(uint256 ousgAmount) {
    vm.prank(address(ousgInstantManager));
    ousg.mint(alice, ousgAmount);
    vm.startPrank(alice);
    ousg.approve(address(rOUSGToken), ousgAmount);
    rOUSGToken.wrap(ousgAmount);
    vm.stopPrank();
    _;
  }

  modifier dealAliceOUSG(uint256 ousgAmount) {
    vm.prank(address(ousgInstantManager));
    ousg.mint(alice, ousgAmount);
    _;
  }
}
