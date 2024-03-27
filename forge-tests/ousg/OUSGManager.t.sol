// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.16;

import "forge-tests/rwaHub/Minting.t.sol";
import "forge-tests/rwaHub/Redemption.t.sol";
import "forge-tests/rwaHub/Setters.t.sol";
import "forge-tests/rwaHub/NonStableInstantMinting.t.sol";
import "forge-tests/rwaHub/OffChainRedemption.t.sol";
import "forge-tests/helpers/events/OUSGManagerEvents.sol";
import "forge-tests/OUSG_BasicDeployment.t.sol";

contract Test_OUSG_Manager_ETH is
  OUSG_BasicDeployment,
  Test_RWAHub_Setters,
  Test_RWAHub_Minting,
  Test_RWAHub_Redemptions,
  OUSGManagerEvents,
  Test_OffChainRedemption_Manager
{
  bytes32[] redemption_ids;
  uint256[] price_ids;

  function setUp() public override {
    super.setUp();
    removeMintAndRedeemLimits();
    _setRWAHubOffChainRedemptions(address(ousgManager));
    vm.startPrank(managerAdmin);
    ousgManager.grantRole(ousgManager.REDEMPTION_PROVER_ROLE(), managerAdmin);
    vm.stopPrank();
  }

  function _initializeUsersArray()
    internal
    override(Test_RWAHub_Redemptions, Test_RWAHub_Minting)
  {
    _initializeOUSGUsersArray();
  }

  function _restrictUser(
    address user
  ) internal override(Test_RWAHub_Setters, Test_RWAHub_Minting) {
    _restrictOUSGUser(user);
  }

  function _expectOpinionatedRestrictionRevert()
    internal
    override(Test_RWAHub_Setters, Test_RWAHub_Minting)
  {
    vm.expectRevert(OUSGManager.KYCCheckFailed.selector);
  }

  /*//////////////////////////////////////////////////////////////
                        Add Redemption Proof Tests
  //////////////////////////////////////////////////////////////*/
  function test_addRedemptionProof() public {
    bytes32 redemption_id = keccak256(
      "0xfc1f23c0cd72a01e907f1bcea5330f73a3d4b45743ebc0f83ef7fec29489a590-123"
    );
    _addAddressToKYC(OUSG_KYC_REQUIREMENT_GROUP, address(managerAdmin));
    vm.prank(guardian);
    ousg.mint(alice, 111e18);
    // address(this) has the price update role.
    pricerOusg.addPrice(1e18, block.timestamp);

    // Alice "requests" a redemption by sending to ops multisig.
    vm.prank(alice);
    ousg.transfer(managerAdmin, 111e18);

    // Operators burn ousg and inform manager of redemption request
    vm.startPrank(managerAdmin);
    ousg.approve(address(ousgManager), 111e18);
    ousgManager.addRedemptionProof(
      redemption_id,
      alice,
      111e18,
      block.timestamp - 100
    );
    vm.stopPrank();

    assertEq(ousg.balanceOf(managerAdmin), 0);
    assertEq(ousg.balanceOf(alice), 0);
    (address client, uint256 amt, uint256 priceId) = ousgManager
      .redemptionIdToRedeemer(redemption_id);
    assertEq(client, alice);
    assertEq(amt, 111e18);
    assertEq(priceId, 0);
  }

  function test_addRedemptionProof_fail_already_added() public {
    bytes32 redemption_id = keccak256(
      "0xfc1f23c0cd72a01e907f1bcea5330f73a3d4b45743ebc0f83ef7fec29489a590-123"
    );
    _addAddressToKYC(OUSG_KYC_REQUIREMENT_GROUP, address(managerAdmin));
    vm.prank(guardian);
    ousg.mint(alice, 222e18);
    // address(this) has the price update role.
    pricerOusg.addPrice(1e18, block.timestamp);

    // Alice "requests" a redemption by sending to ops multisig.
    vm.prank(alice);
    ousg.transfer(managerAdmin, 222e18);

    // Operators burn ousg and inform manager of redemption request
    vm.startPrank(managerAdmin);
    ousg.approve(address(ousgManager), 222e18);
    ousgManager.addRedemptionProof(
      redemption_id,
      alice,
      111e18,
      block.timestamp - 100
    );
    vm.expectRevert(IRWAHub.RedemptionProofAlreadyExists.selector);
    ousgManager.addRedemptionProof(
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
    _addAddressToKYC(OUSG_KYC_REQUIREMENT_GROUP, address(managerAdmin));
    vm.prank(guardian);
    ousg.mint(alice, 222e18);
    // address(this) has the price update role.
    pricerOusg.addPrice(1e18, block.timestamp);

    // Alice "requests" a redemption by sending to ops multisig.
    vm.prank(alice);
    ousg.transfer(managerAdmin, 222e18);

    // Operators burn ousg and inform manager of redemption request
    vm.startPrank(managerAdmin);
    ousg.approve(address(ousgManager), 222e18);
    vm.expectRevert(IRWAHub.RedemptionTooSmall.selector);
    ousgManager.addRedemptionProof(
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
    _addAddressToKYC(OUSG_KYC_REQUIREMENT_GROUP, address(managerAdmin));
    _addAddressToKYC(OUSG_KYC_REQUIREMENT_GROUP, address(0));
    vm.prank(guardian);
    ousg.mint(alice, 222e18);
    // address(this) has the price update role.
    pricerOusg.addPrice(1e18, block.timestamp);

    // Alice "requests" a redemption by sending to ops multisig.
    vm.prank(alice);
    ousg.transfer(managerAdmin, 222e18);

    // Operators burn ousg and inform manager of redemption request
    vm.startPrank(managerAdmin);
    ousg.approve(address(ousgManager), 222e18);
    vm.expectRevert(IRWAHub.RedeemerNull.selector);
    ousgManager.addRedemptionProof(
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
    _addAddressToKYC(OUSG_KYC_REQUIREMENT_GROUP, address(managerAdmin));
    vm.prank(guardian);
    ousg.mint(alice, 111e18);
    // address(this) has the price update role.
    pricerOusg.addPrice(1e18, block.timestamp);

    // Alice "requests" a redemption by sending to ops multisig.
    vm.prank(alice);
    ousg.transfer(managerAdmin, 111e18);

    // Operators burn ousg and inform manager of redemption request
    vm.prank(managerAdmin);
    ousg.approve(address(ousgManager), 111e18);
    vm.expectRevert(
      _formatACRevert(address(this), ousgManager.REDEMPTION_PROVER_ROLE())
    );
    ousgManager.addRedemptionProof(
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
    _addAddressToKYC(OUSG_KYC_REQUIREMENT_GROUP, address(managerAdmin));
    vm.prank(guardian);
    ousg.mint(alice, 101e18);
    // address(this) has the price update role.
    pricerOusg.addPrice(1e18, block.timestamp);

    // Alice "requests" a redemption by sending to ops multisig.
    vm.prank(alice);
    ousg.transfer(managerAdmin, 101e18);

    // Operators setup redemption for servicing in contract
    vm.startPrank(managerAdmin);
    ousg.approve(address(ousgManager), 101e18);
    vm.expectEmit(true, true, true, true);
    emit RedemptionProofAdded(redemption_id, alice, 101e18, block.timestamp);
    ousgManager.addRedemptionProof(
      redemption_id,
      alice,
      101e18,
      block.timestamp
    );
    redemption_ids.push(redemption_id);
    price_ids.push(1);
    ousgManager.setPriceIdForRedemptions(redemption_ids, price_ids);
    vm.stopPrank();

    // Send USDC to redemptions multisig to service Alice.
    deal(address(USDC), ousgManager.assetSender(), 10_100e6);
    vm.prank(ousgManager.assetSender());
    USDC.approve(address(ousgManager), 10_100e6);
    ousgManager.claimRedemption(redemption_ids);
    assertEq(USDC.balanceOf(alice), 10_100e6);
    assertEq(ousg.balanceOf(alice), 0);
    assertEq(ousg.balanceOf(managerAdmin), 0);
  }
}
