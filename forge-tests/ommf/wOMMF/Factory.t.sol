pragma solidity 0.8.16;

import "forge-tests/OMMF_BasicDeployment.sol";

contract Test_WOMMF_Factory is OMMF_BasicDeployment {
  WOMMFFactory factory;

  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
  bytes32 public constant DEFAULT_ADMIN_ROLE = bytes32(0);
  bytes32 public constant BURNER_ROLE = keccak256("BURN_ROLE");
  bytes32 public constant KYC_CONFIGURER_ROLE =
    keccak256("KYC_CONFIGURER_ROLE");

  function setUp() public override {
    _deployKYCRegistry();
    factory = new WOMMFFactory(guardian);
  }

  event WOMMFDeployed(
    address proxy,
    address proxyAdmin,
    address implementation,
    string name,
    string ticker
  );

  function test_deploy_wommf_fail_access_control() public {
    vm.expectRevert(bytes("WOMMFFactory: You are not the Guardian"));
    factory.deployWOMMF("Test", "t", address(1), address(1), 1);
  }

  function test_deploy_wommf_access_control_setup() public {
    vm.prank(guardian);
    vm.expectEmit(true, true, true, false);
    emit WOMMFDeployed(
      address(0x0),
      address(0x0),
      address(0x0),
      "Wrapped OMMF",
      "WOMMF"
    );
    (address proxy, address admin, address impl) = factory.deployWOMMF(
      "Wrapped OMMF",
      "WOMMF",
      address(ommf),
      address(registry),
      1
    );

    WOMMF wommf = WOMMF(proxy);
    ProxyAdmin proxyAdmin = ProxyAdmin(admin);
    assertEq(proxyAdmin.owner(), guardian);

    vm.startPrank(admin);
    TokenProxy iProxy = TokenProxy(payable(proxy));
    assertEq(iProxy.admin(), admin);
    assertEq(iProxy.implementation(), impl);
    vm.stopPrank();

    assertEq(wommf.totalSupply(), 0);

    assertEq(wommf.getRoleAdmin(MINTER_ROLE), DEFAULT_ADMIN_ROLE);
    assertEq(wommf.getRoleAdmin(PAUSER_ROLE), DEFAULT_ADMIN_ROLE);
    assertEq(wommf.getRoleAdmin(BURNER_ROLE), DEFAULT_ADMIN_ROLE);
    assertEq(wommf.getRoleAdmin(KYC_CONFIGURER_ROLE), DEFAULT_ADMIN_ROLE);

    assertEq(wommf.getRoleMemberCount(DEFAULT_ADMIN_ROLE), 1);
    assertEq(wommf.getRoleMemberCount(PAUSER_ROLE), 1);
    assertEq(wommf.getRoleMemberCount(BURNER_ROLE), 1);
    assertEq(wommf.getRoleMemberCount(KYC_CONFIGURER_ROLE), 1);

    assertEq(wommf.getRoleMember(PAUSER_ROLE, 0), guardian);
    assertEq(wommf.getRoleMember(DEFAULT_ADMIN_ROLE, 0), guardian);
    assertEq(wommf.getRoleMember(KYC_CONFIGURER_ROLE, 0), guardian);
    assertEq(wommf.getRoleMember(BURNER_ROLE, 0), guardian);

    // Minter role must be granted at a later stage.
    assertEq(wommf.getRoleMemberCount(MINTER_ROLE), 0);
  }
}
