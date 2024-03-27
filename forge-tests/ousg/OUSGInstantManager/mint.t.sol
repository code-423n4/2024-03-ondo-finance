pragma solidity 0.8.16;
import "forge-tests/OUSG_BasicDeployment.t.sol";
import "forge-tests/ousg/OUSGInstantManager/buidl_helper.sol";

contract Test_OUSGInstant_mint_ETH is OUSG_BasicDeployment, BUIDLHelper {
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
                    Tests for minting OUSG
  //////////////////////////////////////////////////////////////*/
  function test_instant_mint__fail_paused() public {
    vm.prank(OUSG_GUARDIAN);
    ousgInstantManager.pauseMint();

    deal(address(USDC), alice, 100_000e6);
    vm.startPrank(alice);
    USDC.approve(address(ousgInstantManager), 100_000e6);
    vm.expectRevert(bytes("OUSGInstantManager: Mint paused"));
    ousgInstantManager.mint(100_000e6);
    vm.stopPrank();
  }

  function test_instant_mint__fail_not_kycd() public {
    vm.prank(OUSG_GUARDIAN);
    _restrictOUSGUser(alice);

    deal(address(USDC), alice, 100_000e6);
    vm.startPrank(alice);
    USDC.approve(address(ousgInstantManager), 100_000e6);
    vm.expectRevert(
      bytes(
        "CashKYCSenderReceiver: `to` address must be KYC'd to receive tokens"
      )
    );
    ousgInstantManager.mint(100_000e6);
    vm.stopPrank();
  }

  function test_instant_mint__fail_too_small() public {
    deal(address(USDC), alice, 100_000e6);
    assertEq(ousgInstantManager.minimumDepositAmount(), 100_000e6);

    vm.startPrank(alice);
    USDC.approve(address(ousgInstantManager), 100_000e6);
    vm.expectRevert(
      bytes("OUSGInstantManager::_mint: Deposit amount too small")
    );
    ousgInstantManager.mint(99_999e6);
    vm.stopPrank();
  }

  function test_instant_mint__fail_too_large() public {
    vm.prank(OUSG_GUARDIAN);
    ousgInstantManager.setInstantMintLimit(100_000e6);

    deal(address(USDC), alice, 100_001e6);

    vm.startPrank(alice);
    USDC.approve(address(ousgInstantManager), 100_001e6);
    vm.expectRevert(bytes("RateLimit: Mint exceeds rate limit"));
    ousgInstantManager.mint(100_001e6);
    vm.stopPrank();
  }

  function test_instant_mint__fail_allowance() public {
    deal(address(USDC), alice, 100_001e6);

    vm.startPrank(alice);
    USDC.approve(address(ousgInstantManager), 99_000e6);
    vm.expectRevert(
      bytes(
        "OUSGInstantManager::_mint: Allowance must be given to OUSGInstantManager"
      )
    );
    ousgInstantManager.mint(100_000e6);
    vm.stopPrank();
  }

  function test_instant_mint() public {
    deal(address(USDC), alice, 100_000e6);
    vm.startPrank(alice);
    USDC.approve(address(ousgInstantManager), 100_000e6);
    ousgInstantManager.mint(100_000e6);
    vm.stopPrank();

    // should have 100k / 150 OUSG
    assertEq(ousg.balanceOf(alice), 666666666666666666666);
    assertEq(USDC.balanceOf(ousgInstantManager.usdcReceiver()), 100_000e6);
    assertEq(USDC.balanceOf(ousgInstantManager.feeReceiver()), 0);
    assertEq(rOUSGToken.sharesOf(alice), 0);
    assertEq(rOUSGToken.balanceOf(alice), 0);
  }

  function test_instant_mint__fees() public {
    deal(address(USDC), alice, 100_000e6);

    vm.prank(OUSG_GUARDIAN);
    // 1% fee, specified in BPS
    ousgInstantManager.setMintFee(100);

    vm.startPrank(alice);
    USDC.approve(address(ousgInstantManager), 100_000e6);
    ousgInstantManager.mint(100_000e6);
    vm.stopPrank();

    // should have 99k / 150 OUSG
    assertEq(ousg.balanceOf(alice), 660000000000000000000);
    assertEq(USDC.balanceOf(ousgInstantManager.usdcReceiver()), 99_000e6);
    assertEq(USDC.balanceOf(ousgInstantManager.feeReceiver()), 1_000e6);
    assertEq(rOUSGToken.sharesOf(alice), 0);
    assertEq(rOUSGToken.balanceOf(alice), 0);
  }

  // The following will fail, as setMinimumDepositAmount is hardcoded
  // to require at least 10_000.
  /*
  function test_instant_mint__zero_fee() public {
    vm.startPrank(OUSG_GUARDIAN);
    ousgInstantManager.setMintFee(1);
    ousgInstantManager.setMinimumDepositAmount(0);
    vm.stopPrank();

    deal(address(USDC), alice, 0.009999e6);
    vm.startPrank(alice);
    USDC.approve(address(ousgInstantManager), 0.009999e6);
    ousgInstantManager.mint(0.009999e6);
    vm.stopPrank();
    assertEq(USDC.balanceOf(ousgInstantManager.feeReceiver()), 0);
  }

  function test_instant_mint__minimum_fee() public {
    vm.startPrank(OUSG_GUARDIAN);
    ousgInstantManager.setMintFee(1);
    ousgInstantManager.setMinimumDepositAmount(0);
    vm.stopPrank();

    deal(address(USDC), alice, 0.01e6);
    vm.startPrank(alice);
    USDC.approve(address(ousgInstantManager), 0.01e6);
    ousgInstantManager.mint(0.01e6);
    vm.stopPrank();
    assertEq(USDC.balanceOf(ousgInstantManager.feeReceiver()), 0.000001e6);
  }
  */

  /*//////////////////////////////////////////////////////////////
                    Tests for minting Rebasing OUSG
  //////////////////////////////////////////////////////////////*/
  function test_instant_mint__fail_not_kycd_rousg() public {
    vm.prank(OUSG_GUARDIAN);
    _restrictOUSGUser(alice);

    deal(address(USDC), alice, 100_000e6);
    vm.startPrank(alice);
    USDC.approve(address(ousgInstantManager), 100_000e6);
    vm.expectRevert(bytes("rOUSG: 'to' address not KYC'd"));
    ousgInstantManager.mintRebasingOUSG(100_000e6);
    vm.stopPrank();
  }

  function test_instant_mintROUSG() public {
    deal(address(USDC), alice, 100_000e6);
    vm.startPrank(alice);
    USDC.approve(address(ousgInstantManager), 100_000e6);
    ousgInstantManager.mintRebasingOUSG(100_000e6);
    vm.stopPrank();

    uint256 expectedAliceShares = 666666666666666666666 *
      ousgInstantManager.OUSG_TO_ROUSG_SHARES_MULTIPLIER();
    assertEq(USDC.balanceOf(ousgInstantManager.usdcReceiver()), 100_000e6);
    assertEq(USDC.balanceOf(ousgInstantManager.feeReceiver()), 0);
    assertEq(rOUSGToken.sharesOf(alice), expectedAliceShares);
    // Close to 100,000 e18
    assertEq(rOUSGToken.balanceOf(alice), 99999999999999999999900);
  }

  function test_instant_mintROUSG__fees() public {
    deal(address(USDC), alice, 100_000e6);

    vm.prank(OUSG_GUARDIAN);
    // 1% fee, specified in BPS
    ousgInstantManager.setMintFee(100);

    vm.startPrank(alice);
    USDC.approve(address(ousgInstantManager), 100_000e6);
    ousgInstantManager.mintRebasingOUSG(100_000e6);
    vm.stopPrank();

    // should have 99k / 150 OUSG worth of shares
    uint256 expectedAliceShares = 660000000000000000000 *
      ousgInstantManager.OUSG_TO_ROUSG_SHARES_MULTIPLIER();
    assertEq(USDC.balanceOf(ousgInstantManager.usdcReceiver()), 99_000e6);
    assertEq(USDC.balanceOf(ousgInstantManager.feeReceiver()), 1_000e6);
    assertEq(rOUSGToken.sharesOf(alice), expectedAliceShares);
    assertEq(rOUSGToken.balanceOf(alice), 99_000e18);
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
