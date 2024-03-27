pragma solidity 0.8.16;

import "forge-tests/helpers/Constants.sol";
import "forge-tests/helpers/DSTestPlus.sol";
import "contracts/usdy/restrictedUSDYMetadata/RestrictedUSDYMetadata.sol";
import "contracts/interfaces/IRestrictedUSDYMetadata.sol";

contract Test_RestrictedUSDYMetadata is Constants, DSTestPlus {
  event RestrictionAdded(
    address account,
    IRestrictedUSDYMetadata.Restriction restriction
  );
  event RestrictionRemoved(
    address account,
    IRestrictedUSDYMetadata.Restriction restriction
  );

  RestrictedUSDYMetadata restrictedUSDYMetadata;
  IRestrictedUSDYMetadata.Restriction restriction =
    IRestrictedUSDYMetadata.Restriction(bytes32("0x0"), 100, 100);
  IRestrictedUSDYMetadata.Restriction secondRestriction =
    IRestrictedUSDYMetadata.Restriction(bytes32("0x1"), 100, 200);

  function setUp() public {
    vm.warp(50);
    vm.prank(guardian);
    restrictedUSDYMetadata = new RestrictedUSDYMetadata(guardian, bob);

    vm.prank(bob);
    restrictedUSDYMetadata.addToRestrictedList(alice, restriction);
  }

  function test_add_restriction() public {
    (
      bytes32 returnedDepositId,
      uint256 returnedRestrictionAmont,
      uint256 returnedUnsrestrictedAfter
    ) = restrictedUSDYMetadata.restrictionList(alice, 0);
    assertEq(returnedDepositId, restriction.depositId);
    assertEq(returnedRestrictionAmont, restriction.amountRestricted);
    assertEq(returnedUnsrestrictedAfter, restriction.restrictedUntil);
  }

  function test_add_second_restriction() public {
    vm.expectEmit();
    emit Test_RestrictedUSDYMetadata.RestrictionAdded(alice, secondRestriction);
    vm.prank(bob);
    restrictedUSDYMetadata.addToRestrictedList(alice, secondRestriction);

    (
      bytes32 returnedDepositId0,
      uint256 returnedRestrictionAmont0,
      uint256 returnedUnsrestrictedAfter0
    ) = restrictedUSDYMetadata.restrictionList(alice, 0);
    assertEq(returnedDepositId0, restriction.depositId);
    assertEq(returnedRestrictionAmont0, restriction.amountRestricted);
    assertEq(returnedUnsrestrictedAfter0, restriction.restrictedUntil);

    (
      bytes32 returnedDepositId1,
      uint256 returnedRestrictionAmont1,
      uint256 returnedUnsrestrictedAfter1
    ) = restrictedUSDYMetadata.restrictionList(alice, 1);
    assertEq(returnedDepositId1, secondRestriction.depositId);
    assertEq(returnedRestrictionAmont1, secondRestriction.amountRestricted);
    assertEq(returnedUnsrestrictedAfter1, secondRestriction.restrictedUntil);
  }

  function test_remove_restriction() public {
    vm.expectEmit();
    emit Test_RestrictedUSDYMetadata.RestrictionRemoved(alice, restriction);
    vm.prank(bob);
    restrictedUSDYMetadata.removeFromRestrictedList(alice, restriction);

    vm.expectRevert();
    restrictedUSDYMetadata.restrictionList(alice, 0);
  }

  function test_add_and_remove_restriction() public {
    vm.startPrank(bob);
    restrictedUSDYMetadata.addToRestrictedList(alice, secondRestriction);
    restrictedUSDYMetadata.removeFromRestrictedList(alice, restriction);
    vm.stopPrank();

    (
      bytes32 returnedDepositId,
      uint256 returnedRestrictionAmont,
      uint256 returnedUnsrestrictedAfter
    ) = restrictedUSDYMetadata.restrictionList(alice, 0);
    assertEq(returnedDepositId, secondRestriction.depositId);
    assertEq(returnedRestrictionAmont, secondRestriction.amountRestricted);
    assertEq(returnedUnsrestrictedAfter, secondRestriction.restrictedUntil);

    vm.expectRevert();
    restrictedUSDYMetadata.restrictionList(alice, 1);
  }

  function test_add_restriction_fail_not_setter() public {
    vm.expectRevert(
      abi.encodePacked(
        "AccessControl: account ",
        Strings.toHexString(uint160(address(this)), 20),
        " is missing role ",
        Strings.toHexString(
          uint256(restrictedUSDYMetadata.RESTRICTED_LIST_SETTER()),
          32
        )
      )
    );

    restrictedUSDYMetadata.addToRestrictedList(charlie, restriction);
  }

  function test_remove_restriction_fail_not_setter() public {
    vm.expectRevert(
      abi.encodePacked(
        "AccessControl: account ",
        Strings.toHexString(uint160(address(this)), 20),
        " is missing role ",
        Strings.toHexString(
          uint256(restrictedUSDYMetadata.RESTRICTED_LIST_SETTER()),
          32
        )
      )
    );

    restrictedUSDYMetadata.removeFromRestrictedList(alice, restriction);
  }

  function test_add_restriction_fail_time_in_past() public {
    vm.expectRevert(IRestrictedUSDYMetadata.RestrictedUntilInPast.selector);
    vm.prank(bob);
    restrictedUSDYMetadata.addToRestrictedList(
      charlie,
      IRestrictedUSDYMetadata.Restriction(bytes32("0x2"), 20, 20)
    );
  }

  function test_add_restriction_fail_no_amount() public {
    vm.expectRevert(IRestrictedUSDYMetadata.RestrictionAmountZero.selector);
    vm.prank(bob);
    restrictedUSDYMetadata.addToRestrictedList(
      charlie,
      IRestrictedUSDYMetadata.Restriction(bytes32("0x2"), 0, 100)
    );
  }

  function test_remove_restriction_fail_not_restricted() public {
    vm.expectRevert(IRestrictedUSDYMetadata.RestrictionNotFound.selector);
    vm.prank(bob);
    restrictedUSDYMetadata.removeFromRestrictedList(charlie, restriction);
  }

  function test_remove_restriction_fail_restriction_not_found() public {
    vm.expectRevert(IRestrictedUSDYMetadata.RestrictionNotFound.selector);
    vm.prank(bob);
    restrictedUSDYMetadata.removeFromRestrictedList(
      alice,
      IRestrictedUSDYMetadata.Restriction(bytes32("0x2"), 200, 100)
    );
  }

  function test_get_restricted_amount() public {
    assertEq(restrictedUSDYMetadata.getRestrictedAmount(alice), 100);
    vm.prank(bob);
    restrictedUSDYMetadata.addToRestrictedList(alice, secondRestriction);

    assertEq(restrictedUSDYMetadata.getRestrictedAmount(alice), 200);

    vm.warp(150);

    assertEq(restrictedUSDYMetadata.getRestrictedAmount(alice), 100);
  }
}
