pragma solidity 0.8.16;
import "forge-tests/OUSG_BasicDeployment.t.sol";

contract Test_OUSGInstant_ETH is OUSG_BasicDeployment {
  /*//////////////////////////////////////////////////////////////
                        InstantMint Getter tests
  //////////////////////////////////////////////////////////////*/
  function test_ousgInstantManager_initialization() public {
    // Storage within OUSGInstantManager
    assertEq(ousgInstantManager.MINIMUM_OUSG_PRICE(), 105e18);
    assertEq(ousgInstantManager.FEE_GRANULARITY(), 1e4);
    assertEq(address(ousgInstantManager.usdc()), address(USDC));
    assertEq(address(ousgInstantManager.ousg()), OUSG_ADDRESS);
    assertEq(address(ousgInstantManager.rousg()), address(rOUSGToken));
    assertEq(address(ousgInstantManager.buidl()), address(BUIDL));
    assertEq(
      address(ousgInstantManager.buidlRedeemer()),
      address(mockBUIDLRedeemer)
    );
    assertEq(ousgInstantManager.decimalsMultiplier(), 1e12);
    assertEq(ousgInstantManager.usdcReceiver(), instantMintAssetManager);
    assertEq(
      address(ousgInstantManager.oracle()),
      address(oracleCheckHarnessOUSG)
    );
    assertEq(ousgInstantManager.feeReceiver(), feeRecipient);
    assertEq(ousgInstantManager.mintFee(), 0);
    assertEq(ousgInstantManager.redeemFee(), 0);
    assertEq(ousgInstantManager.minimumDepositAmount(), 100_000_000_000);
    assertEq(ousgInstantManager.minimumRedemptionAmount(), 50_000_000_000);
    assertEq(ousgInstantManager.mintPaused(), false);
    assertEq(ousgInstantManager.redeemPaused(), false);

    // Storage within RateLimiter
    assertEq(ousgInstantManager.resetInstantMintDuration(), 0);
    assertEq(ousgInstantManager.lastResetInstantMintTime(), block.timestamp);
    assertEq(ousgInstantManager.instantMintLimit(), 0);
    assertEq(ousgInstantManager.currentInstantMintAmount(), 0);
    assertEq(ousgInstantManager.resetInstantRedemptionDuration(), 0);
    assertEq(
      ousgInstantManager.lastResetInstantRedemptionTime(),
      block.timestamp
    );
    assertEq(ousgInstantManager.instantRedemptionLimit(), 0);
    assertEq(ousgInstantManager.currentInstantRedemptionAmount(), 0);
  }

  function test_ousgInstantManager_access_control_storage() public {
    // Storage within OUSGInstantManager
    bytes32[3] memory roles = [
      ousgInstantManager.DEFAULT_ADMIN_ROLE(),
      ousgInstantManager.PAUSER_ROLE(),
      ousgInstantManager.CONFIGURER_ROLE()
    ];

    for (uint256 i = 0; i < roles.length; i++) {
      assertEq(
        ousgInstantManager.hasRole(roles[i], address(OUSG_GUARDIAN)),
        true
      );
      assertEq(ousgInstantManager.getRoleMemberCount(roles[i]), 1);
    }
  }
}
