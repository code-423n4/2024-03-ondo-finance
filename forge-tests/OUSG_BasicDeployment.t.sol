pragma solidity 0.8.16;

import "forge-tests/BaseTestRunner.sol";
import "forge-tests/helpers/events/OMMFManagerEvents.sol";
import "forge-tests/helpers/events/OMMFEvents.sol";
import "forge-tests/helpers/events/KYCRegistryClientEvents.sol";
import "contracts/external/openzeppelin/contracts/proxy/ProxyAdmin.sol";
import "contracts/ousg/ousg.sol";
import "contracts/Proxy.sol";
import "contracts/ousg/ousgManager.sol";
import "contracts/interfaces/IRWALike.sol";
import "contracts/ousg/ousgInstantManager.sol";
import "contracts/ousg/rOUSGFactory.sol";
import "forge-tests/helpers/MockBUIDLRedeemer.sol";

abstract contract OUSG_BasicDeployment is
  BaseTestRunner,
  KYCRegistryClientEvents
{
  address constant OUSG_ADDRESS = 0x1B19C19393e2d034D8Ff31ff34c81252FcBbee92;
  address constant OUSG_GUARDIAN = 0xAEd4caF2E535D964165B4392342F71bac77e8367;
  uint256 constant OUSG_KYC_REQUIREMENT_GROUP = 1;

  DeltaCheckHarness oracleCheckHarnessOUSG;
  PricerWithOracle pricerOusg;
  OUSGManager ousgManager;
  IRWALike ousg;

  ROUSG rOUSGToken; // Proxy with abi of implementation
  TokenProxy rOUSGProxy;
  ProxyAdmin rOUSGProxyAdmin;
  ROUSG rOUSGImplementation;

  OUSGInstantManager ousgInstantManager;
  BUIDLRedeemerMock mockBUIDLRedeemer;

  function setUp() public virtual {
    // Use on chain KYC Registry
    _getDeployedRegistry();
    _addAddressToKYC(OUSG_KYC_REQUIREMENT_GROUP, guardian);
    _addAddressToKYC(OUSG_KYC_REQUIREMENT_GROUP, address(this));
    // Use on chain OUSG Token Contract
    _getDeployedOUSG();
    // Deploy new OUSG Manager, rOUSG, and OUSG Instant Manager
    _deployOUSGManager();
    _deployROUSG();
    console.log("ROUSG deployed", address(rOUSGToken));
    _deployOUSGInstantManager();
    // Add users to KYC, set up pricer, and set up rwa hub,
    _postDeployActions();
  }

  function _getDeployedRegistry() internal {
    registry = KYCRegistry(PROD_REGISTRY);
    vm.prank(OUSG_GUARDIAN);
    registry.grantRole(bytes32(0), address(this));
    bytes32 groupRole = registry.kycGroupRoles(1);
    vm.prank(OUSG_GUARDIAN);
    registry.grantRole(groupRole, address(this));
  }

  function _getDeployedOUSG() internal {
    ousg = IRWALike(OUSG_ADDRESS);
  }

  function _deployPricer() internal {
    oracleCheckHarnessOUSG = new DeltaCheckHarness();
    oracleCheckHarnessOUSG.setPrice(100e18);
    pricerOusg = new PricerWithOracle(
      address(guardian), // Admin
      address(this), // Pricer
      address(oracleCheckHarnessOUSG)
    );
    oracleCheckHarnessOUSG.setOwner(address(pricerOusg));
  }

  function _deployOUSGManager() internal {
    _deployPricer();
    _deployOUSGManagerWithToken(OUSG_ADDRESS);

    vm.startPrank(managerAdmin);
    ousgManager.grantRole(ousgManager.RELAYER_ROLE(), relayer);
    vm.stopPrank();
  }

  function _deployROUSG() internal {
    ROUSGFactory factory = new ROUSGFactory(OUSG_GUARDIAN);
    vm.startPrank(OUSG_GUARDIAN);
    (address proxy, address proxyAdmin, address implementation) = factory
      .deployRebasingOUSG(
        address(registry),
        OUSG_KYC_REQUIREMENT_GROUP,
        OUSG_ADDRESS,
        address(oracleCheckHarnessOUSG)
      );
    rOUSGToken = ROUSG(proxy);
    rOUSGProxy = TokenProxy(payable(proxy));
    rOUSGProxyAdmin = ProxyAdmin(proxyAdmin);
    rOUSGImplementation = ROUSG(implementation);
    rOUSGToken.grantRole(rOUSGToken.PAUSER_ROLE(), pauser);
    _addAddressToKYC(OUSG_KYC_REQUIREMENT_GROUP, address(address(rOUSGToken)));
    vm.stopPrank();
  }

  function _deployOUSGInstantManager() internal {
    mockBUIDLRedeemer = new BUIDLRedeemerMock(address(BUIDL));
    IOUSGInstantManager.RateLimiterConfig memory rateLimiterConfig = IOUSGInstantManager
      .RateLimiterConfig(
        0, // _instantMintResetDuration
        0, // _instantRedemptionResetDuration
        0, // _instantMintLimit
        0 // _instantRedemptionLimit
      );

    ousgInstantManager = new OUSGInstantManager(
      OUSG_GUARDIAN, // defaultAdmin
      address(USDC), //  _usdc
      instantMintAssetManager, // _usdcReceiver
      feeRecipient, // _feeReceiver
      address(oracleCheckHarnessOUSG), //  _oracle
      OUSG_ADDRESS, //  _ousg
      address(rOUSGToken), // _rOUSG
      address(BUIDL), // _buidl
      address(mockBUIDLRedeemer), // buidlRedeemer
      rateLimiterConfig
    );

    vm.startPrank(OUSG_GUARDIAN);
    console.log("OUSG Instant Manager deployed", address(ousgInstantManager));
    CashKYCSenderReceiver ousgProxied = CashKYCSenderReceiver(address(ousg));
    ousgProxied.grantRole(
      ousgProxied.MINTER_ROLE(),
      address(ousgInstantManager)
    );

    _addAddressToKYC(OUSG_KYC_REQUIREMENT_GROUP, address(ousgInstantManager));
    vm.stopPrank();
  }

  function _deployOUSGManagerWithToken(address token) internal {
    ousgManager = new OUSGManager(
      address(USDC),
      token,
      managerAdmin,
      pauser,
      assetSender,
      feeRecipient,
      10_000e6,
      100e18,
      address(registry),
      OUSG_KYC_REQUIREMENT_GROUP
    );

    vm.startPrank(OUSG_GUARDIAN);
    AccessControlEnumerable(address(ousg)).grantRole(
      keccak256("MINTER_ROLE"),
      address(ousgManager)
    );
    AccessControlEnumerable(address(ousg)).grantRole(
      keccak256("MINTER_ROLE"),
      address(guardian)
    );
    vm.stopPrank();

    vm.startPrank(managerAdmin);
    ousgManager.grantRole(
      ousgManager.PRICE_ID_SETTER_ROLE(),
      address(managerAdmin)
    );
    ousgManager.setPricer(address(pricerOusg));
    vm.stopPrank();
  }

  function _postDeployActions() internal {
    _addAddressToKYC(OUSG_KYC_REQUIREMENT_GROUP, alice);
    _addAddressToKYC(OUSG_KYC_REQUIREMENT_GROUP, bob);
    _addAddressToKYC(OUSG_KYC_REQUIREMENT_GROUP, charlie);
    _addAddressToKYC(OUSG_KYC_REQUIREMENT_GROUP, address(ousgManager));

    // Set general variables for rwa tests
    _setRwaHub(address(ousgManager));
    _setRwa(address(ousg));
    _setPricer(address(pricerOusg));
    _setOracleCheckHarness(address(oracleCheckHarnessOUSG));

    // Labels
    vm.label(guardian, "guardian");
    vm.label(address(USDC), "USDC");
  }

  function _initializeOUSGUsersArray() internal {
    for (uint256 i = 0; i < 300; i++) {
      address user = address(new User());
      users.push(user);
      _addAddressToKYC(OUSG_KYC_REQUIREMENT_GROUP, user);
    }
  }

  function removeMintAndRedeemLimits() internal {
    vm.startPrank(managerAdmin);
    rwaHub.setMinimumDepositAmount(100e6);
    rwaHub.setMinimumRedemptionAmount(100e18);
    vm.stopPrank();
  }

  function _restrictOUSGUser(address user) internal {
    _removeAddressFromKYC(OUSG_KYC_REQUIREMENT_GROUP, user);
  }
}
