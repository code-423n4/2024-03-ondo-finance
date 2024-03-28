pragma solidity 0.8.16;
import "forge-tests/OUSG_BasicDeployment.t.sol";
import "forge-tests/ousg/OUSGInstantManager/buidl_helper.sol";
import "lib/forge-std/src/console.sol";

contract Test_OUSGInstant_redeem_usdc_buffer_ETH is
  OUSG_BasicDeployment,
  BUIDLHelper
{
  event BUIDLRedemptionSkipped(
    address indexed sender,
    uint256 usdcAmountRedeemed,
    uint256 usdcAmountRemaining
  );
  event MinimumBUIDLRedemption(
    address indexed sender,
    uint256 buidlAmountRedeemed,
    uint256 usdcAmountKept
  );

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
         Tests for redeeming OUSG below the BUIDL minimum
  //////////////////////////////////////////////////////////////*/
  function test_instant_redeem_exactly_enough_USDC_to_cover()
    public
    setupSecuritize(1_000_000e6, 1_000_000e6)
    dealAliceOUSG(1660e18)
  {
    // 1k less than the BUIDL min redemption amount of 250k
    uint256 ousgRedeemAmount = 1660e18;
    // equivalent amount in USDC
    uint256 usdcAmount = 249_000e6;
    // Give the OUSGInstantManager some USDC to cover the redemption
    deal(address(USDC), address(ousgInstantManager), usdcAmount);
    // We gave the contract just enough to cover the redemption - nothing left over
    uint256 usdcAmountRemaining = 0;

    uint256 managerBuidlBalance = BUIDL.balanceOf(address(ousgInstantManager));
    uint256 redeemerBuidlBalance = BUIDL.balanceOf(address(mockBUIDLRedeemer));
    uint256 redeemerUSDCBalance = USDC.balanceOf(address(mockBUIDLRedeemer));
    uint256 ousgInstantManagerUSDCBalance = USDC.balanceOf(
      address(ousgInstantManager)
    );
    uint256 ousgTotalSupply = ousg.totalSupply();

    vm.startPrank(alice);
    ousg.approve(address(ousgInstantManager), (ousgRedeemAmount));
    vm.expectEmit(true, true, true, true);
    emit BUIDLRedemptionSkipped(
      address(alice),
      usdcAmount,
      usdcAmountRemaining
    );
    ousgInstantManager.redeem(ousgRedeemAmount);
    vm.stopPrank();

    // The correct amount of OUSG has been burned
    assertEq(ousg.totalSupply(), ousgTotalSupply - ousgRedeemAmount);
    // Alice has redeemed all of her OUSG
    assertEq(ousg.balanceOf(alice), 0);
    // No BUIDL has been removed from the OUSGInstantManager contract
    assertEq(BUIDL.balanceOf(address(ousgInstantManager)), managerBuidlBalance);
    // No BUIDL has been sent to the BUIDL redeemer contract
    assertEq(BUIDL.balanceOf(address(mockBUIDLRedeemer)), redeemerBuidlBalance);
    // No USDC has been taken from the BUIDL redeemer contract
    assertEq(USDC.balanceOf(address(mockBUIDLRedeemer)), redeemerUSDCBalance);
    // The USDC has been removed from the OUSGInstantManager contract
    assertEq(
      USDC.balanceOf(address(ousgInstantManager)),
      ousgInstantManagerUSDCBalance - usdcAmount
    );
    // Alice has received the correct amount of USDC
    assertEq(USDC.balanceOf(alice), usdcAmount);
  }

  function test_instant_redeem_more_than_enough_USDC_to_cover()
    public
    setupSecuritize(1_000_000e6, 1_000_000e6)
    dealAliceOUSG(1500e18)
  {
    // 25k less than the BUIDL min redemption amount of 250k
    uint256 ousgRedeemAmount = 1500e18;
    // equivalent amount in USDC
    uint256 usdcAmount = 225_000e6;
    // Give the OUSGInstantManager more than enough USDC to cover the redemption
    deal(address(USDC), address(ousgInstantManager), 230_000e6);
    // We gave the contract more than enough to cover the redemption - some left over
    uint usdcAmountRemaining = 5_000e6;

    uint256 managerBuidlBalance = BUIDL.balanceOf(address(ousgInstantManager));
    uint256 redeemerBuidlBalance = BUIDL.balanceOf(address(mockBUIDLRedeemer));
    uint256 redeemerUSDCBalance = USDC.balanceOf(address(mockBUIDLRedeemer));
    uint256 ousgInstantManagerUSDCBalance = USDC.balanceOf(
      address(ousgInstantManager)
    );
    uint256 ousgTotalSupply = ousg.totalSupply();

    vm.startPrank(alice);
    ousg.approve(address(ousgInstantManager), (ousgRedeemAmount));
    vm.expectEmit(true, true, true, true);
    emit BUIDLRedemptionSkipped(
      address(alice),
      usdcAmount,
      usdcAmountRemaining
    );
    ousgInstantManager.redeem(ousgRedeemAmount);
    vm.stopPrank();

    // The correct amount of OUSG has been burned
    assertEq(ousg.totalSupply(), ousgTotalSupply - ousgRedeemAmount);
    // Alice has redeemed all of her OUSG
    assertEq(ousg.balanceOf(alice), 0);
    // No BUIDL has been removed from the OUSGInstantManager contract
    assertEq(BUIDL.balanceOf(address(ousgInstantManager)), managerBuidlBalance);
    // No BUIDL has been sent to the BUIDL redeemer contract
    assertEq(BUIDL.balanceOf(address(mockBUIDLRedeemer)), redeemerBuidlBalance);
    // No USDC has been taken from the BUIDL redeemer contract
    assertEq(USDC.balanceOf(address(mockBUIDLRedeemer)), redeemerUSDCBalance);
    // The USDC has been removed from the OUSGInstantManager contract
    assertEq(
      USDC.balanceOf(address(ousgInstantManager)),
      ousgInstantManagerUSDCBalance - usdcAmount
    );
    // Alice has received the correct amount of USDC
    assertEq(USDC.balanceOf(alice), usdcAmount);
  }

  function test_instant_redeem_min_BUIDL_redemption()
    public
    setupSecuritize(1_000_000e6, 1_000_000e6)
    dealAliceOUSG(1500e18)
  {
    uint256 minBUIDLRedeemAmount = ousgInstantManager.minBUIDLRedeemAmount();
    // 25k less than the BUIDL min redemption amount of 250k
    uint256 ousgRedeemAmount = 1500e18;
    // equivalent amount in USDC
    uint256 usdcAmount = 225_000e6;
    // Give the OUSGInstantManager less than enough USDC to cover the redemption
    deal(address(USDC), address(ousgInstantManager), 5_000e6);

    uint256 managerBuidlBalance = BUIDL.balanceOf(address(ousgInstantManager));
    uint256 redeemerBuidlBalance = BUIDL.balanceOf(address(mockBUIDLRedeemer));
    uint256 redeemerUSDCBalance = USDC.balanceOf(address(mockBUIDLRedeemer));
    uint256 managerUSDCBalance = USDC.balanceOf(address(ousgInstantManager));
    uint256 ousgTotalSupply = ousg.totalSupply();

    vm.startPrank(alice);
    ousg.approve(address(ousgInstantManager), (ousgRedeemAmount));
    vm.expectEmit(true, true, true, true);
    emit MinimumBUIDLRedemption(
      address(alice),
      minBUIDLRedeemAmount,
      managerUSDCBalance + minBUIDLRedeemAmount - usdcAmount
    );
    ousgInstantManager.redeem(ousgRedeemAmount);
    vm.stopPrank();

    // The correct amount of OUSG has been burned
    assertEq(ousg.totalSupply(), ousgTotalSupply - ousgRedeemAmount);
    // Alice has redeemed all of her OUSG
    assertEq(ousg.balanceOf(alice), 0);
    // `minBUIDLRedeemAmount` BUIDL has been removed from the OUSGInstantManager contract
    assertEq(
      BUIDL.balanceOf(address(ousgInstantManager)),
      managerBuidlBalance - minBUIDLRedeemAmount
    );
    // `minBUIDLRedeemAmount` BUIDL has been sent to the BUIDL redeemer contract
    assertEq(
      BUIDL.balanceOf(address(mockBUIDLRedeemer)),
      redeemerBuidlBalance + minBUIDLRedeemAmount
    );
    // `minBUIDLRedeemAmount` USDC has been taken from the BUIDL redeemer contract
    assertEq(
      USDC.balanceOf(address(mockBUIDLRedeemer)),
      redeemerUSDCBalance - minBUIDLRedeemAmount
    );
    // USDC has not been removed from the OUSGInstantManager contract, rather, its has been topped up
    // by the difference between the minBUIDLRedeemAmount and the USDC amount redeemed.
    assertEq(
      USDC.balanceOf(address(ousgInstantManager)),
      managerUSDCBalance + minBUIDLRedeemAmount - usdcAmount
    );
    // Alice has received the correct amount of USDC
    assertEq(USDC.balanceOf(alice), usdcAmount);
  }

  function test_instant_redeem_min_BUIDL_redemption__fail_not_enough_BUIDL()
    public
    dealAliceOUSG(1500e18)
  {
    uint256 minBUIDLRedeemAmount = ousgInstantManager.minBUIDLRedeemAmount();
    // Distribute 1 less than minBUIDLRedeemAmount to the OUSGInstantManager
    vm.prank(BUIDL_WHALE);
    BUIDL.transfer(address(ousgInstantManager), minBUIDLRedeemAmount - 1);
    deal(address(USDC), address(mockBUIDLRedeemer), minBUIDLRedeemAmount - 1);

    // 25k less than the BUIDL min redemption amount of 250k
    uint256 ousgRedeemAmount = 1500e18;
    // equivalent amount in USDC
    uint256 usdcAmount = 225_000e6;
    // Give the OUSGInstantManager less than enough USDC to cover the redemption
    deal(address(USDC), address(ousgInstantManager), 5_000e6);

    vm.startPrank(alice);
    ousg.approve(address(ousgInstantManager), (ousgRedeemAmount));
    vm.expectRevert(
      bytes("OUSGInstantManager::_redeemBUIDL: Insufficient BUIDL balance")
    );
    ousgInstantManager.redeem(ousgRedeemAmount);
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
