pragma solidity 0.8.16;

import {PROD_CONSTANTS_USDY_MANTLE} from "forge-tests/postDeploymentConfig/prod_constants.t.sol";
import "forge-tests/USDY_BasicDeployment.sol";

contract ASSERT_FORK_rUSDY_PROD_MNT is
  PROD_CONSTANTS_USDY_MANTLE,
  USDY_BasicDeployment
{
  /**
   * @notice INPUT ADDRESSES TO CHECK CONFIG OF BELOW
   *
   * USDY Deployment: 10/24/23
   * Passing on block: 17360945
   */
  address rusdy_to_check = 0xab575258d37EaA5C8956EfABe71F4eE8F6397cF3;
  address ondo_dro_to_check = 0xA96abbe61AfEdEB0D14a20440Ae7100D9aB4882f;

  bytes32 impl_slot =
    bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
  bytes32 admin_slot = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

  function setUp() public override {
    rUSDYToken = rUSDY(rusdy_to_check);
    oracleUSDY = RWADynamicOracle(ondo_dro_to_check);
  }

  function test_print_block() public view {
    console.log("The Current Block #: ", block.number);
  }

  function test_fork_assert_rusdy_token_proxy() public {
    // Assert Proxy Setup
    bytes32 impl = vm.load(address(rUSDYToken), impl_slot);
    bytes32 admin = vm.load(address(rUSDYToken), admin_slot);
    assertEq(impl, PROD_CONSTANTS_USDY_MANTLE.rusdy_impl_bytes);
    assertEq(admin, PROD_CONSTANTS_USDY_MANTLE.rusdy_proxy_admin_bytes);

    // Assert that the owner of the proxy admin is correct
    assertEq(
      ProxyAdmin(address(uint160(uint256(admin)))).owner(),
      PROD_CONSTANTS_USDY_MANTLE.rusdy_pa_owner
    );

    /**
     * Assert Token Roles
     * 1) Assert Role count
     * 2) Assert Role membership
     */
    assertEq(rUSDYToken.getRoleMemberCount(rUSDYToken.DEFAULT_ADMIN_ROLE()), 1);
    assertEq(
      rUSDYToken.getRoleMember(rUSDYToken.DEFAULT_ADMIN_ROLE(), 0),
      PROD_CONSTANTS_USDY_MANTLE.usdy_default_admin
    );

    /// @notice No minter Role

    assertEq(rUSDYToken.getRoleMemberCount(rUSDYToken.PAUSER_ROLE()), 1);
    assertEq(
      rUSDYToken.getRoleMember(rUSDYToken.PAUSER_ROLE(), 0),
      PROD_CONSTANTS_USDY_MANTLE.usdy_default_admin
    );

    /// @notice BURNER_ROLE - Not granted by default
    // assertEq(usdy.getRoleMemberCount(usdy.BURNER_ROLE()), 1);
    // assertEq(
    //   usdy.getRoleMember(usdy.BURNER_ROLE(), 0),
    //   PROD_CONSTANTS_USDY_MANTLE.usdy_pauser_role
    // );

    assertEq(
      address(rUSDYToken.blocklist()),
      PROD_CONSTANTS_USDY_MANTLE.usdy_blocklist
    );

    assertEq(rUSDYToken.paused(), PROD_CONSTANTS_USDY_MANTLE.paused);
    assertEq(rUSDYToken.decimals(), PROD_CONSTANTS_USDY_MANTLE.decimals);
    assertEq(rUSDYToken.name(), PROD_CONSTANTS_USDY_MANTLE.rUSDY_name);
    assertEq(rUSDYToken.symbol(), PROD_CONSTANTS_USDY_MANTLE.rUSDY_symbol);

    // rUSDY Assert oracle
    assertEq(
      address(rUSDYToken.oracle()),
      PROD_CONSTANTS_USDY_MANTLE.rusdy_oracle
    );
  }

  function test_fork_assert_ondo_dro() public {
    // Assert Admin
    assertEq(oracleUSDY.getRoleMemberCount(oracleUSDY.DEFAULT_ADMIN_ROLE()), 1);
    assertEq(
      oracleUSDY.getRoleMember(oracleUSDY.DEFAULT_ADMIN_ROLE(), 0),
      PROD_CONSTANTS_USDY_MANTLE.dro_admin
    );
    // Assert Setter
    assertEq(oracleUSDY.getRoleMemberCount(oracleUSDY.SETTER_ROLE()), 1);
    assertEq(
      oracleUSDY.getRoleMember(oracleUSDY.SETTER_ROLE(), 0),
      PROD_CONSTANTS_USDY_MANTLE.dro_setter
    );
    // Assert Pauser
    assertEq(oracleUSDY.getRoleMemberCount(oracleUSDY.PAUSER_ROLE()), 0);

    // check price > 0
    uint256 currentPrice = oracleUSDY.getPrice();
    assertGt(currentPrice, 0);
  }
}
