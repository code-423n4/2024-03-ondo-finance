pragma solidity 0.8.16;

import {STAGING_CONSTANTS_OMMF_MAINNET} from "forge-tests/postDeploymentConfig/prod_constants.t.sol";
import "forge-tests/OMMF_BasicDeployment.sol";
import "contracts/ommf/ommf_token/OMMFRebaseSetter.sol";

contract ASSERT_FORK_OMMF_STAGING is
  STAGING_CONSTANTS_OMMF_MAINNET,
  OMMF_BasicDeployment
{
  /**
   * @notice INPUT ADDRESSES TO CHECK CONFIG OF BELOW
   *
   * @dev FILL THIS OUT POST PROD DEPLOYMENT
   * OMMF DEPLOYMENT: 09/27/23
   * Passing on block: 18229347
   */
  address ommf_to_check = 0x1dB541F00595B783957A0ED80eD70035Ad727E30;
  address ommfManager_to_check = 0x533C5c15E073f56860B3091d7f7414f1cf6d4aE3;
  address wommf_to_check = 0x09dEF4Eca85658900A33859bD22B6cd26C6Ccbf8;

  bytes32 impl_slot =
    bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
  bytes32 admin_slot = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);
  OMMFRebaseSetter rebaseSetter;

  function setUp() public override {
    ommf = OMMF(ommf_to_check);
    wommf = WOMMF(wommf_to_check);
    registry = KYCRegistry(address(ommf.kycRegistry()));
    ommfManager = OMMFManager(ommfManager_to_check);
    pricerOmmf = PricerWithOracle(address(ommfManager.pricer()));
    rebaseSetter = OMMFRebaseSetter(ommf.oracle());
  }

  function test_print_block() public view {
    console.log("The Current Block #: ", block.number);
  }

  function test_fork_assert_ommf_manager() public {
    assertEq(
      ommfManager.getRoleMemberCount(ommfManager.DEFAULT_ADMIN_ROLE()),
      1
    );
    assertEq(
      ommfManager.getRoleMember(ommfManager.DEFAULT_ADMIN_ROLE(), 0),
      STAGING_CONSTANTS_OMMF_MAINNET.ommfhub_default_admin
    );
    assertEq(ommfManager.getRoleMemberCount(ommfManager.MANAGER_ADMIN()), 1);
    assertEq(
      ommfManager.getRoleMember(ommfManager.MANAGER_ADMIN(), 0),
      STAGING_CONSTANTS_OMMF_MAINNET.ommfhub_manager_admin
    );
    assertEq(ommfManager.getRoleMemberCount(ommfManager.PAUSER_ADMIN()), 1);
    assertEq(
      ommfManager.getRoleMember(ommfManager.PAUSER_ADMIN(), 0),
      STAGING_CONSTANTS_OMMF_MAINNET.ommfhub_pauser_admin
    );

    assertEq(
      ommfManager.getRoleMemberCount(ommfManager.PRICE_ID_SETTER_ROLE()),
      1
    );
    assertEq(
      ommfManager.getRoleMember(ommfManager.PRICE_ID_SETTER_ROLE(), 0),
      STAGING_CONSTANTS_OMMF_MAINNET.ommfhub_price_id_setter_role
    );

    // assertEq(ommfManager.getRoleMemberCount(ommfManager.RELAYER_ROLE()), 1);
    // assertEq(
    //   ommfManager.getRoleMember(ommfManager.RELAYER_ROLE(), 0),
    //   STAGING_CONSTANTS_OMMF_MAINNET.ommfhub_relayer_role
    // );

    // ASSERT OMMF Manager config
    assertEq(
      ommfManager.assetSender(),
      STAGING_CONSTANTS_OMMF_MAINNET.asset_sender
    );
    assertEq(
      ommfManager.assetRecipient(),
      STAGING_CONSTANTS_OMMF_MAINNET.asset_recipient
    );
    assertEq(
      ommfManager.feeRecipient(),
      STAGING_CONSTANTS_OMMF_MAINNET.fee_recipient
    );
    assertEq(
      address(ommfManager.rwa()),
      STAGING_CONSTANTS_OMMF_MAINNET.ommf_asset
    );
    assertEq(
      address(ommfManager.collateral()),
      STAGING_CONSTANTS_OMMF_MAINNET.collateral
    );
    assertEq(
      address(ommfManager.pricer()),
      STAGING_CONSTANTS_OMMF_MAINNET.ommf_pricer
    );
    assertEq(
      ommfManager.minimumDepositAmount(),
      STAGING_CONSTANTS_OMMF_MAINNET.min_deposit_amt
    );
    assertEq(
      ommfManager.minimumRedemptionAmount(),
      STAGING_CONSTANTS_OMMF_MAINNET.min_redeem_amt
    );
    assertEq(ommfManager.mintFee(), STAGING_CONSTANTS_OMMF_MAINNET.mint_fee);
    assertEq(
      ommfManager.redemptionFee(),
      STAGING_CONSTANTS_OMMF_MAINNET.redeem_fee
    );
    assertEq(
      ommfManager.BPS_DENOMINATOR(),
      STAGING_CONSTANTS_OMMF_MAINNET.bps_denominator
    );
    assertEq(
      address(ommfManager.kycRegistry()),
      STAGING_CONSTANTS_OMMF_MAINNET.kyc_registry
    );
    assertEq(
      ommfManager.decimalsMultiplier(),
      STAGING_CONSTANTS_OMMF_MAINNET.decimals_multiplier
    );
    // Check that instant minting/redeeming functionality is paused
    assertEq(ommfManager.instantMintPaused(), true);
    assertEq(ommfManager.instantRedemptionPaused(), true);
  }

  function test_fork_assert_ommf_token_proxy() public {
    // Assert Proxy Setup
    bytes32 impl = vm.load(address(ommf), impl_slot);
    bytes32 admin = vm.load(address(ommf), admin_slot);
    assertEq(impl, STAGING_CONSTANTS_OMMF_MAINNET.ommf_impl_bytes);
    assertEq(admin, STAGING_CONSTANTS_OMMF_MAINNET.ommf_proxy_admin_bytes);

    // Assert that the owner of the proxy admin is correct
    assertEq(
      ProxyAdmin(address(uint160(uint256(admin)))).owner(),
      STAGING_CONSTANTS_OMMF_MAINNET.ommf_pa_owner
    );

    assertEq(ommf.getRoleMemberCount(ommf.DEFAULT_ADMIN_ROLE()), 1);
    assertEq(
      ommf.getRoleMember(ommf.DEFAULT_ADMIN_ROLE(), 0),
      STAGING_CONSTANTS_OMMF_MAINNET.ommf_default_admin
    );
    assertEq(ommf.getRoleMemberCount(ommf.MINTER_ROLE()), 1);
    assertEq(
      ommf.getRoleMember(ommf.MINTER_ROLE(), 0),
      STAGING_CONSTANTS_OMMF_MAINNET.ommf_minter_role
    );

    // assertEq(ommf.getRoleMemberCount(ommf.PAUSER_ROLE()), 1);
    // assertEq(
    //   ommf.getRoleMember(ommf.PAUSER_ROLE(), 0),
    //   STAGING_CONSTANTS_OMMF_MAINNET.ommf_default_admin
    // );
    // assertEq(
    //   ommf.getRoleMember(ommf.PAUSER_ROLE(), 1),
    //   STAGING_CONSTANTS_OMMF_MAINNET.ommf_pauser_role
    // );

    /// @notice BURNER_ROLE - Not granted by default
    // assertEq(ommf.getRoleMemberCount(ommf.BURNER_ROLE()), 1);
    // assertEq(
    //   ommf.getRoleMember(ommf.BURNER_ROLE(), 0),
    //   PROD_CONSTANTS_OMMF.ommf_pauser_role
    // );

    // ASSERT Token config
    assertEq(ommf.paused(), STAGING_CONSTANTS_OMMF_MAINNET.paused);
    assertEq(ommf.decimals(), STAGING_CONSTANTS_OMMF_MAINNET.decimals);
    assertEq(ommf.name(), STAGING_CONSTANTS_OMMF_MAINNET.name);
    assertEq(ommf.symbol(), STAGING_CONSTANTS_OMMF_MAINNET.symbol);
    // OMMF: assert the rebase setter contract address
    assertEq(
      ommf.oracle(),
      STAGING_CONSTANTS_OMMF_MAINNET.ommf_rebase_setter_role
    );
  }

  function test_fork_assert_pricer_ommf() public {
    assertEq(pricerOmmf.getRoleMemberCount(pricerOmmf.DEFAULT_ADMIN_ROLE()), 1);
    assertEq(
      pricerOmmf.getRoleMember(pricerOmmf.DEFAULT_ADMIN_ROLE(), 0),
      STAGING_CONSTANTS_OMMF_MAINNET.pricer_default_admin
    );
    assertEq(pricerOmmf.getRoleMemberCount(pricerOmmf.PRICE_UPDATE_ROLE()), 1);
    assertEq(
      pricerOmmf.getRoleMember(pricerOmmf.PRICE_UPDATE_ROLE(), 0),
      STAGING_CONSTANTS_OMMF_MAINNET.pricer_price_update_role
    );
  }

  function test_fork_assert_rebaseSetter() public {
    assertEq(
      rebaseSetter.getRoleMemberCount(rebaseSetter.DEFAULT_ADMIN_ROLE()),
      1
    );
    assertEq(
      rebaseSetter.getRoleMember(rebaseSetter.DEFAULT_ADMIN_ROLE(), 0),
      STAGING_CONSTANTS_OMMF_MAINNET.rebaseSetter_admin_role
    );
    assertEq(rebaseSetter.getRoleMemberCount(rebaseSetter.SETTER_ROLE()), 1);
    assertEq(
      rebaseSetter.getRoleMember(rebaseSetter.SETTER_ROLE(), 0),
      STAGING_CONSTANTS_OMMF_MAINNET.rebaseSetter_setter_role
    );
  }

  function test_fork_assert_wommf_token_proxy() public {
    // Assert Proxy Setup
    bytes32 impl = vm.load(address(wommf), impl_slot);
    bytes32 admin = vm.load(address(wommf), admin_slot);
    assertEq(impl, STAGING_CONSTANTS_OMMF_MAINNET.wommf_impl_bytes);
    assertEq(admin, STAGING_CONSTANTS_OMMF_MAINNET.wommf_proxy_admin_bytes);

    // Assert that the owner of the proxy admin is correct
    assertEq(
      ProxyAdmin(address(uint160(uint256(admin)))).owner(),
      STAGING_CONSTANTS_OMMF_MAINNET.wommf_pa_owner
    );

    assertEq(wommf.getRoleMemberCount(wommf.DEFAULT_ADMIN_ROLE()), 1);
    assertEq(
      wommf.getRoleMember(wommf.DEFAULT_ADMIN_ROLE(), 0),
      STAGING_CONSTANTS_OMMF_MAINNET.wommf_default_admin
    );
    // assertEq(wommf.getRoleMemberCount(wommf.MINTER_ROLE()), 1);
    // assertEq(
    //   ommf.getRoleMember(ommf.MINTER_ROLE(), 0),
    //   STAGING_CONSTANTS_OMMF_MAINNET.wommf_minter_role
    // );

    assertEq(ommf.getRoleMemberCount(ommf.PAUSER_ROLE()), 1);
    assertEq(
      ommf.getRoleMember(ommf.PAUSER_ROLE(), 0),
      STAGING_CONSTANTS_OMMF_MAINNET.ommf_default_admin
    );
    // assertEq(
    //   ommf.getRoleMember(ommf.PAUSER_ROLE(), 1),
    //   STAGING_CONSTANTS_OMMF_MAINNET.ommf_pauser_role
    // );

    /// @notice BURNER_ROLE - Not granted by default
    // assertEq(ommf.getRoleMemberCount(ommf.BURNER_ROLE()), 1);
    // assertEq(
    //   ommf.getRoleMember(ommf.BURNER_ROLE(), 0),
    //   PROD_CONSTANTS_OMMF.ommf_pauser_role
    // );

    // ASSERT Token config
    assertEq(wommf.paused(), STAGING_CONSTANTS_OMMF_MAINNET.paused);
    assertEq(wommf.decimals(), STAGING_CONSTANTS_OMMF_MAINNET.wommf_decimals);
    assertEq(wommf.name(), STAGING_CONSTANTS_OMMF_MAINNET.wommf_name);
    assertEq(wommf.symbol(), STAGING_CONSTANTS_OMMF_MAINNET.wommf_symbol);
  }
}
