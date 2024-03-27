pragma solidity 0.8.16;

import "forge-tests/OMMF_BasicDeployment.sol";

contract Test_WOMMF is OMMF_BasicDeployment {
  function test_wommf_ommf_token_pointer() public {
    address res = address(wommf.ommf());
    assertEq(res, address(ommf));
  }

  function test_wommf_name() public {
    string memory res = wommf.name();
    assertEq(res, "Wrapped OMMF");
  }

  function test_wommf_symbol() public {
    string memory res = wommf.symbol();
    assertEq(res, "WOMMF");
  }

  function test_wommf_decimals() public {
    uint256 decimals = wommf.decimals();
    assertEq(decimals, 18);
  }

  function test_approval() public dealalice {
    vm.prank(alice);
    ommf.approve(address(7), 5e18);
    uint256 res = ommf.allowance(alice, address(7));
    assertEq(res, 5e18);
  }

  function test_wrapping() public dealalice {
    vm.startPrank(alice);
    ommf.approve(address(wommf), 5e18);
    wommf.wrap(5e18);
    uint256 res = wommf.balanceOf(alice);
    // Assert that the amount of wOMMF received is the amount
    // of shares
    assertEq(res, 0.5e18);
  }

  function test_wrapping_and_accrual() public dealalice {
    vm.startPrank(alice);
    ommf.approve(address(wommf), 5e18);
    wommf.wrap(5e18);
    // Assert the ommf balance in the wrapped token contract
    uint256 res = ommf.balanceOf(address(wommf));
    assertEq(res, 5e18);
    vm.stopPrank();
    // Rebase
    _rebase(50e18);
    // Assert balance post rebase
    res = ommf.balanceOf(address(wommf));
    assertEq(res, 25e18);
    // Assert that the balance of the alice post rebase
    res = ommf.balanceOf(alice);
    assertEq(res, 25e18);
  }

  function test_pause_fail_accessControl() public {
    vm.expectRevert(_formatACRevert(address(this), wommf.PAUSER_ROLE()));
    wommf.pause();
  }

  function test_pause() public {
    vm.prank(guardian);
    wommf.pause();
    assertTrue(wommf.paused());
  }

  function test_unpause_fail_accessControl() public {
    vm.expectRevert(_formatACRevert(address(this), wommf.WOMMF_MANAGER_ROLE()));
    wommf.unpause();
  }

  function test_unpause() public pausedState {
    vm.startPrank(guardian);
    wommf.grantRole(wommf.WOMMF_MANAGER_ROLE(), charlie);
    vm.stopPrank();

    vm.prank(charlie);
    wommf.unpause();
    assertFalse(wommf.paused());

    vm.startPrank(guardian);
    wommf.revokeRole(wommf.WOMMF_MANAGER_ROLE(), charlie);
    vm.stopPrank();
  }

  function test_wommf_transfers_paused() public dealAndWrap pausedState {
    vm.prank(alice);
    vm.expectRevert(bytes("ERC20Pausable: token transfer while paused"));
    wommf.transfer(guardian, 1e18);
  }

  function test_wommf_wrap_paused() public dealalice pausedState {
    vm.startPrank(alice);
    ommf.approve(address(wommf), 1e18);
    vm.expectRevert(bytes("ERC20Pausable: token transfer while paused"));
    wommf.wrap(1e18);
  }

  function test_wommf_unwrap_paused() public dealAndWrap pausedState {
    vm.prank(alice);
    vm.expectRevert(bytes("ERC20Pausable: token transfer while paused"));
    wommf.unwrap(1e18);
  }

  function test_wommf_admin_burn() public dealAndWrap {
    // Assert the starting token balances
    assertEq(10e18, ommf.balanceOf(address(wommf)));
    assertEq(1e18, wommf.balanceOf(alice));
    // Admin burn the tokens
    vm.prank(guardian);
    wommf.adminBurn(alice, 1e18);
    // Assert the end state token balances
    assertEq(0, wommf.balanceOf(alice));
    assertEq(0, ommf.balanceOf(address(wommf)));
    assertEq(10e18, ommf.balanceOf(guardian));
  }

  function test_unwrapping_post_accrual() public dealAndWrap {
    // Rebase
    _rebase(500e18);
    // Prank the alice address
    vm.startPrank(alice);
    // Unwrap
    wommf.unwrap(1e18);
    // Assert that the total rebase amount is given
    uint256 res = ommf.balanceOf(alice);
    assertEq(res, 500e18);
  }

  function test_fuzz_unwrap_post_accrual(
    uint256 newPoolAmt
  ) public dealAndWrap {
    vm.assume(newPoolAmt < 1_000_000_000e18);
    _rebase(newPoolAmt);
    vm.startPrank(alice);
    wommf.unwrap(1e18);
    uint256 res = ommf.balanceOf(alice);
    assertEq(res, newPoolAmt);
  }

  modifier dealalice() {
    _mintRWAToUser(alice, 1e18);
    _rebase(10e18);
    _;
  }

  modifier dealAndWrap() {
    _mintRWAToUser(alice, 1e18);
    _rebase(10e18);
    vm.startPrank(alice);
    ommf.approve(address(wommf), 10e18);
    wommf.wrap(10e18);
    vm.stopPrank();
    _;
  }

  modifier pausedState() {
    vm.prank(guardian);
    wommf.pause();
    _;
  }
}
