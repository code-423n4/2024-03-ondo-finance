pragma solidity 0.8.16;

import "forge-tests/BaseTestRunner.sol";
import "forge-tests/helpers/events/OMMFManagerEvents.sol";
import "forge-tests/helpers/events/OMMFEvents.sol";
import "forge-tests/helpers/events/KYCRegistryClientEvents.sol";
import "contracts/external/openzeppelin/contracts/proxy/ProxyAdmin.sol";
import "contracts/ommf/ommf_token/ommf.sol";
import "contracts/ommf/ommf_token/ommf_factory.sol";
import "contracts/ommf/wrappedOMMF/wOMMF_factory.sol";
import "contracts/ommf/wrappedOMMF/wOMMF.sol";
import "contracts/Proxy.sol";
import "contracts/ommf/ommfManager.sol";
import "contracts/Pricer.sol";

abstract contract OMMF_BasicDeployment is
  BaseTestRunner,
  OMMFManagerEvents,
  KYCRegistryClientEvents,
  OMMFEvents,
  loadChainEnv
{
  // Oracle address that calls `handleOracleReport` on OMMF
  address oracle;

  // KYC Registry
  uint256 public constant OMMF_KYC_REQUIREMENT_GROUP = 2;

  // OMMF Contract Array
  OMMF ommf; // Proxy with abi of implementation
  TokenProxy ommfProxy;
  ProxyAdmin ommfProxyAdmin;
  OMMF ommfImplementation;
  OMMFFactory ommfFactory;

  // WOMMF Contract Array
  WOMMF wommf; // Proxy with abi of implementation
  TokenProxy wommfProxy;
  ProxyAdmin wommfProxyAdmin;
  WOMMF wommfImplementation;
  WOMMFFactory wommfFactory;

  // OMMF Manager Contracts
  OMMFManager ommfManager;
  Pricer pricerOmmf;

  function setUp() public virtual {
    loadEnv();
    // Deploy registry and KYC privileged addresses
    _deployKYCRegistry();
    _addAddressToKYC(OMMF_KYC_REQUIREMENT_GROUP, guardian);
    _addAddressToKYC(OMMF_KYC_REQUIREMENT_GROUP, address(this));
    oracle = guardian;
    _deployOMMF();
    _deployWOMMF(address(ommf));
    _setOracle(oracle);
    _deployOMMFManager();
    _postDeployActions();
  }

  function _deployOMMF() internal {
    ommfFactory = new OMMFFactory(guardian);
    vm.prank(guardian);
    // Using group 2 since OUSG is group 1 on mainnet
    (address proxy, address proxyAdmin, address implementation) = ommfFactory
      .deployOMMF(address(registry), OMMF_KYC_REQUIREMENT_GROUP);
    ommf = OMMF(proxy);
    ommfProxy = TokenProxy(payable(proxy));
    ommfProxyAdmin = ProxyAdmin(proxyAdmin);
    ommfImplementation = OMMF(implementation);
    vm.prank(guardian);
    ommf.grantRole(keccak256("MINTER_ROLE"), guardian);
  }

  function _deployWOMMF(address ommfAddress) internal {
    wommfFactory = new WOMMFFactory(guardian);
    vm.prank(guardian);
    (address proxy, address proxyAdmin, address implementation) = wommfFactory
      .deployWOMMF(
        "Wrapped OMMF",
        "WOMMF",
        ommfAddress,
        address(registry),
        OMMF_KYC_REQUIREMENT_GROUP
      );
    wommf = WOMMF(proxy);
    wommfProxy = TokenProxy(payable(proxy));
    wommfProxyAdmin = ProxyAdmin(proxyAdmin);
    wommfImplementation = WOMMF(implementation);
    _addAddressToKYC(OMMF_KYC_REQUIREMENT_GROUP, address(wommf));
  }

  function _setOracle(address _oracle) internal {
    vm.prank(guardian);
    ommf.setOracle(_oracle);
  }

  function _deployOMMFManagerWithToken(address token) internal {
    ommfManager = new OMMFManager(
      address(USDC),
      token,
      managerAdmin,
      pauser,
      assetSender,
      feeRecipient,
      100e6, // minimum deposit amount
      100e18, // minimum redemption amount
      instantMintAssetManager,
      address(registry),
      OMMF_KYC_REQUIREMENT_GROUP,
      address(wommf)
    );

    // Grant the ommfManager the OMMF minter role
    vm.startPrank(guardian);
    ommf.grantRole(ommf.MINTER_ROLE(), address(ommfManager));
    vm.stopPrank();

    // Initialize pricer inside rwaHub
    vm.startPrank(managerAdmin);
    ommfManager.grantRole(ommfManager.PRICE_ID_SETTER_ROLE(), managerAdmin);
    ommfManager.grantRole(ommfManager.RELAYER_ROLE(), managerAdmin);
    ommfManager.setPricer(address(pricerOmmf));
    vm.stopPrank();
  }

  function _deployPricer() internal {
    pricerOmmf = new Pricer(
      guardian, // Admin
      address(this) // price setter
    );
    pricerOmmf.addPrice(1e18, block.timestamp);
  }

  function _deployOMMFManager() internal {
    _deployPricer();
    _deployOMMFManagerWithToken(address(ommf));

    vm.startPrank(managerAdmin);
    ommfManager.setPricer(address(pricerOmmf));
    ommfManager.grantRole(ommfManager.RELAYER_ROLE(), relayer);
    vm.stopPrank();
  }

  /*//////////////////////////////////////////////////////////////
                             Helpers
  //////////////////////////////////////////////////////////////*/

  function _postDeployActions() internal {
    _addAddressToKYC(OMMF_KYC_REQUIREMENT_GROUP, alice);
    _addAddressToKYC(OMMF_KYC_REQUIREMENT_GROUP, bob);
    _addAddressToKYC(OMMF_KYC_REQUIREMENT_GROUP, charlie);
    _addAddressToKYC(OMMF_KYC_REQUIREMENT_GROUP, address(ommfManager));

    // Set general variables for rwa tests
    _setRwaHub(address(ommfManager));
    _setRwa(address(ommf));
    _setPricer(address(pricerOmmf));

    // Labels
    vm.label(guardian, "guardian");
    vm.label(address(USDC), "USDC");
  }

  function _rebase(uint256 potAmount) internal {
    vm.prank(oracle);
    ommf.handleOracleReport(potAmount);
  }

  function _initializeOMMFUsersArray() internal {
    for (uint256 i = 0; i < 300; i++) {
      address user = address(new User());
      users.push(user);
      _addAddressToKYC(OMMF_KYC_REQUIREMENT_GROUP, user);
    }
  }

  function _restrictOMMFUser(address user) internal {
    _removeAddressFromKYC(OMMF_KYC_REQUIREMENT_GROUP, user);
  }
}
