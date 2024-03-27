pragma solidity 0.8.16;

import "forge-tests/OMMF_BasicDeployment.sol";

contract Test_OMMF_Fuzz is OMMF_BasicDeployment {
  // TODO: second constraint can be relaxed. s.t. rebase does not cause a 0 value OR overflow
  //       for `getSharesFromPooledCash` in the subsequent mint
  // NOTE: We assume no deposits < $1. In reality, min deposit amount will be closer to $10k+
  // NOTE: We assume rebases will be no more than 100_000x underlying

  // Mint, Rebase Up
  function test_fuzz_mint_singleUser_rebaseUp(
    uint256 _mintAmount,
    uint256 _rebaseAmount
  ) public {
    uint256 mintAmount = bound(_mintAmount, 1e18, 1e36);
    uint256 rebaseAmount = bound(_rebaseAmount, 1, 100000 * mintAmount);

    // Mint for alice
    vm.startPrank(guardian);
    ommf.mint(alice, mintAmount);

    // Checks
    assertEq(ommf.balanceOf(alice), mintAmount);
    assertEq(ommf.sharesOf(alice), mintAmount);
    assertEq(ommf.getTotalShares(), mintAmount);
    assertEq(ommf.totalSupply(), mintAmount);
    assertEq(ommf.depositedCash(), mintAmount);

    // Rebase
    ommf.handleOracleReport(mintAmount + rebaseAmount);
    vm.stopPrank();

    // Checks after rebase
    assertEq(ommf.balanceOf(alice), mintAmount + rebaseAmount);
    assertEq(ommf.sharesOf(alice), mintAmount);
    assertEq(ommf.getTotalShares(), mintAmount);
    assertEq(ommf.totalSupply(), mintAmount + rebaseAmount);
    assertEq(ommf.depositedCash(), mintAmount + rebaseAmount);
  }

  // Mint, Rebase DOWN
  function test_fuzz_mint_singleUser_rebaseDown(
    uint256 _mintAmount,
    uint256 _rebaseAmount
  ) public {
    uint256 mintAmount = bound(_mintAmount, 1e18, 1e36);
    uint256 rebaseAmount = bound(_rebaseAmount, 1, mintAmount);

    // Mint
    vm.startPrank(guardian);
    ommf.mint(alice, mintAmount);

    // Checks
    assertEq(ommf.balanceOf(alice), mintAmount);
    assertEq(ommf.sharesOf(alice), mintAmount);
    assertEq(ommf.getTotalShares(), mintAmount);
    assertEq(ommf.depositedCash(), mintAmount);
    assertEq(ommf.totalSupply(), mintAmount);
    assertEq(ommf.depositedCash(), mintAmount);

    // Rebase
    ommf.handleOracleReport(mintAmount - rebaseAmount);
    vm.stopPrank();

    // Checks after rebase
    assertEq(ommf.balanceOf(alice), mintAmount - rebaseAmount);
    assertEq(ommf.sharesOf(alice), mintAmount);
    assertEq(ommf.getTotalShares(), mintAmount);
    assertEq(ommf.depositedCash(), mintAmount - rebaseAmount);
    assertEq(ommf.totalSupply(), mintAmount - rebaseAmount);
    assertEq(ommf.depositedCash(), mintAmount - rebaseAmount);
  }

  function test_fuzz_mint_multiUser_rebase(
    uint256 _aliceMintAmount,
    uint256 _bobMintAmount,
    uint256 _rebaseAmount
  ) public {
    uint256 aliceMintAmount = bound(_aliceMintAmount, 1e18, 1e36);
    uint256 bobMintAmount = bound(_bobMintAmount, 1e18, 1e36);
    uint256 rebaseAmount = bound(_rebaseAmount, 1e18, 100000 * aliceMintAmount);

    test_fuzz_mint_singleUser_rebaseUp(aliceMintAmount, rebaseAmount);

    // Mint for Bob
    vm.prank(guardian);
    ommf.mint(bob, bobMintAmount);

    // Checks
    assertApproxEqRel(
      ommf.balanceOf(alice),
      aliceMintAmount + rebaseAmount,
      1e13
    ); //.0001% away
    assertEq(ommf.sharesOf(alice), aliceMintAmount);
    assertApproxEqRel(ommf.balanceOf(bob), bobMintAmount, 1e13);
    uint256 bobShares = (bobMintAmount * ommf.sharesOf(alice)) /
      (aliceMintAmount + rebaseAmount);
    assertEq(ommf.sharesOf(bob), bobShares);
    assertEq(ommf.getTotalShares(), aliceMintAmount + bobShares);
    assertEq(
      ommf.depositedCash(),
      aliceMintAmount + bobMintAmount + rebaseAmount
    );
    assertEq(
      ommf.totalSupply(),
      aliceMintAmount + bobMintAmount + rebaseAmount
    );
    assertEq(
      ommf.depositedCash(),
      aliceMintAmount + bobMintAmount + rebaseAmount
    );
  }

  // Mint, Rebase, New User Mint, Rebase, Check Balances
  function test_fuzz_mint_multiUser_multiRebase(
    uint256 _aliceMintAmount,
    uint256 _bobMintAmount,
    uint256 _firstRebaseAmount,
    uint256 _secondRebaseAmount
  ) public {
    uint256 aliceMintAmount = bound(_aliceMintAmount, 1e18, 1e36);
    uint256 bobMintAmount = bound(_bobMintAmount, 1e18, 1e36);
    uint256 firstRebaseAmount = bound(
      _firstRebaseAmount,
      1e18,
      100000 * aliceMintAmount
    );
    uint256 secondRebaseAmount = bound(
      _secondRebaseAmount,
      1e18,
      10000 * aliceMintAmount // If the second rebase is too large, we will have overflows
    );

    // Mint, Rebase, New User Mint
    test_fuzz_mint_multiUser_rebase(
      aliceMintAmount,
      bobMintAmount,
      firstRebaseAmount
    );

    // Rebase
    vm.prank(guardian);
    ommf.handleOracleReport(
      aliceMintAmount + bobMintAmount + firstRebaseAmount + secondRebaseAmount
    );

    // Checks
    assertEq(ommf.sharesOf(alice), aliceMintAmount);
    uint256 bobShares = (bobMintAmount * ommf.sharesOf(alice)) /
      (aliceMintAmount + firstRebaseAmount);
    uint256 expectedBobTokens = (bobShares *
      (aliceMintAmount +
        bobMintAmount +
        firstRebaseAmount +
        secondRebaseAmount)) / (aliceMintAmount + bobShares);
    uint256 expectedAliceTokens = (aliceMintAmount +
      bobMintAmount +
      firstRebaseAmount +
      secondRebaseAmount) - expectedBobTokens;

    assertApproxEqRel(ommf.balanceOf(alice), expectedAliceTokens, 1e13); //.0001% away
    assertApproxEqRel(ommf.balanceOf(bob), expectedBobTokens, 1e13); //.0001% away
    assertEq(ommf.sharesOf(bob), bobShares);
    assertEq(ommf.getTotalShares(), aliceMintAmount + bobShares);
    assertEq(
      ommf.depositedCash(),
      aliceMintAmount + bobMintAmount + firstRebaseAmount + secondRebaseAmount
    );
    assertEq(
      ommf.totalSupply(),
      aliceMintAmount + bobMintAmount + firstRebaseAmount + secondRebaseAmount
    );
    assertEq(
      ommf.depositedCash(),
      aliceMintAmount + bobMintAmount + firstRebaseAmount + secondRebaseAmount
    );
  }

  function test_fuzz_burn_singleUser_rebaseUp(
    uint256 _mintAmount,
    uint256 _rebaseAmount
  ) public {
    uint256 mintAmount = bound(_mintAmount, 1e18, 1e36);
    uint256 rebaseAmount = bound(_rebaseAmount, 1, 100000 * mintAmount);

    test_fuzz_mint_singleUser_rebaseUp(mintAmount, rebaseAmount);

    // Burn
    uint256 aliceBalance = ommf.balanceOf(alice);
    vm.prank(alice);
    ommf.approve(address(this), aliceBalance);
    ommf.burnFrom(alice, aliceBalance);

    // Checks
    assertEq(ommf.balanceOf(alice), 0);
    assertEq(ommf.sharesOf(alice), 0);
    assertEq(ommf.getTotalShares(), 0);
    assertEq(ommf.depositedCash(), 0);
    assertEq(ommf.totalSupply(), 0);
    assertEq(ommf.depositedCash(), 0);
  }

  function test_fuzz_burn_singleUser_rebaseDown(
    uint256 _mintAmount,
    uint256 _rebaseAmount
  ) public {
    uint256 mintAmount = bound(_mintAmount, 1e18, 1e36);
    uint256 rebaseAmount = bound(_rebaseAmount, 1, mintAmount);

    test_fuzz_mint_singleUser_rebaseDown(mintAmount, rebaseAmount);

    // Burn
    uint256 aliceBalanceBefore = ommf.balanceOf(alice);
    vm.prank(alice);
    ommf.approve(address(this), aliceBalanceBefore);
    ommf.burnFrom(alice, aliceBalanceBefore);

    // Checks
    assertEq(ommf.balanceOf(alice), 0);
    if (aliceBalanceBefore == 0) {
      // If rebase down to 0 underlying RWA before, shares are still there so you're not burning anything
      assertEq(ommf.sharesOf(alice), mintAmount);
      assertEq(ommf.getTotalShares(), mintAmount);
    } else {
      assertEq(ommf.sharesOf(alice), 0);
      assertEq(ommf.getTotalShares(), 0);
    }
    assertEq(ommf.depositedCash(), 0);
    assertEq(ommf.totalSupply(), 0);
    assertEq(ommf.depositedCash(), 0);
  }

  // Mint, Rebase, New user mint, New user burn
  function test_fuzz_burn_multiUser_rebase(
    uint256 _aliceMintAmount,
    uint256 _bobMintAmount,
    uint256 _bobBurnAmount,
    uint256 _rebaseAmount
  ) public {
    uint256 aliceMintAmount = bound(_aliceMintAmount, 1e18, 1e36);
    uint256 bobMintAmount = bound(_bobMintAmount, 1e18, 1e36);
    uint256 rebaseAmount = bound(_rebaseAmount, 1e18, 100000 * aliceMintAmount);
    uint256 bobBurnAmount = bound(_bobBurnAmount, 1e18, bobMintAmount);

    test_fuzz_mint_multiUser_rebase(
      aliceMintAmount,
      bobMintAmount,
      rebaseAmount
    );

    // Burn
    uint256 bobSharesInitial = (bobMintAmount * ommf.sharesOf(alice)) /
      (aliceMintAmount + rebaseAmount);
    vm.prank(bob);
    ommf.approve(address(this), bobBurnAmount);
    ommf.burnFrom(bob, bobBurnAmount);

    // Checks
    assertEq(ommf.sharesOf(alice), aliceMintAmount);
    uint256 bobSharesBurnt = (bobBurnAmount *
      (ommf.sharesOf(alice) + bobSharesInitial)) /
      (aliceMintAmount + bobMintAmount + rebaseAmount);
    uint256 bobShares = bobSharesInitial - bobSharesBurnt;
    assertEq(ommf.sharesOf(bob), bobShares);
    uint256 expectedBobTokens = (bobShares *
      (aliceMintAmount + bobMintAmount + rebaseAmount - bobBurnAmount)) /
      (aliceMintAmount + bobShares);
    uint256 expectedAliceTokens = (aliceMintAmount +
      bobMintAmount +
      rebaseAmount -
      bobBurnAmount) - expectedBobTokens;
    assertApproxEqRel(ommf.balanceOf(alice), expectedAliceTokens, 1e13); //.0001% away
    assertApproxEqRel(ommf.balanceOf(bob), expectedBobTokens, 1e13); //.0001% away
    assertEq(ommf.getTotalShares(), aliceMintAmount + bobShares);
    assertEq(
      ommf.depositedCash(),
      aliceMintAmount + bobMintAmount + rebaseAmount - bobBurnAmount
    );
    assertEq(
      ommf.totalSupply(),
      aliceMintAmount + bobMintAmount + rebaseAmount - bobBurnAmount
    );
    assertEq(
      ommf.depositedCash(),
      aliceMintAmount + bobMintAmount + rebaseAmount - bobBurnAmount
    );
  }
}
