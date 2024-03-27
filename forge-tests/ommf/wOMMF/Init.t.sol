pragma solidity 0.8.16;

import "forge-tests/OMMF_BasicDeployment.sol";

contract Test_WOMMF_init is OMMF_BasicDeployment {
  function setUp() public override {
    super.setUp();
  }

  function test_initialize_implementation() public {
    vm.expectRevert(bytes("Initializable: contract is already initialized"));
    wommfImplementation.initialize(
      address(1),
      "Bad Token",
      "Bad Token",
      address(0),
      address(1),
      1
    );
  }

  function test_implementation_RBAC_null() public {
    uint256 res = wommfImplementation.getRoleMemberCount(bytes32(0));
    assertEq(res, 0);
    res = wommfImplementation.getRoleMemberCount(keccak256("MINTER_ROLE"));
    assertEq(res, 0);
    res = wommfImplementation.getRoleMemberCount(keccak256("PAUSER_ROLE"));
    assertEq(res, 0);
  }
}
