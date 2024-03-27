pragma solidity 0.8.16;

import {PROD_CONSTANTS_OMMF_MAINNET} from "forge-tests/postDeploymentConfig/prod_constants.t.sol";
import "forge-tests/OMMF_BasicDeployment.sol";
import "contracts/ommf/ommf_token/OMMFRebaseSetter.sol";

contract ASSERT_FORK_OMMF is PROD_CONSTANTS_OMMF_MAINNET, OMMF_BasicDeployment {
  /**
   * @notice INPUT ADDRESSES TO CHECK CONFIG OF BELOW
   *
   * @dev FILL THIS OUT POST PROD DEPLOYMENT
   * OMMF DEPLOYMENT: 10/30/2023
   * Passing on block: 18470803
   */
  address ommf_to_check = 0xE00e79c24B9Bd388fbf1c4599694C2cf18166102;
  address ommfManager_to_check = 0x1d01be0296B99aAdeE94116e285CDb2C40bE7929;
  address wommf_to_check = 0x59E119C783BC6EEF1045f254b841dc4dE94DC6fD;

  bytes32 impl_slot =
    bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
  bytes32 admin_slot = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);
  OMMFRebaseSetter rebaseSetter;

  function setUp() public override {
    ommf = OMMF(ommf_to_check);
    registry = KYCRegistry(address(ommf.kycRegistry()));
    wommf = WOMMF(wommf_to_check);
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
      PROD_CONSTANTS_OMMF_MAINNET.ommfhub_default_admin
    );
    assertEq(ommfManager.getRoleMemberCount(ommfManager.MANAGER_ADMIN()), 1);
    assertEq(
      ommfManager.getRoleMember(ommfManager.MANAGER_ADMIN(), 0),
      PROD_CONSTANTS_OMMF_MAINNET.ommfhub_manager_admin
    );
    assertEq(ommfManager.getRoleMemberCount(ommfManager.PAUSER_ADMIN()), 1);
    assertEq(
      ommfManager.getRoleMember(ommfManager.PAUSER_ADMIN(), 0),
      PROD_CONSTANTS_OMMF_MAINNET.ommfhub_pauser_admin
    );

    assertEq(
      ommfManager.getRoleMemberCount(ommfManager.PRICE_ID_SETTER_ROLE()),
      1
    );
    assertEq(
      ommfManager.getRoleMember(ommfManager.PRICE_ID_SETTER_ROLE(), 0),
      PROD_CONSTANTS_OMMF_MAINNET.ommfhub_price_id_setter_role
    );

    assertEq(ommfManager.getRoleMemberCount(ommfManager.RELAYER_ROLE()), 1);
    assertEq(
      ommfManager.getRoleMember(ommfManager.RELAYER_ROLE(), 0),
      PROD_CONSTANTS_OMMF_MAINNET.ommfhub_relayer_role
    );

    assertEq(
      ommfManager.getRoleMemberCount(ommfManager.REDEMPTION_PROVER_ROLE()),
      1
    );
    assertEq(
      ommfManager.getRoleMember(ommfManager.REDEMPTION_PROVER_ROLE(), 0),
      PROD_CONSTANTS_OMMF_MAINNET.ommfhub_redemption_prover_role
    );

    // ASSERT OMMF Manager config
    assertEq(
      ommfManager.assetSender(),
      PROD_CONSTANTS_OMMF_MAINNET.asset_sender
    );
    assertEq(
      ommfManager.assetRecipient(),
      PROD_CONSTANTS_OMMF_MAINNET.asset_recipient
    );
    assertEq(
      ommfManager.feeRecipient(),
      PROD_CONSTANTS_OMMF_MAINNET.fee_recipient
    );
    assertEq(
      address(ommfManager.rwa()),
      PROD_CONSTANTS_OMMF_MAINNET.ommf_asset
    );
    assertEq(
      address(ommfManager.collateral()),
      PROD_CONSTANTS_OMMF_MAINNET.collateral
    );
    assertEq(
      address(ommfManager.pricer()),
      PROD_CONSTANTS_OMMF_MAINNET.ommf_pricer
    );
    assertEq(
      ommfManager.minimumDepositAmount(),
      PROD_CONSTANTS_OMMF_MAINNET.min_deposit_amt
    );
    assertEq(
      ommfManager.minimumRedemptionAmount(),
      PROD_CONSTANTS_OMMF_MAINNET.min_redeem_amt
    );
    assertEq(ommfManager.mintFee(), PROD_CONSTANTS_OMMF_MAINNET.mint_fee);
    assertEq(
      ommfManager.redemptionFee(),
      PROD_CONSTANTS_OMMF_MAINNET.redeem_fee
    );
    assertEq(
      ommfManager.BPS_DENOMINATOR(),
      PROD_CONSTANTS_OMMF_MAINNET.bps_denominator
    );
    assertEq(
      address(ommfManager.kycRegistry()),
      PROD_CONSTANTS_OMMF_MAINNET.kyc_registry
    );
    assertEq(
      ommfManager.decimalsMultiplier(),
      PROD_CONSTANTS_OMMF_MAINNET.decimals_multiplier
    );
    // Check that instant minting/redeeming functionality is paused
    assertEq(ommfManager.instantMintPaused(), true);
    assertEq(ommfManager.instantRedemptionPaused(), true);
    assertEq(ommfManager.offChainRedemptionPaused(), false);
  }

  function test_fork_assert_ommf_token_proxy() public {
    // Assert Proxy Setup
    bytes32 impl = vm.load(address(ommf), impl_slot);
    bytes32 admin = vm.load(address(ommf), admin_slot);
    assertEq(impl, PROD_CONSTANTS_OMMF_MAINNET.ommf_impl_bytes);
    assertEq(admin, PROD_CONSTANTS_OMMF_MAINNET.ommf_proxy_admin_bytes);

    // Assert that the owner of the proxy admin is correct
    assertEq(
      ProxyAdmin(address(uint160(uint256(admin)))).owner(),
      PROD_CONSTANTS_OMMF_MAINNET.ommf_pa_owner
    );
    assertEq(ommf.getRoleMemberCount(ommf.DEFAULT_ADMIN_ROLE()), 1);
    assertEq(
      ommf.getRoleMember(ommf.DEFAULT_ADMIN_ROLE(), 0),
      PROD_CONSTANTS_OMMF_MAINNET.ommf_default_admin
    );
    assertEq(ommf.getRoleMemberCount(ommf.MINTER_ROLE()), 1);
    assertEq(
      ommf.getRoleMember(ommf.MINTER_ROLE(), 0),
      PROD_CONSTANTS_OMMF_MAINNET.ommf_minter_role
    );

    assertEq(ommf.getRoleMemberCount(ommf.PAUSER_ROLE()), 1);
    assertEq(
      ommf.getRoleMember(ommf.PAUSER_ROLE(), 0),
      PROD_CONSTANTS_OMMF_MAINNET.ommf_default_admin
    );

    /// @notice BURNER_ROLE - Not granted by default
    // assertEq(ommf.getRoleMemberCount(ommf.BURNER_ROLE()), 1);
    // assertEq(
    //   ommf.getRoleMember(ommf.BURNER_ROLE(), 0),
    //   PROD_CONSTANTS_OMMF.ommf_pauser_role
    // );

    // ASSERT Token config
    assertEq(ommf.paused(), PROD_CONSTANTS_OMMF_MAINNET.paused);
    assertEq(ommf.decimals(), PROD_CONSTANTS_OMMF_MAINNET.decimals);
    assertEq(ommf.name(), PROD_CONSTANTS_OMMF_MAINNET.name);
    assertEq(ommf.symbol(), PROD_CONSTANTS_OMMF_MAINNET.symbol);

    assertEq(
      ommf.oracle(),
      PROD_CONSTANTS_OMMF_MAINNET.ommf_rebase_setter_role
    );
    assertEq(
      address(ommf.kycRegistry()),
      PROD_CONSTANTS_OMMF_MAINNET.kyc_registry
    );
    assertEq(
      ommf.kycRequirementGroup(),
      PROD_CONSTANTS_OMMF_MAINNET.kyc_requirement_group
    );
  }

  function test_fork_assert_pricer_ommf() public {
    assertEq(pricerOmmf.getRoleMemberCount(pricerOmmf.DEFAULT_ADMIN_ROLE()), 1);
    assertEq(
      pricerOmmf.getRoleMember(pricerOmmf.DEFAULT_ADMIN_ROLE(), 0),
      PROD_CONSTANTS_OMMF_MAINNET.pricer_default_admin
    );
    assertEq(pricerOmmf.getRoleMemberCount(pricerOmmf.PRICE_UPDATE_ROLE()), 1);
    assertEq(
      pricerOmmf.getRoleMember(pricerOmmf.PRICE_UPDATE_ROLE(), 0),
      PROD_CONSTANTS_OMMF_MAINNET.pricer_price_update_role
    );
  }

  function test_fork_assert_rebaseSetter() public {
    assertEq(
      rebaseSetter.getRoleMemberCount(rebaseSetter.DEFAULT_ADMIN_ROLE()),
      1
    );
    assertEq(
      rebaseSetter.getRoleMember(rebaseSetter.DEFAULT_ADMIN_ROLE(), 0),
      PROD_CONSTANTS_OMMF_MAINNET.rebaseSetter_admin_role
    );
    assertEq(rebaseSetter.getRoleMemberCount(rebaseSetter.SETTER_ROLE()), 1);
    assertEq(
      rebaseSetter.getRoleMember(rebaseSetter.SETTER_ROLE(), 0),
      PROD_CONSTANTS_OMMF_MAINNET.rebaseSetter_setter_role
    );
  }

  function test_fork_assert_wommf_token_proxy() public {
    // Assert Proxy Setup
    bytes32 impl = vm.load(address(wommf), impl_slot);
    bytes32 admin = vm.load(address(wommf), admin_slot);
    assertEq(impl, PROD_CONSTANTS_OMMF_MAINNET.wommf_impl_bytes);
    assertEq(admin, PROD_CONSTANTS_OMMF_MAINNET.wommf_proxy_admin_bytes);

    // Assert that the owner of the proxy admin is correct
    assertEq(
      ProxyAdmin(address(uint160(uint256(admin)))).owner(),
      PROD_CONSTANTS_OMMF_MAINNET.wommf_pa_owner
    );

    assertEq(wommf.getRoleMemberCount(wommf.DEFAULT_ADMIN_ROLE()), 1);
    assertEq(
      wommf.getRoleMember(wommf.DEFAULT_ADMIN_ROLE(), 0),
      PROD_CONSTANTS_OMMF_MAINNET.wommf_default_admin
    );
    assertEq(wommf.getRoleMemberCount(wommf.MINTER_ROLE()), 1);
    assertEq(
      ommf.getRoleMember(ommf.MINTER_ROLE(), 0),
      PROD_CONSTANTS_OMMF_MAINNET.wommf_minter_role
    );

    assertEq(wommf.getRoleMemberCount(ommf.PAUSER_ROLE()), 2);
    assertEq(
      wommf.getRoleMember(wommf.PAUSER_ROLE(), 0),
      PROD_CONSTANTS_OMMF_MAINNET.wommf_default_admin
    );
    assertEq(
      wommf.getRoleMember(wommf.PAUSER_ROLE(), 1),
      PROD_CONSTANTS_OMMF_MAINNET.wommf_pauser_role
    );

    /// @notice BURNER_ROLE - Not granted by default
    // assertEq(wommf.getRoleMemberCount(wommf.BURNER_ROLE()), 1);
    // assertEq(
    //   wommf.getRoleMember(ommf.BURNER_ROLE(), 0),
    //   PROD_CONSTANTS_OMMF_MAINNET.wommf_pauser_role
    // );

    // ASSERT Token config
    assertEq(wommf.paused(), PROD_CONSTANTS_OMMF_MAINNET.paused);
    assertEq(wommf.decimals(), PROD_CONSTANTS_OMMF_MAINNET.wommf_decimals);
    assertEq(wommf.name(), PROD_CONSTANTS_OMMF_MAINNET.wommf_name);
    assertEq(wommf.symbol(), PROD_CONSTANTS_OMMF_MAINNET.wommf_symbol);
  }
}
