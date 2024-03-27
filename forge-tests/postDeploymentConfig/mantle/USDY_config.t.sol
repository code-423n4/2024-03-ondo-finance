pragma solidity 0.8.16;

import {PROD_CONSTANTS_USDY_MANTLE} from "forge-tests/postDeploymentConfig/prod_constants.t.sol";
import "forge-tests/USDY_BasicDeployment.sol";

contract ASSERT_FORK_USDY_PROD_MNT is
  PROD_CONSTANTS_USDY_MANTLE,
  USDY_BasicDeployment
{
  /**
   * @notice INPUT ADDRESSES TO CHECK CONFIG OF BELOW
   *
   * USDY Deployment: 10/24/23
   * Passing on block: 17361093
   */
  address usdy_to_check = 0x5bE26527e817998A7206475496fDE1E68957c5A6;
  //   address usdyManager_to_check = 0x25A103A1D6AeC5967c1A4fe2039cdc514886b97e;

  bytes32 impl_slot =
    bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
  bytes32 admin_slot = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

  function setUp() public override {
    usdy = USDY(usdy_to_check);
    blocklist = Blocklist(address(usdy.blocklist()));

    // allowlist = AllowlistUpgradeable(address(usdy.allowlist()));
    // sanctionsList = ISanctionsList(usdy.sanctionsList());

    // usdyManager = USDYManager(usdyManager_to_check);
    // pricerUSDY = Pricer(address(usdyManager.pricer()));
  }

  function test_print_block() public view {
    console.log("The Current Block #: ", block.number);
  }

  function test_fork_assert_usdy_token_proxy() public {
    // Assert Proxy Setup
    bytes32 impl = vm.load(address(usdy), impl_slot);
    bytes32 admin = vm.load(address(usdy), admin_slot);
    assertEq(impl, PROD_CONSTANTS_USDY_MANTLE.usdy_impl_bytes);
    assertEq(admin, PROD_CONSTANTS_USDY_MANTLE.usdy_proxy_admin_bytes);

    // Assert that the owner of the proxy admin is correct
    assertEq(
      ProxyAdmin(address(uint160(uint256(admin)))).owner(),
      PROD_CONSTANTS_USDY_MANTLE.usdy_pa_owner
    );

    /**
     * Assert Token Roles
     * 1) Assert Role count
     * 2) Assert Role membership
     */
    assertEq(usdy.getRoleMemberCount(usdy.DEFAULT_ADMIN_ROLE()), 1);
    assertEq(
      usdy.getRoleMember(usdy.DEFAULT_ADMIN_ROLE(), 0),
      PROD_CONSTANTS_USDY_MANTLE.usdy_default_admin
    );

    assertEq(usdy.getRoleMemberCount(usdy.MINTER_ROLE()), 0);

    assertEq(usdy.getRoleMemberCount(usdy.PAUSER_ROLE()), 1);
    assertEq(
      usdy.getRoleMember(usdy.PAUSER_ROLE(), 0),
      PROD_CONSTANTS_USDY_MANTLE.usdy_default_admin
    );

    /// @notice BURNER_ROLE - Not granted by default
    assertEq(usdy.getRoleMemberCount(usdy.BURNER_ROLE()), 0);
    // assertEq(
    //   usdy.getRoleMember(usdy.BURNER_ROLE(), 0),
    //   PROD_CONSTANTS_USDY_MANTLE.usdy_pauser_role
    // );

    /// @notice LIST CONFIG remains ungranted
    assertEq(usdy.getRoleMemberCount(usdy.LIST_CONFIGURER_ROLE()), 0);

    assertEq(
      address(usdy.blocklist()),
      PROD_CONSTANTS_USDY_MANTLE.usdy_blocklist
    );

    assertEq(usdy.paused(), PROD_CONSTANTS_USDY_MANTLE.paused);
    assertEq(usdy.decimals(), PROD_CONSTANTS_USDY_MANTLE.decimals);
    assertEq(usdy.name(), PROD_CONSTANTS_USDY_MANTLE.name);
    assertEq(usdy.symbol(), PROD_CONSTANTS_USDY_MANTLE.symbol);
  }

  function test_fork_assert_blocklist() public {
    assertEq(blocklist.owner(), PROD_CONSTANTS_USDY_MANTLE.block_owner);
  }
}
