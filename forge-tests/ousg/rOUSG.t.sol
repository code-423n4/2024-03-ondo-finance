pragma solidity 0.8.16;
import "forge-tests/OUSG_BasicDeployment.t.sol";
import "lib/forge-std/src/console.sol";

contract Test_rOUSG_ETH is OUSG_BasicDeployment {
  address constant NO_KYC_ADDRESS = 0x0000000000000000000000000000000000000Bad;
  address constant ALT_GUARDIAN = 0xaAaAaAaaAaAaAaaAaAAAAAAAAaaaAaAaAaaAaaAa;

  function setUp() public override {
    super.setUp();
    // Initial State: OUSG Oracle returns price of $100 per OUSG
    oracleCheckHarnessOUSG.setPrice(100e18);
    CashKYCSenderReceiver ousgProxied = CashKYCSenderReceiver(address(ousg));
    vm.startPrank(OUSG_GUARDIAN);
    ousgProxied.grantRole(ousgProxied.MINTER_ROLE(), OUSG_GUARDIAN);
    vm.stopPrank();

    // Sanity Asserts
    assertEq(rOUSGToken.totalSupply(), 0);
    assertTrue(
      registry.getKYCStatus(OUSG_KYC_REQUIREMENT_GROUP, address(this))
    );
    assertTrue(
      registry.getKYCStatus(OUSG_KYC_REQUIREMENT_GROUP, address(rOUSGToken))
    );
    assertTrue(registry.getKYCStatus(OUSG_KYC_REQUIREMENT_GROUP, alice));
  }

  /*//////////////////////////////////////////////////////////////
                        rOUSG Metadata Tests
  //////////////////////////////////////////////////////////////*/
  function test_rOUSG_name() public {
    string memory res = rOUSGToken.name();
    assertEq(res, "Rebasing OUSG");
  }

  function test_rOUSG_symbol() public {
    assertEq(rOUSGToken.symbol(), "rOUSG");
  }

  /*//////////////////////////////////////////////////////////////
                        rOUSG Pause/UnPause Tests
  //////////////////////////////////////////////////////////////*/

  function test_rOUSG_pause__fail_wrap() public dealAliceOUSG(1e18) pauseRousg {
    vm.prank(alice);
    vm.expectRevert("Pausable: paused");
    rOUSGToken.wrap(1e18);
  }

  function test_rOUSG_pause__fail_unwrap()
    public
    dealAliceROUSG(1e18)
    pauseRousg
  {
    vm.prank(alice);
    vm.expectRevert("Pausable: paused");
    rOUSGToken.unwrap(1e18);
  }

  function test_rOUSG_pause__fail_transfer()
    public
    dealAliceROUSG(1e18)
    pauseRousg
  {
    vm.prank(alice);
    vm.expectRevert("Pausable: paused");
    rOUSGToken.transfer(address(bob), 1e18);
  }

  function test_rOUSG_pause__fail_transferFrom() public dealAliceROUSG(1e18) {
    vm.prank(alice);
    rOUSGToken.approve(address(bob), 1e18);
    vm.prank(OUSG_GUARDIAN);
    rOUSGToken.pause();
    vm.prank(bob);
    vm.expectRevert("Pausable: paused");
    rOUSGToken.transferFrom(alice, address(bob), 1e18);
  }

  modifier pauseRousg() {
    vm.prank(OUSG_GUARDIAN);
    rOUSGToken.pause();
    _;
  }

  /*//////////////////////////////////////////////////////////////
                      Access Control Tests
  //////////////////////////////////////////////////////////////*/
  function test_rOUSG_setKYCRegistry() public {
    vm.prank(OUSG_GUARDIAN);
    rOUSGToken.setKYCRegistry(address(1));
    assertEq(address(rOUSGToken.kycRegistry()), address(1));
  }

  function test_rOUSG_setKYCRegistry__fail_accessControl() public {
    vm.expectRevert(
      _formatACRevert(ALT_GUARDIAN, rOUSGToken.CONFIGURER_ROLE())
    );

    vm.prank(ALT_GUARDIAN);
    rOUSGToken.setKYCRegistry(address(1));
  }

  function test_rOUSG_setKYCRegistry__grant_accessControl() public {
    vm.startPrank(OUSG_GUARDIAN);
    rOUSGToken.grantRole(rOUSGToken.CONFIGURER_ROLE(), ALT_GUARDIAN);
    vm.stopPrank();

    vm.prank(ALT_GUARDIAN);
    rOUSGToken.setKYCRegistry(address(1));
    assertEq(address(rOUSGToken.kycRegistry()), address(1));
  }

  function test_rOUSG_setKYCRequirementGroup() public {
    vm.prank(OUSG_GUARDIAN);
    rOUSGToken.setKYCRequirementGroup(333);
    assertEq(rOUSGToken.kycRequirementGroup(), 333);
  }

  function test_rOUSG_setKYCRequirementGroup__fail_accessControl() public {
    vm.expectRevert(
      _formatACRevert(ALT_GUARDIAN, rOUSGToken.CONFIGURER_ROLE())
    );

    vm.prank(ALT_GUARDIAN);
    rOUSGToken.setKYCRequirementGroup(333);
  }

  function test_rOUSG_setKYCRequirementGroup__grant_accessControl() public {
    vm.startPrank(OUSG_GUARDIAN);
    rOUSGToken.grantRole(rOUSGToken.CONFIGURER_ROLE(), ALT_GUARDIAN);
    vm.stopPrank();

    vm.prank(ALT_GUARDIAN);
    rOUSGToken.setKYCRequirementGroup(333);
    assertEq(rOUSGToken.kycRequirementGroup(), 333);
  }

  function test_rOUSG_setOracle() public {
    vm.prank(OUSG_GUARDIAN);
    rOUSGToken.setOracle(address(1));
    assertEq(address(rOUSGToken.oracle()), address(1));
  }

  function test_rOUSG_setOracle__fail_accessControl() public {
    vm.expectRevert(
      _formatACRevert(ALT_GUARDIAN, rOUSGToken.DEFAULT_ADMIN_ROLE())
    );

    vm.prank(ALT_GUARDIAN);
    rOUSGToken.setOracle(address(1));
  }

  function test_rOUSG_setOracle__grant_accessControl() public {
    vm.startPrank(OUSG_GUARDIAN);
    rOUSGToken.grantRole(rOUSGToken.DEFAULT_ADMIN_ROLE(), ALT_GUARDIAN);
    vm.stopPrank();

    vm.prank(ALT_GUARDIAN);
    rOUSGToken.setOracle(address(1));
    assertEq(address(rOUSGToken.oracle()), address(1));
  }

  function test_rOUSG_pause__GUARDIAN() public {
    vm.prank(OUSG_GUARDIAN);
    rOUSGToken.pause();
    assertTrue(rOUSGToken.paused());
  }

  function test_rOUSG_pause__PAUSER() public pauseRousg {
    assertTrue(rOUSGToken.paused());
  }

  function test_rOUSG_pause__fail_accessControl() public {
    vm.expectRevert(_formatACRevert(ALT_GUARDIAN, rOUSGToken.PAUSER_ROLE()));

    vm.prank(ALT_GUARDIAN);
    rOUSGToken.pause();
  }

  function test_rOUSG_pause__grant_accessControl() public {
    vm.startPrank(OUSG_GUARDIAN);
    rOUSGToken.grantRole(rOUSGToken.PAUSER_ROLE(), ALT_GUARDIAN);
    vm.stopPrank();

    vm.prank(ALT_GUARDIAN);
    rOUSGToken.pause();
    assertTrue(rOUSGToken.paused());
  }

  function test_rOUSG_unpause() public {
    vm.startPrank(OUSG_GUARDIAN);
    rOUSGToken.grantRole(rOUSGToken.PAUSER_ROLE(), ALT_GUARDIAN);
    vm.stopPrank();

    vm.prank(ALT_GUARDIAN);
    rOUSGToken.pause();

    vm.prank(OUSG_GUARDIAN);
    rOUSGToken.unpause();

    assertFalse(rOUSGToken.paused());
  }

  function test_rOUSG_unpause__fail_accessControl() public {
    vm.startPrank(OUSG_GUARDIAN);
    rOUSGToken.grantRole(rOUSGToken.PAUSER_ROLE(), ALT_GUARDIAN);
    vm.stopPrank();

    vm.prank(ALT_GUARDIAN);
    rOUSGToken.pause();

    vm.expectRevert(
      _formatACRevert(ALT_GUARDIAN, rOUSGToken.DEFAULT_ADMIN_ROLE())
    );

    vm.prank(ALT_GUARDIAN);
    rOUSGToken.unpause();
  }

  function test_rOUSG_unpause__grant_accessControl() public {
    vm.startPrank(OUSG_GUARDIAN);
    rOUSGToken.grantRole(rOUSGToken.PAUSER_ROLE(), ALT_GUARDIAN);
    vm.stopPrank();

    vm.prank(ALT_GUARDIAN);
    rOUSGToken.pause();

    vm.startPrank(OUSG_GUARDIAN);
    rOUSGToken.grantRole(rOUSGToken.DEFAULT_ADMIN_ROLE(), ALT_GUARDIAN);
    vm.stopPrank();

    vm.prank(ALT_GUARDIAN);
    rOUSGToken.unpause();

    assertFalse(rOUSGToken.paused());
  }

  /*//////////////////////////////////////////////////////////////
                        KYC Requirement Tests
  //////////////////////////////////////////////////////////////*/

  function test_rOUSG_kyc_requirement__fail_transfer_to()
    public
    dealAliceROUSG(1e18)
  {
    vm.prank(alice);
    vm.expectRevert("rOUSG: 'to' address not KYC'd");
    rOUSGToken.transfer(NO_KYC_ADDRESS, 1e18);
  }

  function test_rOUSG_kyc_requirement__fail_transferFrom_to()
    public
    dealAliceROUSG(1e18)
  {
    vm.prank(alice);
    rOUSGToken.approve(address(bob), 1e18);
    vm.prank(bob);
    vm.expectRevert("rOUSG: 'to' address not KYC'd");
    rOUSGToken.transferFrom(alice, NO_KYC_ADDRESS, 1e18);
  }

  function test_rOUSG_kyc_requirement__fail_transferFrom_caller()
    public
    dealAliceROUSG(1e18)
  {
    vm.prank(alice);
    rOUSGToken.approve(NO_KYC_ADDRESS, 1e18);
    vm.prank(NO_KYC_ADDRESS);
    vm.expectRevert("rOUSG: 'sender' address not KYC'd");
    rOUSGToken.transferFrom(alice, address(bob), 1e18);
  }

  function test_rOUSG_kyc_requirement__add_kyc_and_transfer()
    public
    dealAliceROUSG(1e18)
  {
    vm.prank(OUSG_GUARDIAN);
    _addAddressToKYC(OUSG_KYC_REQUIREMENT_GROUP, NO_KYC_ADDRESS);

    vm.prank(alice);
    rOUSGToken.transfer(NO_KYC_ADDRESS, 100e18);

    assertEq(rOUSGToken.balanceOf(alice), 0);
    assertEq(rOUSGToken.balanceOf(NO_KYC_ADDRESS), 100e18);
  }

  function test_rOUSG_kyc_requirement__add_kyc_and_transferFrom()
    public
    dealAliceROUSG(1e18)
  {
    vm.prank(OUSG_GUARDIAN);
    _addAddressToKYC(OUSG_KYC_REQUIREMENT_GROUP, NO_KYC_ADDRESS);

    vm.prank(alice);
    rOUSGToken.approve(NO_KYC_ADDRESS, 100e18);

    vm.prank(NO_KYC_ADDRESS);
    rOUSGToken.transferFrom(alice, NO_KYC_ADDRESS, 100e18);

    assertEq(rOUSGToken.balanceOf(alice), 0);
    assertEq(rOUSGToken.balanceOf(NO_KYC_ADDRESS), 100e18);
  }

  function test_rOUSG_kyc_requirement__fail_transfer_remove_kyc()
    public
    dealAliceROUSG(1e18)
  {
    vm.prank(OUSG_GUARDIAN);
    _removeAddressFromKYC(OUSG_KYC_REQUIREMENT_GROUP, bob);

    vm.prank(alice);
    vm.expectRevert("rOUSG: 'to' address not KYC'd");
    rOUSGToken.transfer(NO_KYC_ADDRESS, 100e18);
  }

  function test_rOUSG_kyc_requirement__fail_transferFrom_to_remove_kyc()
    public
    dealAliceROUSG(1e18)
  {
    vm.prank(OUSG_GUARDIAN);
    _removeAddressFromKYC(OUSG_KYC_REQUIREMENT_GROUP, bob);

    vm.prank(alice);
    rOUSGToken.approve(bob, 100e18);

    vm.prank(bob);
    vm.expectRevert("rOUSG: 'to' address not KYC'd");
    rOUSGToken.transferFrom(alice, bob, 100e18);
  }

  function test_rOUSG_kyc_requirement__fail_transferFrom_caller_remove_kyc()
    public
    dealAliceROUSG(1e18)
  {
    vm.prank(OUSG_GUARDIAN);
    _addAddressToKYC(OUSG_KYC_REQUIREMENT_GROUP, NO_KYC_ADDRESS);

    vm.prank(OUSG_GUARDIAN);
    _removeAddressFromKYC(OUSG_KYC_REQUIREMENT_GROUP, bob);

    vm.prank(alice);
    rOUSGToken.approve(bob, 100e18);

    vm.prank(bob);
    vm.expectRevert("rOUSG: 'sender' address not KYC'd");
    rOUSGToken.transferFrom(alice, NO_KYC_ADDRESS, 100e18);
  }

  function test_rOUSG_kyc_requirement__change_requirement_transfer()
    public
    dealAliceROUSG(1e18)
  {
    vm.prank(OUSG_GUARDIAN);
    rOUSGToken.setKYCRequirementGroup(444);

    vm.prank(alice);
    vm.expectRevert("rOUSG: 'from' address not KYC'd");
    rOUSGToken.transfer(bob, 100e18);

    vm.prank(OUSG_GUARDIAN);
    _addAddressToKYC(444, alice);

    vm.prank(alice);
    vm.expectRevert("rOUSG: 'to' address not KYC'd");
    rOUSGToken.transfer(bob, 100e18);

    vm.prank(OUSG_GUARDIAN);
    _addAddressToKYC(444, bob);

    vm.prank(alice);
    rOUSGToken.transfer(bob, 100e18);

    assertEq(rOUSGToken.balanceOf(alice), 0);
    assertEq(rOUSGToken.balanceOf(bob), 100e18);
  }

  function test_rOUSG_kyc_requirement__change_requirement_transferFrom()
    public
    dealAliceROUSG(1e18)
  {
    vm.prank(OUSG_GUARDIAN);
    rOUSGToken.setKYCRequirementGroup(444);

    vm.prank(alice);
    rOUSGToken.approve(bob, 100e18);

    vm.prank(bob);
    vm.expectRevert("rOUSG: 'from' address not KYC'd");
    rOUSGToken.transferFrom(alice, bob, 100e18);

    vm.prank(OUSG_GUARDIAN);
    _addAddressToKYC(444, alice);

    vm.prank(bob);
    vm.expectRevert("rOUSG: 'to' address not KYC'd");
    rOUSGToken.transferFrom(alice, bob, 100e18);

    vm.prank(OUSG_GUARDIAN);
    _addAddressToKYC(444, bob);

    vm.prank(bob);
    rOUSGToken.transferFrom(alice, bob, 100e18);

    assertEq(rOUSGToken.balanceOf(alice), 0);
    assertEq(rOUSGToken.balanceOf(bob), 100e18);
  }

  /*//////////////////////////////////////////////////////////////
                        Wrap -> Unwrap Tests
  //////////////////////////////////////////////////////////////*/
  function test_rOUSG_wrap_and_unwrap() public dealAliceROUSG(1e18) {
    assertEq(rOUSGToken.balanceOf(alice), 100e18);
    // Assert that 1 OUSG is pooled within the
    assertEq(ousg.balanceOf(address(rOUSGToken)), 1e18);

    vm.prank(alice);
    rOUSGToken.unwrap(100e18);

    assertEq(rOUSGToken.balanceOf(alice), 0);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 0);
    assertEq(ousg.balanceOf(alice), 1e18);
  }

  function test_rOUSG_wrap_and_unwrap_price_accrual()
    public
    dealAliceROUSG(1e18)
  {
    // Increase OUSG price from $ 100 -> $105
    oracleCheckHarnessOUSG.setPrice(105e18);
    // Assert balance post "rebase" of rOUSG
    assertEq(rOUSGToken.balanceOf(alice), 105e18);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 1e18);

    vm.prank(alice);
    rOUSGToken.unwrap(105e18);

    assertEq(rOUSGToken.balanceOf(alice), 0);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 0);
    assertEq(ousg.balanceOf(alice), 1e18);
  }

  function test_rOUSG_wrap_and_unwrap_price_reduction()
    public
    dealAliceROUSG(1e18)
  {
    // Increase OUSG price from $ 100 -> $95
    oracleCheckHarnessOUSG.setPrice(95e18);
    // Assert balance post "negative rebase" of rOUSG
    assertEq(rOUSGToken.balanceOf(alice), 95e18);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 1e18);

    vm.prank(alice);
    rOUSGToken.unwrap(95e18);

    assertEq(rOUSGToken.balanceOf(alice), 0);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 0);
    assertEq(ousg.balanceOf(alice), 1e18);
  }

  function test_rOUSG_wrap_and_partial_unwrap() public dealAliceROUSG(1e18) {
    assertEq(rOUSGToken.balanceOf(alice), 100e18);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 1e18);

    vm.prank(alice);
    rOUSGToken.unwrap(50e18);

    assertEq(rOUSGToken.balanceOf(alice), 50e18);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 5e17);
    assertEq(ousg.balanceOf(alice), 5e17);
  }

  function test_rOUSG_wrap_and_partial_unwrap_after_accrual()
    public
    dealAliceROUSG(1e18)
  {
    assertEq(rOUSGToken.balanceOf(alice), 100e18);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 1e18);

    // Increase OUSG price from $ 100 -> $101
    oracleCheckHarnessOUSG.setPrice(101e18);
    vm.startPrank(alice);
    rOUSGToken.unwrap(505e17);

    assertEq(rOUSGToken.balanceOf(alice), 505e17);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 5e17);
    assertEq(ousg.balanceOf(alice), 5e17);
  }

  function test_rOUSG_wrap_and_unwrap_after_transfers()
    public
    dealAliceROUSG(1e18)
  {
    vm.startPrank(alice);
    rOUSGToken.transfer(address(bob), 50e18);
    assertEq(rOUSGToken.balanceOf(alice), 50e18);
    assertEq(rOUSGToken.balanceOf(bob), 50e18);
    rOUSGToken.unwrap(50e18);
    vm.stopPrank();

    assertEq(rOUSGToken.balanceOf(alice), 0);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 5e17);
    assertEq(ousg.balanceOf(alice), 5e17);

    vm.prank(bob);
    rOUSGToken.unwrap(50e18);
    assertEq(rOUSGToken.balanceOf(bob), 0);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 0);
    assertEq(ousg.balanceOf(alice), 5e17);
  }

  function test_rOUSG__wrap_and_unwrap_after_accrual_and_transfers()
    public
    dealAliceROUSG(1e18)
  {
    vm.prank(alice);
    rOUSGToken.transfer(address(bob), 50e18);
    assertEq(rOUSGToken.balanceOf(alice), 50e18);
    assertEq(rOUSGToken.balanceOf(bob), 50e18);

    oracleCheckHarnessOUSG.setPrice(101e18);
    assertEq(rOUSGToken.balanceOf(alice), 505e17);
    assertEq(rOUSGToken.balanceOf(bob), 505e17);

    vm.prank(alice);
    rOUSGToken.unwrap(505e17);

    assertEq(rOUSGToken.balanceOf(alice), 0);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 5e17);
    assertEq(ousg.balanceOf(alice), 5e17);

    vm.prank(bob);
    rOUSGToken.unwrap(505e17);
    assertEq(rOUSGToken.balanceOf(bob), 0);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 0);
    assertEq(ousg.balanceOf(alice), 5e17);
  }

  /*//////////////////////////////////////////////////////////////
                    Balance Requirement Tests
  //////////////////////////////////////////////////////////////*/

  function test_rOUSG_wrap__fail_insufficient_balance()
    public
    dealAliceOUSG(1e18)
  {
    vm.startPrank(alice);
    ousg.approve(address(rOUSGToken), 1e18 + 1);
    vm.expectRevert("ERC20: transfer amount exceeds balance");
    rOUSGToken.wrap(1e18 + 1);
    vm.stopPrank();
  }

  function test_rOUSG_unwrap__fail_insufficient_balance()
    public
    dealAliceROUSG(1e18)
  {
    vm.prank(alice);
    vm.expectRevert("BURN_AMOUNT_EXCEEDS_BALANCE");
    rOUSGToken.unwrap(100e18 + 1);
  }

  function test_rOUSG_unwrap_after_accrual__fail_insufficient_balance()
    public
    dealAliceROUSG(1e18)
  {
    // Increase OUSG price from $ 100 -> $101
    oracleCheckHarnessOUSG.setPrice(101e18);
    vm.expectRevert("BURN_AMOUNT_EXCEEDS_BALANCE");
    vm.prank(alice);
    rOUSGToken.unwrap(101e18 + 1);
  }

  function test_rOUSG_transfer__fail_insufficient_balance()
    public
    dealAliceROUSG(1e18)
  {
    vm.prank(alice);
    vm.expectRevert("TRANSFER_AMOUNT_EXCEEDS_BALANCE");
    rOUSGToken.transfer(address(bob), 100e18 + 1);
  }

  function test_rOUSG_transferFrom__fail_insufficient_balance()
    public
    dealAliceROUSG(1e18)
  {
    vm.prank(alice);
    rOUSGToken.approve(address(bob), 100e18 + 1);
    vm.prank(bob);
    vm.expectRevert("TRANSFER_AMOUNT_EXCEEDS_BALANCE");
    rOUSGToken.transferFrom(alice, address(bob), 100e18 + 1);
  }

  /*//////////////////////////////////////////////////////////////
                        Approval Tests
  //////////////////////////////////////////////////////////////*/

  function test_rOUSG_approve() public dealAliceROUSG(1e18) {
    vm.prank(alice);
    rOUSGToken.approve(address(bob), 100e18);
    assertEq(rOUSGToken.allowance(alice, bob), 100e18);
  }

  function test_rOUSG_increase_allowance() public dealAliceROUSG(1e18) {
    vm.startPrank(alice);
    rOUSGToken.approve(address(bob), 100e18);
    rOUSGToken.increaseAllowance(bob, 100e18);
    vm.stopPrank();
    assertEq(rOUSGToken.allowance(alice, bob), 200e18);
  }

  function test_rOUSG_decrease_allowance() public dealAliceROUSG(1e18) {
    vm.startPrank(alice);
    rOUSGToken.approve(address(bob), 100e18);
    rOUSGToken.decreaseAllowance(bob, 50e18);
    vm.stopPrank();
    assertEq(rOUSGToken.allowance(alice, bob), 50e18);
  }

  function test_rOUSG_approve_and_decrease_allowance__fail_transfer_insufficient_allowance()
    public
    dealAliceROUSG(1e18)
  {
    rOUSGToken.approve(address(bob), 100e18);
    rOUSGToken.decreaseAllowance(bob, 50e18);
    vm.expectRevert("TRANSFER_AMOUNT_EXCEEDS_ALLOWANCE");
    vm.prank(bob);
    rOUSGToken.transferFrom(alice, address(bob), 51e18);
  }

  function test_rOUSG_approve_and_transfer__fail_transfer_insufficient_allowance()
    public
    dealAliceROUSG(1e18)
  {
    vm.prank(alice);
    rOUSGToken.approve(address(bob), 100e18);
    vm.startPrank(bob);
    rOUSGToken.transferFrom(alice, address(bob), 50e18);
    vm.expectRevert("TRANSFER_AMOUNT_EXCEEDS_ALLOWANCE");
    rOUSGToken.transferFrom(alice, address(bob), 51e18);
  }

  function test_rOUSG_approve_and_accrue__fail_transfer_insufficient_allowance()
    public
    dealAliceROUSG(1e18)
  {
    // Increase OUSG price from $ 100 -> $101
    vm.prank(alice);
    rOUSGToken.approve(address(bob), 100e18);
    oracleCheckHarnessOUSG.setPrice(101e18);

    vm.expectRevert("TRANSFER_AMOUNT_EXCEEDS_ALLOWANCE");
    rOUSGToken.transferFrom(alice, address(bob), 101e18);
  }

  /*//////////////////////////////////////////////////////////////
                      Oracle Accrual Tests
  //////////////////////////////////////////////////////////////*/

  function test_rOUSG_accrual() public dealAliceROUSG(1e18) {
    assertEq(rOUSGToken.balanceOf(alice), 100e18);
    // Increase OUSG price from $ 100 -> $101
    oracleCheckHarnessOUSG.setPrice(101e18);
    assertEq(rOUSGToken.balanceOf(alice), 101e18);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 1e18);
  }

  function test_rOUSG_wrap_after_accrual_and_accrue()
    public
    dealAliceOUSG(1e18)
  {
    // Increase OUSG price from $ 100 -> $101
    oracleCheckHarnessOUSG.setPrice(101e18);
    assertEq(rOUSGToken.balanceOf(alice), 0);

    vm.startPrank(alice);
    ousg.approve(address(rOUSGToken), 1e18);
    rOUSGToken.wrap(1e18);
    vm.stopPrank();

    assertEq(rOUSGToken.balanceOf(alice), 101e18);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 1e18);

    // Increase OUSG price from $ 101 -> $102
    oracleCheckHarnessOUSG.setPrice(102e18);
    assertEq(rOUSGToken.balanceOf(alice), 102e18);
  }

  function test_rOUSG_multiple_wraps_and_accruals() public dealAliceOUSG(3e18) {
    vm.startPrank(alice);
    ousg.transfer(address(bob), 1e18);
    ousg.transfer(address(charlie), 1e18);
    ousg.approve(address(rOUSGToken), 1e18);
    rOUSGToken.wrap(1e18);
    vm.stopPrank();
    // Increase OUSG price from $ 100 -> $101
    oracleCheckHarnessOUSG.setPrice(101e18);
    assertEq(rOUSGToken.balanceOf(alice), 101e18);

    vm.startPrank(bob);
    ousg.approve(address(rOUSGToken), 1e18);
    rOUSGToken.wrap(1e18);
    vm.stopPrank();

    assertEq(rOUSGToken.balanceOf(bob), 101e18);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 2e18);

    // Increase OUSG price from $ 101 -> $102
    oracleCheckHarnessOUSG.setPrice(102e18);
    assertEq(rOUSGToken.balanceOf(alice), 102e18);
    assertEq(rOUSGToken.balanceOf(bob), 102e18);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 2e18);

    vm.startPrank(charlie);
    ousg.approve(address(rOUSGToken), 1e18);
    rOUSGToken.wrap(1e18);
    vm.stopPrank();

    assertEq(rOUSGToken.balanceOf(charlie), 102e18);

    // Increase OUSG price from $ 102 -> $103
    oracleCheckHarnessOUSG.setPrice(103e18);
    assertEq(rOUSGToken.balanceOf(alice), 103e18);
    assertEq(rOUSGToken.balanceOf(bob), 103e18);
    assertEq(rOUSGToken.balanceOf(charlie), 103e18);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 3e18);
  }

  function test_rOUSG_multiple_wraps_and_accrual_on_same_account()
    public
    dealAliceOUSG(3e18)
  {
    vm.startPrank(alice);
    ousg.approve(address(rOUSGToken), 1e18);
    rOUSGToken.wrap(1e18);
    vm.stopPrank();
    // Increase OUSG price from $ 100 -> $101
    oracleCheckHarnessOUSG.setPrice(101e18);
    assertEq(rOUSGToken.balanceOf(alice), 101e18);

    vm.startPrank(alice);
    ousg.approve(address(rOUSGToken), 1e18);
    rOUSGToken.wrap(1e18);
    vm.stopPrank();

    assertEq(rOUSGToken.balanceOf(alice), 202e18);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 2e18);

    // Increase OUSG price from $ 101 -> $102
    oracleCheckHarnessOUSG.setPrice(102e18);
    assertEq(rOUSGToken.balanceOf(alice), 204e18);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 2e18);

    vm.startPrank(alice);
    ousg.approve(address(rOUSGToken), 1e18);
    rOUSGToken.wrap(1e18);
    vm.stopPrank();

    assertEq(rOUSGToken.balanceOf(alice), 306e18);

    // Increase OUSG price from $ 102 -> $103
    oracleCheckHarnessOUSG.setPrice(103e18);
    assertEq(rOUSGToken.balanceOf(alice), 309e18);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 3e18);
  }

  function test_rOUSG_negative_accrual() public dealAliceROUSG(1e18) {
    assertEq(rOUSGToken.balanceOf(alice), 100e18);
    // Decrease OUSG price from $ 100 -> $99
    oracleCheckHarnessOUSG.setPrice(99e18);
    assertEq(rOUSGToken.balanceOf(alice), 99e18);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 1e18);
  }

  function test_rOUSG_wrap_after_negative_accrual() public dealAliceOUSG(1e18) {
    // Increase OUSG price from $ 100 -> $99
    oracleCheckHarnessOUSG.setPrice(99e18);
    assertEq(rOUSGToken.balanceOf(alice), 0);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 0);

    vm.startPrank(alice);
    ousg.approve(address(rOUSGToken), 1e18);
    rOUSGToken.wrap(1e18);
    vm.stopPrank();
    assertEq(rOUSGToken.balanceOf(alice), 99e18);

    oracleCheckHarnessOUSG.setPrice(100e18);
    assertEq(rOUSGToken.balanceOf(alice), 100e18);
  }

  function test_OUSG_price_set_to_zero() public dealAliceROUSG(1e18) {
    // Increase OUSG price from $ 100 -> $0
    oracleCheckHarnessOUSG.setPrice(0);
    assertEq(rOUSGToken.balanceOf(alice), 0);
    assertEq(ousg.balanceOf(address(rOUSGToken)), 1e18);
  }

  /*//////////////////////////////////////////////////////////////
                  Mathematical Uncertainty Tests
  //////////////////////////////////////////////////////////////*/

  function test_rOUSG_full_unwrap_after_transfers()
    public
    dealAliceROUSG(1e18)
  {
    vm.startPrank(alice);
    uint256 transferAmount = 50e18 + 1;
    uint256 aliceRemainingBalance = 100e18 - transferAmount;
    rOUSGToken.transfer(address(bob), transferAmount);
    // ~49.99.... e18
    assertEq(rOUSGToken.balanceOf(alice), aliceRemainingBalance);
    assertEq(rOUSGToken.balanceOf(bob), transferAmount);

    rOUSGToken.unwrap(aliceRemainingBalance);
    assertEq(rOUSGToken.balanceOf(alice), 0);
    vm.stopPrank();

    vm.prank(bob);
    rOUSGToken.unwrap(transferAmount);
    assertEq(rOUSGToken.balanceOf(bob), 0);
    // DUST! Not all values can be represented in the rOUSG token logic. When user's transfer,
    // they transfer shares, which are calculated as
    // shares = _rOUSGAmount * 1e18 * BPS_DENOMINATOR / getOUSGPrice();
    // 1e22   = 1e18         * 1e18 * 1e4            /  1e18
    // ousgOut = shares / BPS_DENOMINATOR;
    // 1e18 = 1e22 / 1e4;
    // As a result, 1 OUSG is split between Alice and Bob and a dust amount is left over
    // within the rOUSG token
    uint256 aliceOUSGWithdrawal = (aliceRemainingBalance * 1e18) / 100e18;
    uint256 bobOUSGWithdrawal = (transferAmount * 1e18) / 100e18;
    assertEq(ousg.balanceOf(alice), aliceOUSGWithdrawal);
    assertEq(ousg.balanceOf(bob), bobOUSGWithdrawal);
    assertEq(
      ousg.balanceOf(address(rOUSGToken)),
      1e18 - aliceOUSGWithdrawal - bobOUSGWithdrawal
    );
  }

  function test_rOUSG_full_unwrap_after_accrual_and_transfers()
    public
    dealAliceROUSG(1e18)
  {
    // Alice starts with 100 rOUSG
    // Alice to transfer ~ half rOUSG to Bob
    vm.startPrank(alice);
    uint256 transferAmount = 50e18 + 1;
    uint256 aliceRemainingBalance = 100e18 - transferAmount;
    rOUSGToken.transfer(address(bob), transferAmount);
    // ~49.99.... e18
    assertEq(rOUSGToken.balanceOf(alice), aliceRemainingBalance);
    assertEq(rOUSGToken.balanceOf(bob), transferAmount);

    oracleCheckHarnessOUSG.setPrice(150e18);
    uint256 aliceBalanceAfterRebase = (aliceRemainingBalance * 150e18) / 100e18;
    uint256 bobBalanceAfterRebase = (transferAmount * 150e18) / 100e18;

    rOUSGToken.unwrap(aliceBalanceAfterRebase);
    assertEq(rOUSGToken.balanceOf(alice), 0);
    vm.stopPrank();

    vm.prank(bob);
    rOUSGToken.unwrap(bobBalanceAfterRebase);
    assertEq(rOUSGToken.balanceOf(bob), 0);
    // DUST! Not all values can be represented in the rOUSG token logic. When user's transfer,
    // they transfer shares, which are calculated as
    // shares = _rOUSGAmount * 1e18 * BPS_DENOMINATOR / getOUSGPrice();
    // 1e22   = 1e18         * 1e18 * 1e4            /  1e18
    // As a result, 1 OUSG is split between Alice and Bob and a dust amount is left over
    // within the rOUSG token
    uint256 aliceOUSGWithdrawal = (aliceBalanceAfterRebase * 1e18) / 150e18;
    uint256 bobOUSGWithdrawal = (bobBalanceAfterRebase * 1e18) / 150e18;
    assertEq(ousg.balanceOf(alice), aliceOUSGWithdrawal);
    assertEq(ousg.balanceOf(bob), bobOUSGWithdrawal);
    assertEq(
      ousg.balanceOf(address(rOUSGToken)),
      1e18 - aliceOUSGWithdrawal - bobOUSGWithdrawal
    );
  }

  modifier dealAliceOUSG(uint256 ousgAmount) {
    vm.prank(OUSG_GUARDIAN);
    ousg.mint(alice, ousgAmount);
    _;
  }

  modifier dealAliceROUSG(uint256 ousgAmount) {
    vm.prank(OUSG_GUARDIAN);
    ousg.mint(alice, ousgAmount);
    vm.startPrank(alice);
    ousg.approve(address(rOUSGToken), ousgAmount);
    rOUSGToken.wrap(ousgAmount);
    vm.stopPrank();
    _;
  }
}
