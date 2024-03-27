pragma solidity 0.8.16;

import "forge-tests/OMMF_BasicDeployment.sol";

contract Test_OMMF is OMMF_BasicDeployment {
  /*//////////////////////////////////////////////////////////////
                            Basic Tests
  //////////////////////////////////////////////////////////////*/

  function test_ommf_name() public {
    assertEq(ommf.name(), "Ondo US Money Markets");
  }

  function test_ommf_symbol() public {
    assertEq(ommf.symbol(), "OMMF");
  }

  function test_ommf_decimals() public {
    assertEq(ommf.decimals(), 18);
  }

  function test_pause_fail_accessControl() public {
    vm.expectRevert(_formatACRevert(address(this), ommf.PAUSER_ROLE()));
    ommf.pause();
  }

  function test_pause() public {
    vm.prank(guardian);
    ommf.pause();
    assertTrue(ommf.paused());
  }

  function test_unpause_fail_accessControl() public {
    vm.expectRevert(_formatACRevert(address(this), ommf.OMMF_MANAGER_ROLE()));
    ommf.unpause();
  }

  function test_unpause() public {
    test_pause();
    vm.prank(guardian);
    ommf.unpause();
    assertFalse(ommf.paused());
  }

  function test_setKYCRequirementGroup_fail_accessControl() public {
    vm.expectRevert(_formatACRevert(address(this), ommf.KYC_CONFIGURER_ROLE()));
    ommf.setKYCRequirementGroup(1);
  }

  function test_setKYCRequirementGroup() public {
    vm.prank(guardian);
    vm.expectEmit(true, true, true, true);
    emit KYCRequirementGroupSet(OMMF_KYC_REQUIREMENT_GROUP, 1);
    ommf.setKYCRequirementGroup(1);
    assertEq(ommf.kycRequirementGroup(), 1);
  }

  function test_setKYCRegistry_fail_accessControl() public {
    vm.expectRevert(_formatACRevert(address(this), ommf.KYC_CONFIGURER_ROLE()));
    ommf.setKYCRegistry(address(0));
  }

  function test_setKYCRegistry() public {
    KYCRegistry newRegistry = new KYCRegistry(
      address(this),
      address(SANCTIONS_ORACLE)
    );
    vm.prank(guardian);
    vm.expectEmit(true, true, true, true);
    emit KYCRegistrySet(address(registry), address(newRegistry));
    ommf.setKYCRegistry(address(newRegistry));
    assertEq(address(ommf.kycRegistry()), address(newRegistry));
  }

  function test_handleOracleReport_fail_notOracle() public {
    vm.expectRevert("OMMF: not oracle");
    ommf.handleOracleReport(100e18);
  }

  function test_handleOracleReport() public {
    uint256 original = ommf.depositedCash();
    vm.prank(oracle);
    vm.expectEmit(true, true, true, true);
    emit OracleReportHandled(original, 101e18);
    ommf.handleOracleReport(101e18);
    assertEq(ommf.depositedCash(), 101e18);
  }

  function test_ommf_postDeploymentInitialization() public {
    assertEq(ommf.oracle(), oracle);
    assertEq(address(ommf.kycRegistry()), address(registry));
    assertEq(ommf.kycRequirementGroup(), OMMF_KYC_REQUIREMENT_GROUP);
    assertTrue(ommf.hasRole(ommf.DEFAULT_ADMIN_ROLE(), guardian));
    assertTrue(ommf.hasRole(ommf.MINTER_ROLE(), guardian));
    assertTrue(ommf.hasRole(ommf.PAUSER_ROLE(), guardian));
    assertTrue(ommf.hasRole(ommf.BURNER_ROLE(), guardian));
    assertTrue(ommf.hasRole(ommf.KYC_CONFIGURER_ROLE(), guardian));
  }

  /*//////////////////////////////////////////////////////////////
                        Basic Mint Tests
  //////////////////////////////////////////////////////////////*/

  function test_ommf_mint_fail_accessControl() public {
    vm.expectRevert(_formatACRevert(address(this), ommf.MINTER_ROLE()));
    ommf.mint(address(this), 100e18);
  }

  function test_ommf_mint_fail_zeroDepositAmount() public {
    vm.prank(guardian);
    vm.expectRevert("OMMF: zero deposit amount");
    ommf.mint(address(this), 0);
  }

  function test_ommf_mint_fail_zeroAddress() public {
    vm.prank(guardian);
    vm.expectRevert("MINT_TO_THE_ZERO_ADDRESS");
    ommf.mint(address(0), 100e18);
  }

  function test_ommf_mint_fail_kyc_initiator() public {
    _removeAddressFromKYC(OMMF_KYC_REQUIREMENT_GROUP, guardian);
    vm.prank(guardian);
    vm.expectRevert("OMMF: must be KYC'd to initiate transfer");
    ommf.mint(address(this), 100e18);
  }

  function test_ommf_mint_fail_kyc_receiver() public {
    _removeAddressFromKYC(OMMF_KYC_REQUIREMENT_GROUP, address(this));
    vm.prank(guardian);
    vm.expectRevert("OMMF: `to` address must be KYC'd to receive tokens");
    ommf.mint(address(this), 100e18);
  }

  function test_ommf_mint_fail_paused() public pausedState {
    vm.expectRevert("Pausable: paused");
    vm.prank(guardian);
    ommf.mint(address(this), 100e18);
  }

  function test_ommf_mint_firstDeposit() public {
    vm.prank(guardian);
    vm.expectEmit(true, true, true, true);
    emit TransferShares(address(0), address(this), 100e18);
    vm.expectEmit(true, true, true, true);
    emit Transfer(address(0), address(this), 100e18);
    ommf.mint(address(this), 100e18);

    // Checks
    assertEq(ommf.balanceOf(address(this)), 100e18);
    assertEq(ommf.sharesOf(address(this)), 100e18);
    assertEq(ommf.getTotalShares(), 100e18);
    assertEq(ommf.depositedCash(), 100e18);
    assertEq(ommf.totalSupply(), 100e18);
  }

  /*//////////////////////////////////////////////////////////////
                      Basic Admin Burn Tests
  //////////////////////////////////////////////////////////////*/

  function test_ommf_burn_fail_accessControl() public {
    vm.expectRevert(_formatACRevert(address(this), ommf.BURNER_ROLE()));
    ommf.adminBurn(address(this), 100e18);
  }

  function test_ommf_burn_fail_zeroAddress() public {
    vm.prank(guardian);
    vm.expectRevert("BURN_FROM_THE_ZERO_ADDRESS");
    ommf.adminBurn(address(0), 100e18);
  }

  function test_ommf_burn_fail_paused() public pausedState {
    vm.expectRevert("Pausable: paused");
    vm.prank(guardian);
    ommf.adminBurn(address(this), 100e18);
  }

  function test_ommf_burn_fail_kyc_initator() public {
    _removeAddressFromKYC(OMMF_KYC_REQUIREMENT_GROUP, guardian);
    vm.prank(guardian);
    vm.expectRevert("OMMF: must be KYC'd to initiate transfer");
    ommf.adminBurn(address(this), 100e18);
  }

  function test_ommf_burn_fail_kyc_burnedFrom() public {
    _removeAddressFromKYC(OMMF_KYC_REQUIREMENT_GROUP, address(this));
    vm.prank(guardian);
    vm.expectRevert("OMMF: `from` address must be KYC'd to send tokens");
    ommf.adminBurn(address(this), 100e18);
  }

  function test_ommf_burn_postFirstMint() public {
    vm.startPrank(guardian);
    ommf.mint(address(this), 100e18);
    vm.expectEmit(true, true, true, true);
    emit TransferShares(address(this), address(0), 100e18);
    vm.expectEmit(true, true, true, true);
    emit Transfer(address(this), address(0), 100e18);
    ommf.adminBurn(address(this), 100e18);
    vm.stopPrank();

    // Checks
    assertEq(ommf.balanceOf(address(this)), 0);
    assertEq(ommf.sharesOf(address(this)), 0);
    assertEq(ommf.getTotalShares(), 0);
    assertEq(ommf.totalSupply(), 0);
    assertEq(ommf.depositedCash(), 0);
  }

  /*//////////////////////////////////////////////////////////////
                      Basic Transfer Tests
  //////////////////////////////////////////////////////////////*/

  function test_ommf_transfer_fail_paused() public pausedState {
    vm.expectRevert("Pausable: paused");
    ommf.transfer(alice, 0);
  }

  function test_ommf_transfer_fail_zeroAddress() public {
    vm.expectRevert("TRANSFER_TO_THE_ZERO_ADDRESS");
    ommf.transfer(address(0), 100e18);
  }

  function test_ommf_transfer_fail_kyc_sender() public {
    _removeAddressFromKYC(OMMF_KYC_REQUIREMENT_GROUP, address(this));
    vm.expectRevert("OMMF: `from` address must be KYC'd to send tokens");
    ommf.transfer(alice, 100e18);
  }

  function test_ommf_fail_kyc_receiver() public {
    _removeAddressFromKYC(OMMF_KYC_REQUIREMENT_GROUP, alice);
    vm.expectRevert("OMMF: `to` address must be KYC'd to receive tokens");
    ommf.transfer(alice, 100e18);
  }

  function test_ommf_transfer_fail_insufficientBalance() public {
    vm.prank(guardian);
    ommf.mint(address(this), 100e18);
    vm.expectRevert("TRANSFER_AMOUNT_EXCEEDS_BALANCE");
    ommf.transfer(alice, 200e18);
  }

  function test_ommf_transfer() public {
    vm.prank(guardian);
    ommf.mint(address(this), 100e18);
    vm.expectEmit(true, true, true, true);
    emit TransferShares(address(this), alice, 100e18);
    vm.expectEmit(true, true, true, true);
    emit Transfer(address(this), alice, 100e18);
    ommf.transfer(alice, 100e18);

    // Checks
    assertEq(ommf.balanceOf(address(this)), 0);
    assertEq(ommf.balanceOf(alice), 100e18);
    assertEq(ommf.sharesOf(address(this)), 0);
    assertEq(ommf.sharesOf(alice), 100e18);
    assertEq(ommf.getTotalShares(), 100e18);
    assertEq(ommf.depositedCash(), 100e18);
    assertEq(ommf.totalSupply(), 100e18);
  }

  /*//////////////////////////////////////////////////////////////
                  Basic Approve/TransferFrom Tests
  //////////////////////////////////////////////////////////////*/

  function test_ommf_approve_fail_paused() public pausedState {
    vm.expectRevert("Pausable: paused");
    ommf.approve(alice, 100e18);
  }

  function test_ommf_approve_fail_zeroAddress() public {
    vm.expectRevert("APPROVE_TO_ZERO_ADDRESS");
    ommf.approve(address(0), 100e18);
  }

  function test_ommf_approve() public {
    vm.prank(guardian);
    ommf.mint(address(this), 100e18);
    vm.expectEmit(true, true, true, true);
    emit Approval(address(this), alice, 100e18);
    ommf.approve(alice, 100e18);
  }

  function test_ommf_transferFrom_fail_allowance() public {
    test_ommf_approve();
    vm.prank(alice);
    vm.expectRevert("TRANSFER_AMOUNT_EXCEEDS_ALLOWANCE");
    ommf.transferFrom(address(this), bob, 200e18);
  }

  function test_ommf_transferFrom_fail_kyc_initiator() public {
    test_ommf_approve();
    _removeAddressFromKYC(OMMF_KYC_REQUIREMENT_GROUP, alice);
    vm.prank(alice);
    vm.expectRevert("OMMF: must be KYC'd to initiate transfer");
    ommf.transferFrom(address(this), bob, 100e18);
  }

  function test_ommf_transferFrom_fail_kyc_sender() public {
    test_ommf_approve();
    _removeAddressFromKYC(OMMF_KYC_REQUIREMENT_GROUP, address(this));
    vm.prank(alice);
    vm.expectRevert("OMMF: `from` address must be KYC'd to send tokens");
    ommf.transferFrom(address(this), bob, 100e18);
  }

  function test_ommf_transferFrom_fail_kyc_recipient() public {
    test_ommf_approve();
    _removeAddressFromKYC(OMMF_KYC_REQUIREMENT_GROUP, bob);
    vm.prank(alice);
    vm.expectRevert("OMMF: `to` address must be KYC'd to receive tokens");
    ommf.transferFrom(address(this), bob, 100e18);
  }

  function test_ommf_transferFrom() public {
    test_ommf_approve();
    vm.prank(alice);
    vm.expectEmit(true, true, true, true);
    emit TransferShares(address(this), bob, 100e18);
    vm.expectEmit(true, true, true, true);
    emit Transfer(address(this), bob, 100e18);
    vm.expectEmit(true, true, true, true);
    emit Approval(address(this), alice, 0);
    ommf.transferFrom(address(this), bob, 100e18);

    // Checks
    assertEq(ommf.balanceOf(address(this)), 0);
    assertEq(ommf.balanceOf(bob), 100e18);
    assertEq(ommf.sharesOf(address(this)), 0);
    assertEq(ommf.sharesOf(bob), 100e18);
    assertEq(ommf.getTotalShares(), 100e18);
    assertEq(ommf.depositedCash(), 100e18);
    assertEq(ommf.totalSupply(), 100e18);
  }

  function test_ommf_transferFrom_postRebase() public {
    test_ommf_approve();
    vm.prank(guardian);
    ommf.handleOracleReport(200e18); // Double underlying
    vm.prank(alice);
    ommf.transferFrom(address(this), bob, 100e18);

    // Checks
    assertEq(ommf.balanceOf(address(this)), 100e18);
    assertEq(ommf.balanceOf(bob), 100e18);
    assertEq(ommf.sharesOf(address(this)), 50e18);
    assertEq(ommf.sharesOf(bob), 50e18);
    assertEq(ommf.getTotalShares(), 100e18);
    assertEq(ommf.depositedCash(), 200e18);
    assertEq(ommf.totalSupply(), 200e18);

    // Alice cannot transfer any more
    vm.expectRevert("TRANSFER_AMOUNT_EXCEEDS_ALLOWANCE");
    vm.prank(alice);
    ommf.transferFrom(address(this), bob, 1);
  }

  /*//////////////////////////////////////////////////////////////
             Basic Increase/Decrease Allowance Tests
  //////////////////////////////////////////////////////////////*/

  function test_ommf_increaseAllowance_fail_paused() public pausedState {
    vm.expectRevert("Pausable: paused");
    ommf.increaseAllowance(alice, 100e18);
  }

  function test_ommf_increaseAllowance_fail_zeroAddress() public {
    vm.expectRevert("APPROVE_TO_ZERO_ADDRESS");
    ommf.increaseAllowance(address(0), 100e18);
  }

  function test_ommf_increaseAllowance() public {
    // Mint and increase allowance
    vm.prank(guardian);
    ommf.mint(address(this), 100e18);
    vm.expectEmit(true, true, true, true);
    emit Approval(address(this), alice, 100e18);
    ommf.increaseAllowance(alice, 100e18);

    // Alice can spend 100 OMMF
    vm.prank(alice);
    ommf.transferFrom(address(this), bob, 100e18);

    // Checks
    assertEq(ommf.balanceOf(address(this)), 0);
    assertEq(ommf.balanceOf(bob), 100e18);
    assertEq(ommf.sharesOf(address(this)), 0);
    assertEq(ommf.sharesOf(bob), 100e18);
    assertEq(ommf.getTotalShares(), 100e18);
    assertEq(ommf.depositedCash(), 100e18);
    assertEq(ommf.totalSupply(), 100e18);
  }

  function test_ommf_decreaseAllowance_fail_decreaseTooMuch() public {
    vm.expectRevert("DECREASED_ALLOWANCE_BELOW_ZERO");
    ommf.decreaseAllowance(alice, 100e18);
  }

  function test_ommf_decreaseAllowance_fail_paused() public {
    ommf.increaseAllowance(alice, 100e18);
    vm.prank(guardian);
    ommf.pause();
    vm.expectRevert("Pausable: paused");
    ommf.decreaseAllowance(alice, 100e18);
  }

  function test_ommf_decreaseAllowance() public {
    // Mint and decrease allowance
    vm.prank(guardian);
    ommf.mint(address(this), 100e18);
    ommf.increaseAllowance(alice, 100e18);
    vm.expectEmit(true, true, true, true);
    emit Approval(address(this), alice, 50e18);
    ommf.decreaseAllowance(alice, 50e18);

    // Alice can spend 50 OMMF
    vm.prank(alice);
    ommf.transferFrom(address(this), bob, 50e18);

    // Checks
    assertEq(ommf.balanceOf(address(this)), 50e18);
    assertEq(ommf.balanceOf(bob), 50e18);
    assertEq(ommf.sharesOf(address(this)), 50e18);
    assertEq(ommf.sharesOf(bob), 50e18);
    assertEq(ommf.getTotalShares(), 100e18);
    assertEq(ommf.depositedCash(), 100e18);
    assertEq(ommf.totalSupply(), 100e18);
  }

  /*//////////////////////////////////////////////////////////////
                         BurnFrom Tests
  //////////////////////////////////////////////////////////////*/

  function test_ommf_burnFrom_fail_paused() public {
    // Mint
    vm.prank(guardian);
    ommf.mint(address(this), 100e18);
    ommf.approve(alice, 100e18);

    // Pause
    vm.prank(guardian);
    ommf.pause();

    // Burn
    vm.prank(alice);
    vm.expectRevert("Pausable: paused");
    ommf.burnFrom(address(this), 100e18);
  }

  function test_ommf_burnFrom_fail_allowance() public {
    vm.expectRevert("BURN_AMOUNT_EXCEEDS_ALLOWANCE");
    ommf.burnFrom(alice, 100e18);
  }

  function test_ommf_burnFrom_fail_underflow() public {
    ommf.approve(alice, 100e18);

    vm.prank(alice);
    vm.expectRevert();
    ommf.burnFrom(address(this), 100e18);
  }

  function test_ommf_burnFrom_fail_insufficientBalance() public {
    vm.startPrank(guardian);
    ommf.mint(address(this), 100e18);
    ommf.mint(bob, 100e18);
    vm.stopPrank();
    ommf.approve(alice, 200e18);

    vm.prank(alice);
    vm.expectRevert("BURN_AMOUNT_EXCEEDS_BALANCE");
    ommf.burnFrom(address(this), 200e18);
  }

  function test_ommf_burnFrom() public {
    // Mint
    vm.prank(guardian);
    ommf.mint(address(this), 100e18);
    ommf.approve(alice, 100e18);

    // Burn
    vm.prank(alice);
    vm.expectEmit(true, true, true, true);
    emit Approval(address(this), alice, 0);
    vm.expectEmit(true, true, true, true);
    emit TransferShares(address(this), address(0), 100e18);
    vm.expectEmit(true, true, true, true);
    emit Transfer(address(this), address(0), 100e18);
    ommf.burnFrom(address(this), 100e18);

    // Checks
    assertEq(ommf.balanceOf(address(this)), 0);
    assertEq(ommf.sharesOf(address(this)), 0);
    assertEq(ommf.getTotalShares(), 0);
    assertEq(ommf.depositedCash(), 0);
    assertEq(ommf.totalSupply(), 0);
  }

  function test_ommf_burnFrom_postRebase() public {
    // Mint
    vm.startPrank(guardian);
    ommf.mint(address(this), 100e18);
    ommf.mint(bob, 100e18);

    // Double Underlying
    ommf.handleOracleReport(400e18);
    vm.stopPrank();

    // Cache Variables for Checks
    uint256 bobBalanceBefore = ommf.balanceOf(bob); // 200e18
    uint256 bobSharesBefore = ommf.sharesOf(bob); // 100e18
    uint256 testRunnerBalanceBefore = ommf.balanceOf(address(this)); // 200e18

    // Burn
    ommf.approve(alice, testRunnerBalanceBefore);
    vm.prank(alice);
    ommf.burnFrom(address(this), testRunnerBalanceBefore);

    // Checks
    assertEq(ommf.balanceOf(address(this)), 0);
    assertEq(ommf.sharesOf(address(this)), 0);
    assertEq(ommf.balanceOf(bob), bobBalanceBefore);
    assertEq(ommf.sharesOf(bob), bobSharesBefore);
    assertEq(ommf.getTotalShares(), 100e18);
    assertEq(ommf.depositedCash(), 200e18);
    assertEq(ommf.totalSupply(), 200e18);
  }

  /*//////////////////////////////////////////////////////////////
                        Burn Test
  //////////////////////////////////////////////////////////////*/

  function test_ommf_user_burn_fail_paused() public {
    // Mint
    vm.prank(guardian);
    ommf.mint(alice, 100e18);

    // Pause
    vm.prank(guardian);
    ommf.pause();

    // Burn
    vm.prank(alice);
    vm.expectRevert("Pausable: paused");
    ommf.burn(100e18);
  }

  function test_ommf_user_burn_fail_insufficientBalance() public {
    // Mint
    vm.prank(guardian);
    ommf.mint(alice, 100e18);

    // Burn
    vm.prank(alice);
    vm.expectRevert("BURN_AMOUNT_EXCEEDS_BALANCE");
    ommf.burn(101e18);
  }

  function test_ommf_user_burn() public {
    // Mint
    vm.prank(guardian);
    ommf.mint(alice, 100e18);

    // Burn
    vm.prank(alice);
    vm.expectEmit(true, true, true, true);
    emit TransferShares(alice, address(0), 100e18);
    vm.expectEmit(true, true, true, true);
    emit Transfer(alice, address(0), 100e18);
    ommf.burn(100e18);
  }

  function test_ommf_user_burn_post_rebase() public {
    // Mint
    vm.startPrank(guardian);
    ommf.mint(alice, 100e18);
    ommf.mint(bob, 100e18);
    ommf.mint(charlie, 100e18);
    vm.stopPrank();

    // Double Underlying
    _rebase(600e18);

    // Burn tokens
    vm.prank(alice);
    ommf.burn(100e18);
    vm.prank(bob);
    ommf.burn(200e18);

    // Checks
    assertEq(ommf.balanceOf(alice), 100e18);
    assertEq(ommf.balanceOf(bob), 0);
    assertEq(ommf.sharesOf(alice), 50e18);
    assertEq(ommf.sharesOf(bob), 0);
    assertEq(ommf.balanceOf(charlie), 200e18);
    assertEq(ommf.sharesOf(charlie), 100e18);

    assertEq(ommf.depositedCash(), 300e18);
    assertEq(ommf.getTotalShares(), 150e18);
    assertEq(ommf.totalSupply(), 300e18);
  }

  /*//////////////////////////////////////////////////////////////
                          Test Modifiers
  //////////////////////////////////////////////////////////////*/

  modifier pausedState() {
    vm.prank(guardian);
    ommf.pause();
    _;
  }
}
