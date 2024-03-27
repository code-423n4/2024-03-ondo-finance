// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "forge-tests/rwaHub/Minting.t.sol";
import "forge-tests/rwaHub/Redemption.t.sol";
import "forge-tests/rwaHub/Setters.t.sol";
import "forge-tests/rwaHub/InstantMinting.t.sol";
import "forge-tests/OMMF_BasicDeployment.sol";
import "forge-tests/rwaHub/OffChainRedemption.t.sol";

contract Test_OMMF_Manager is
  OMMF_BasicDeployment,
  Test_RWAHub_Redemptions,
  Test_RWAHub_Setters,
  Test_RWAHub_Minting,
  Test_RWAHub_InstantMinting,
  Test_OffChainRedemption_Manager
{
  bytes32[] redemption_ids;
  uint256[] price_ids;

  function setUp() public override {
    super.setUp();
    _setRwaHubInstantMint(address(ommfManager));
    _setRWAHubOffChainRedemptions(address(ommfManager));
    vm.startPrank(managerAdmin);
    ommfManager.grantRole(ommfManager.REDEMPTION_PROVER_ROLE(), managerAdmin);
    vm.stopPrank();
  }

  function _initializeUsersArray()
    internal
    override(Test_RWAHub_Redemptions, Test_RWAHub_Minting)
  {
    _initializeOMMFUsersArray();
  }

  function _restrictUser(
    address user
  ) internal override(Test_RWAHub_Setters, Test_RWAHub_Minting) {
    _restrictOMMFUser(user);
  }

  function _expectOpinionatedRestrictionRevert()
    internal
    override(Test_RWAHub_Setters, Test_RWAHub_Minting)
  {
    vm.expectRevert(OMMFManager.KYCCheckFailed.selector);
  }

  /*//////////////////////////////////////////////////////////////
                        Add Redemption Proof Tests
  //////////////////////////////////////////////////////////////*/
  function test_addRedemptionProof() public {
    bytes32 redemption_id = keccak256(
      "0xfc1f23c0cd72a01e907f1bcea5330f73a3d4b45743ebc0f83ef7fec29489a590-123"
    );
    _addAddressToKYC(OMMF_KYC_REQUIREMENT_GROUP, address(managerAdmin));
    vm.prank(guardian);
    ommf.mint(alice, 111e18);
    // address(this) has the price update role.
    pricerOmmf.addPrice(1e18, block.timestamp);

    // Alice "requests" a redemption by sending to ops multisig.
    vm.prank(alice);
    ommf.transfer(managerAdmin, 111e18);

    // Operators burn ommf and inform manager of redemption request
    vm.startPrank(managerAdmin);
    ommf.approve(address(ommfManager), 111e18);
    ommfManager.addRedemptionProof(
      redemption_id,
      alice,
      111e18,
      block.timestamp - 100
    );
    vm.stopPrank();

    assertEq(ommf.balanceOf(managerAdmin), 0);
    assertEq(ommf.balanceOf(alice), 0);
    (address client, uint256 amt, uint256 priceId) = ommfManager
      .redemptionIdToRedeemer(redemption_id);
    assertEq(client, alice);
    assertEq(amt, 111e18);
    assertEq(priceId, 0);
  }

  function test_addRedemptionProof_fail_already_added() public {
    bytes32 redemption_id = keccak256(
      "0xfc1f23c0cd72a01e907f1bcea5330f73a3d4b45743ebc0f83ef7fec29489a590-123"
    );
    _addAddressToKYC(OMMF_KYC_REQUIREMENT_GROUP, address(managerAdmin));
    vm.prank(guardian);
    ommf.mint(alice, 222e18);
    // address(this) has the price update role.
    pricerOmmf.addPrice(1e18, block.timestamp);

    // Alice "requests" a redemption by sending to ops multisig.
    vm.prank(alice);
    ommf.transfer(managerAdmin, 222e18);

    // Operators burn ommf and inform manager of redemption request
    vm.startPrank(managerAdmin);
    ommf.approve(address(ommfManager), 222e18);
    ommfManager.addRedemptionProof(
      redemption_id,
      alice,
      111e18,
      block.timestamp - 100
    );
    vm.expectRevert(IRWAHub.RedemptionProofAlreadyExists.selector);
    ommfManager.addRedemptionProof(
      redemption_id,
      alice,
      111e18,
      block.timestamp - 100
    );
    vm.stopPrank();
  }

  function test_addRedemptionProof_fail_burn_amount() public {
    bytes32 redemption_id = keccak256(
      "0xfc1f23c0cd72a01e907f1bcea5330f73a3d4b45743ebc0f83ef7fec29489a590-123"
    );
    _addAddressToKYC(OMMF_KYC_REQUIREMENT_GROUP, address(managerAdmin));
    vm.prank(guardian);
    ommf.mint(alice, 222e18);
    // address(this) has the price update role.
    pricerOmmf.addPrice(1e18, block.timestamp);

    // Alice "requests" a redemption by sending to ops multisig.
    vm.prank(alice);
    ommf.transfer(managerAdmin, 222e18);

    // Operators burn ommf and inform manager of redemption request
    vm.startPrank(managerAdmin);
    ommf.approve(address(ommfManager), 222e18);
    vm.expectRevert(IRWAHub.RedemptionTooSmall.selector);
    ommfManager.addRedemptionProof(
      redemption_id,
      alice,
      0,
      block.timestamp - 100
    );
    vm.stopPrank();
  }

  function test_addRedemptionProof_fail_invalid_user() public {
    bytes32 redemption_id = keccak256(
      "0xfc1f23c0cd72a01e907f1bcea5330f73a3d4b45743ebc0f83ef7fec29489a590-123"
    );
    _addAddressToKYC(OMMF_KYC_REQUIREMENT_GROUP, address(managerAdmin));
    _addAddressToKYC(OMMF_KYC_REQUIREMENT_GROUP, address(0));
    vm.prank(guardian);
    ommf.mint(alice, 222e18);
    // address(this) has the price update role.
    pricerOmmf.addPrice(1e18, block.timestamp);

    // Alice "requests" a redemption by sending to ops multisig.
    vm.prank(alice);
    ommf.transfer(managerAdmin, 222e18);

    // Operators burn ommf and inform manager of redemption request
    vm.startPrank(managerAdmin);
    ommf.approve(address(ommfManager), 222e18);
    vm.expectRevert(IRWAHub.RedeemerNull.selector);
    ommfManager.addRedemptionProof(
      redemption_id,
      address(0),
      222e18,
      block.timestamp - 100
    );
    vm.stopPrank();
  }

  function test_addRedemptionProof_fail_AC() public {
    bytes32 redemption_id = keccak256(
      "0xfc1f23c0cd72a01e907f1bcea5330f73a3d4b45743ebc0f83ef7fec29489a590-123"
    );
    _addAddressToKYC(OMMF_KYC_REQUIREMENT_GROUP, address(managerAdmin));
    vm.prank(guardian);
    ommf.mint(alice, 111e18);
    // address(this) has the price update role.
    pricerOmmf.addPrice(1e18, block.timestamp);

    // Alice "requests" a redemption by sending to ops multisig.
    vm.prank(alice);
    ommf.transfer(managerAdmin, 111e18);

    // Operators burn ommf and inform manager of redemption request
    vm.prank(managerAdmin);
    ommf.approve(address(ommfManager), 111e18);
    vm.expectRevert(
      _formatACRevert(address(this), ommfManager.REDEMPTION_PROVER_ROLE())
    );
    ommfManager.addRedemptionProof(
      redemption_id,
      alice,
      111e18,
      block.timestamp - 100
    );
  }

  function test_addRedemptionProof_full_lifecycle() public {
    bytes32 redemption_id = keccak256(
      "0xfc1f23c0cd72a01e907f1bcea5330f73a3d4b45743ebc0f83ef7fec29489a590-123"
    );
    _addAddressToKYC(OMMF_KYC_REQUIREMENT_GROUP, address(managerAdmin));
    vm.prank(guardian);
    ommf.mint(alice, 101e18);
    // address(this) has the price update role.
    pricerOmmf.addPrice(1e18, block.timestamp);

    // Alice "requests" a redemption by sending to ops multisig.
    vm.prank(alice);
    ommf.transfer(managerAdmin, 101e18);

    // Operators setup redemption for servicing in contract
    vm.startPrank(managerAdmin);
    ommf.approve(address(ommfManager), 101e18);
    vm.expectEmit(true, true, true, true);
    emit RedemptionProofAdded(redemption_id, alice, 101e18, block.timestamp);
    ommfManager.addRedemptionProof(
      redemption_id,
      alice,
      101e18,
      block.timestamp
    );
    redemption_ids.push(redemption_id);
    price_ids.push(1);
    ommfManager.setPriceIdForRedemptions(redemption_ids, price_ids);
    vm.stopPrank();

    // Send USDC to redemptions multisig to service Alice.
    deal(address(USDC), assetSender, 101e6);
    vm.prank(assetSender);
    USDC.approve(address(ommfManager), 101e6);
    ommfManager.claimRedemption(redemption_ids);
    assertEq(USDC.balanceOf(alice), 101e6);
    assertEq(ommf.balanceOf(alice), 0);
    assertEq(ommf.balanceOf(managerAdmin), 0);
  }

  /*//////////////////////////////////////////////////////////////
                        Claim WOMMF Tests
  //////////////////////////////////////////////////////////////*/

  function test_claim_and_wrap() public {
    test_fuzz_claim_wrapped_ommf(1_000_000e6);
  }

  function test_claim_and_wrap_alt() public initOtherHolders {
    _seedWithCollateral(alice, 400_000e6);

    vm.startPrank(alice);
    USDC.approve(address(ommfManager), 400_000e6);
    ommfManager.requestSubscription(400_000e6);
    vm.stopPrank();

    depositIds.push(FIRST_DEPOSIT_ID);
    priceIds.push(1);

    vm.prank(managerAdmin);
    ommfManager.setPriceIdForDeposits(depositIds, priceIds);

    vm.expectEmit(true, true, true, true);
    emit WrappedMintCompleted(
      alice,
      FIRST_DEPOSIT_ID,
      400_000e18,
      200_000e18,
      400_000e6,
      1e18
    );
    ommfManager.claimMint_wOMMF(depositIds);

    assertEq(wommf.balanceOf(alice), 200_000e18);
    assertEq(wommf.getOMMFbywOMMF(wommf.balanceOf(alice)), 400_000e18);
  }

  function test_fuzz_claim_wrapped_ommf(uint256 amount) public {
    vm.assume(amount > ommfManager.minimumDepositAmount());
    vm.assume(amount < 5_000_000e6);

    _seedWithCollateral(alice, amount);

    vm.startPrank(alice);
    USDC.approve(address(ommfManager), amount);
    ommfManager.requestSubscription(amount);
    vm.stopPrank();

    depositIds.push(FIRST_DEPOSIT_ID);
    priceIds.push(1);
    vm.prank(managerAdmin);
    ommfManager.setPriceIdForDeposits(depositIds, priceIds);

    vm.expectEmit(true, true, true, true);
    emit WrappedMintCompleted(
      alice,
      FIRST_DEPOSIT_ID,
      amount * 1e12,
      amount * 1e12,
      amount,
      1e18
    );
    ommfManager.claimMint_wOMMF(depositIds);

    // Assert that the alice received their OMMF
    assertEq(amount * 1e12, wommf.balanceOf(alice));
    // Assert that the corresponding CM entry was removed
    (address client, uint256 amt, uint256 priceId) = ommfManager
      .depositIdToDepositor(FIRST_DEPOSIT_ID);
    assertEq(client, address(0));
    assertEq(amt, 0);
    assertEq(priceId, 0);
  }

  /*//////////////////////////////////////////////////////////////
                     Redemption WOMMF Tests
  //////////////////////////////////////////////////////////////*/

  function test_requestRedemption_with_wrapped_token() public {
    test_claim_and_wrap();

    uint256 wommfBalBefore = wommf.balanceOf(alice);

    vm.startPrank(alice);
    wommf.approve(address(ommfManager), 500_000e18);
    ommfManager.requestRedemption_wOMMF(500_000e18);
    vm.stopPrank();

    (address client, uint256 amt, uint256 priceId) = ommfManager
      .redemptionIdToRedeemer(FIRST_REDEMPTION_ID);

    assertEq(client, alice);
    assertEq(amt, 500_000e18);
    assertEq(priceId, 0);
    assertEq(wommfBalBefore - 500_000e18, wommf.balanceOf(alice));
  }

  function test_completeRedemption_with_wrapped_token()
    public
    preRedeemState(500_000e6)
  {
    test_requestRedemption_with_wrapped_token();
    vm.prank(managerAdmin);
    redemptionIds.push(FIRST_REDEMPTION_ID);
    ommfManager.setPriceIdForRedemptions(redemptionIds, priceIds);

    vm.prank(alice);
    ommfManager.claimRedemption(redemptionIds);

    // Assert that the alice receives USDC
    assertEq(USDC.balanceOf(alice), 500_000e6);

    // Assert that the entry in CM no longer exists
    (address client, uint256 amt, uint256 priceId) = ommfManager
      .redemptionIdToRedeemer(FIRST_REDEMPTION_ID);
    assertEq(client, address(0));
    assertEq(amt, 0);
    assertEq(priceId, 0);
  }

  function test_fuzz_requestRedemption_wrapped(uint256 amount) public {
    test_fuzz_claim_wrapped_ommf(amount);
    redeemState(amount);

    uint256 wommfBalBefore = wommf.balanceOf(alice);
    uint256 impliedOmmfBal = wommf.getOMMFbywOMMF(wommf.balanceOf(alice));

    vm.startPrank(alice);
    wommf.approve(address(ommfManager), wommfBalBefore);

    vm.expectEmit(true, true, true, true);
    emit WrappedRedemptionRequested(
      alice,
      FIRST_REDEMPTION_ID,
      impliedOmmfBal,
      wommfBalBefore
    );
    ommfManager.requestRedemption_wOMMF(wommfBalBefore);
    vm.stopPrank();

    redemptionIds.push(FIRST_REDEMPTION_ID);
    vm.prank(managerAdmin);
    ommfManager.setPriceIdForRedemptions(redemptionIds, priceIds);

    ommfManager.claimRedemption(redemptionIds);

    assertEq(USDC.balanceOf(alice), amount);
    assertEq(wommf.balanceOf(alice), 0);
    assertEq(ommf.balanceOf(alice), 0);
  }

  /*//////////////////////////////////////////////////////////////
                            KYC Tests
  //////////////////////////////////////////////////////////////*/

  function test_setKYCRequirementGroup() public {
    vm.expectEmit(true, true, true, true);
    emit KYCRequirementGroupSet(2, 1);
    vm.startPrank(managerAdmin);
    ommfManager.setKYCRequirementGroup(1);
    uint256 res = ommfManager.kycRequirementGroup();
    assertEq(res, 1);
  }

  function test_setKYCRegistry() public {
    vm.expectEmit(true, true, true, true);
    emit KYCRegistrySet(address(registry), address(1));
    vm.prank(managerAdmin);
    ommfManager.setKYCRegistry(address(1));
    address res = address(ommfManager.kycRegistry());
    assertEq(res, address(1));
  }

  function test_setKYCRequirementGroup_unauthorized() public {
    vm.expectRevert(_formatACRevert(badActor, ommfManager.MANAGER_ADMIN()));
    vm.startPrank(badActor);
    ommfManager.setKYCRequirementGroup(1);
  }

  function test_setKYCRegistry_unauthorized() public {
    vm.expectRevert(_formatACRevert(badActor, ommfManager.MANAGER_ADMIN()));
    vm.startPrank(badActor);
    ommfManager.setKYCRegistry(address(badActor));
  }

  /*//////////////////////////////////////////////////////////////
                              Utils
  //////////////////////////////////////////////////////////////*/

  function credit_other_users() public {
    _mintRWAToUser(users[4], 300e18);
    _mintRWAToUser(users[5], 300e18);
    _rebase(1200e18);
  }

  function redeemState(uint256 amt) public {
    address sender = address(ommfManager.assetSender());
    deal(address(USDC), sender, amt);
    uint256 toSend = USDC.balanceOf(address(ommfManager.assetSender()));
    vm.prank(address(ommfManager.assetSender()));
    USDC.approve(address(ommfManager), toSend);
  }

  modifier preRedeemState(uint256 redeemAmt) {
    redeemState(redeemAmt);
    _;
  }

  modifier initOtherHolders() {
    _initializeOMMFUsersArray();
    credit_other_users();
    _;
  }
}
