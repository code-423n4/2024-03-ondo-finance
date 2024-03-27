pragma solidity 0.8.16;
import "forge-tests/OUSG_BasicDeployment.t.sol";

contract Test_OUSGInstant_Setters_ETH is OUSG_BasicDeployment {
  /*//////////////////////////////////////////////////////////////
                        InstantMint Setter AC Tests
  //////////////////////////////////////////////////////////////*/
  function test_setMintLimit_fail_AC() public {
    vm.expectRevert(
      _formatACRevert(badActor, ousgInstantManager.CONFIGURER_ROLE())
    );
    vm.startPrank(badActor);
    ousgInstantManager.setInstantMintLimit(1e18);
  }

  function test_setRedeemLimit_fail_AC() public {
    vm.expectRevert(
      _formatACRevert(badActor, ousgInstantManager.CONFIGURER_ROLE())
    );
    vm.startPrank(badActor);
    ousgInstantManager.setInstantRedemptionLimit(1e18);
  }

  function test_setMintLimitDuration_fail_AC() public {
    vm.expectRevert(
      _formatACRevert(badActor, ousgInstantManager.CONFIGURER_ROLE())
    );
    vm.startPrank(badActor);
    ousgInstantManager.setInstantMintLimitDuration(1e18);
  }

  function test_setRedeemLimitDuration_fail_AC() public {
    vm.expectRevert(
      _formatACRevert(badActor, ousgInstantManager.CONFIGURER_ROLE())
    );
    vm.startPrank(badActor);
    ousgInstantManager.setInstantRedemptionLimitDuration(1e18);
  }

  function test_setMinimumRedemptionAmount_fail_AC() public {
    vm.expectRevert(
      _formatACRevert(badActor, ousgInstantManager.CONFIGURER_ROLE())
    );
    vm.startPrank(badActor);
    ousgInstantManager.setMinimumRedemptionAmount(1e18);
  }

  function test_setMinimumDepositAmount_fail_AC() public {
    vm.expectRevert(
      _formatACRevert(badActor, ousgInstantManager.CONFIGURER_ROLE())
    );
    vm.startPrank(badActor);
    ousgInstantManager.setMinimumDepositAmount(1e18);
  }

  function test_setMintFee_fail_AC() public {
    vm.expectRevert(
      _formatACRevert(badActor, ousgInstantManager.CONFIGURER_ROLE())
    );
    vm.startPrank(badActor);
    ousgInstantManager.setMintFee(10_000);
  }

  function test_setRedemptionFee_fail_AC() public {
    vm.expectRevert(
      _formatACRevert(badActor, ousgInstantManager.CONFIGURER_ROLE())
    );
    vm.startPrank(badActor);
    ousgInstantManager.setRedeemFee(10_000);
  }

  function test_setOracle_fail_AC() public {
    vm.expectRevert(
      _formatACRevert(badActor, ousgInstantManager.DEFAULT_ADMIN_ROLE())
    );
    vm.startPrank(badActor);
    ousgInstantManager.setOracle(address(badActor));
  }

  function test_setFeeReceiver_fail_AC() public {
    vm.expectRevert(
      _formatACRevert(badActor, ousgInstantManager.DEFAULT_ADMIN_ROLE())
    );
    vm.prank(badActor);
    ousgInstantManager.setFeeReceiver(address(badActor));
  }

  function test_pauseMint_fail_AC() public {
    vm.expectRevert(
      _formatACRevert(badActor, ousgInstantManager.PAUSER_ROLE())
    );
    vm.startPrank(badActor);
    ousgInstantManager.pauseMint();
  }

  function test_pauseRedemption_fail_AC() public {
    vm.expectRevert(
      _formatACRevert(badActor, ousgInstantManager.PAUSER_ROLE())
    );
    vm.startPrank(badActor);
    ousgInstantManager.pauseRedeem();
  }

  function test_unpauseSubscription_fail_AC() public {
    vm.expectRevert(
      _formatACRevert(badActor, ousgInstantManager.DEFAULT_ADMIN_ROLE())
    );
    vm.startPrank(badActor);
    ousgInstantManager.unpauseMint();
  }

  function test_unpauseRedemption_fail_AC() public {
    vm.expectRevert(
      _formatACRevert(badActor, ousgInstantManager.DEFAULT_ADMIN_ROLE())
    );
    vm.startPrank(badActor);
    ousgInstantManager.unpauseRedeem();
  }
}
