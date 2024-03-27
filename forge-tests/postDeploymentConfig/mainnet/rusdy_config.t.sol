pragma solidity 0.8.16;

import {PROD_CONSTANTS_USDY_MAINNET} from "forge-tests/postDeploymentConfig/prod_constants.t.sol";
import "forge-tests/USDY_BasicDeployment.sol";

contract ASSERT_FORK_rUSDY_PROD is
  PROD_CONSTANTS_USDY_MAINNET,
  USDY_BasicDeployment
{
  /**
   * @notice INPUT ADDRESSES TO CHECK CONFIG OF BELOW
   *
   * USDY Deployment: ----
   * Passing on block: ----
   */
  address rusdy_to_check = 0x0000000000000000000000000000000000000000; /// @dev FILL OUT!
  address ondo_dro_to_check = 0xA0219AA5B31e65Bc920B5b6DFb8EdF0988121De0;

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
    bytes32 impl = vm.load(address(usdy), impl_slot);
    bytes32 admin = vm.load(address(usdy), admin_slot);
    assertEq(impl, PROD_CONSTANTS_USDY_MAINNET.rusdy_impl_bytes);
    assertEq(admin, PROD_CONSTANTS_USDY_MAINNET.rusdy_proxy_admin_bytes);

    // Assert that the owner of the proxy admin is correct
    assertEq(
      ProxyAdmin(address(uint160(uint256(admin)))).owner(),
      PROD_CONSTANTS_USDY_MAINNET.rusdy_pa_owner
    );

    /**
     * Assert Token Roles
     * 1) Assert Role count
     * 2) Assert Role membership
     */
    assertEq(rUSDYToken.getRoleMemberCount(rUSDYToken.DEFAULT_ADMIN_ROLE()), 1);
    assertEq(
      rUSDYToken.getRoleMember(rUSDYToken.DEFAULT_ADMIN_ROLE(), 0),
      PROD_CONSTANTS_USDY_MAINNET.usdy_default_admin
    );

    assertEq(rUSDYToken.getRoleMemberCount(rUSDYToken.PAUSER_ROLE()), 2);
    assertEq(
      rUSDYToken.getRoleMember(rUSDYToken.PAUSER_ROLE(), 0),
      PROD_CONSTANTS_USDY_MAINNET.usdy_default_admin
    );
    assertEq(
      rUSDYToken.getRoleMember(rUSDYToken.PAUSER_ROLE(), 1),
      PROD_CONSTANTS_USDY_MAINNET.usdy_pauser_role
    );

    /// @notice BURNER_ROLE - Not granted by default
    // assertEq(usdy.getRoleMemberCount(usdy.BURNER_ROLE()), 1);
    // assertEq(
    //   usdy.getRoleMember(usdy.BURNER_ROLE(), 0),
    //   PROD_CONSTANTS_USDY_MAINNET.usdy_pauser_role
    // );

    assertEq(
      rUSDYToken.getRoleMemberCount(rUSDYToken.LIST_CONFIGURER_ROLE()),
      1
    );
    assertEq(
      rUSDYToken.getRoleMember(rUSDYToken.LIST_CONFIGURER_ROLE(), 0),
      PROD_CONSTANTS_USDY_MAINNET.usdy_list_config_role
    );

    // Assert Token config
    assertEq(
      address(rUSDYToken.allowlist()),
      PROD_CONSTANTS_USDY_MAINNET.usdy_allowlist
    );
    assertEq(
      address(rUSDYToken.blocklist()),
      PROD_CONSTANTS_USDY_MAINNET.usdy_blocklist
    );
    assertEq(
      address(rUSDYToken.sanctionsList()),
      PROD_CONSTANTS_USDY_MAINNET.usdy_sanctionslist
    );
    assertEq(rUSDYToken.paused(), PROD_CONSTANTS_USDY_MAINNET.paused);
    assertEq(rUSDYToken.decimals(), PROD_CONSTANTS_USDY_MAINNET.decimals);
    assertEq(rUSDYToken.name(), PROD_CONSTANTS_USDY_MAINNET.rUSDY_name);
    assertEq(rUSDYToken.symbol(), PROD_CONSTANTS_USDY_MAINNET.rUSDY_symbol);

    // rUSDY Assert oracle
    assertEq(
      address(rUSDYToken.oracle()),
      PROD_CONSTANTS_USDY_MAINNET.rusdy_oracle
    );
  }

  function test_fork_assert_ondo_dro_ETH() public {
    // Assert Admin
    assertEq(oracleUSDY.getRoleMemberCount(oracleUSDY.DEFAULT_ADMIN_ROLE()), 1);
    assertEq(
      oracleUSDY.getRoleMember(oracleUSDY.DEFAULT_ADMIN_ROLE(), 0),
      PROD_CONSTANTS_USDY_MAINNET.dro_admin
    );
    // Assert Setter
    assertEq(oracleUSDY.getRoleMemberCount(oracleUSDY.SETTER_ROLE()), 1);
    assertEq(
      oracleUSDY.getRoleMember(oracleUSDY.SETTER_ROLE(), 0),
      PROD_CONSTANTS_USDY_MAINNET.dro_setter
    );
    // Assert Pauser
    assertEq(oracleUSDY.getRoleMemberCount(oracleUSDY.PAUSER_ROLE()), 1);
    assertEq(
      oracleUSDY.getRoleMember(oracleUSDY.PAUSER_ROLE(), 0),
      PROD_CONSTANTS_USDY_MAINNET.dro_pauser
    );
    // check price > 0
    uint256 currentPrice = oracleUSDY.getPrice();
    assertGt(currentPrice, 0);
  }
}
