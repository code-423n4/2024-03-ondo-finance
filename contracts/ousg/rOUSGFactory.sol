/**SPDX-License-Identifier: BUSL-1.1

      ▄▄█████████▄
   ╓██▀└ ,╓▄▄▄, '▀██▄
  ██▀ ▄██▀▀╙╙▀▀██▄ └██µ           ,,       ,,      ,     ,,,            ,,,
 ██ ,██¬ ▄████▄  ▀█▄ ╙█▄      ▄███▀▀███▄   ███▄    ██  ███▀▀▀███▄    ▄███▀▀███,
██  ██ ╒█▀'   ╙█▌ ╙█▌ ██     ▐██      ███  █████,  ██  ██▌    └██▌  ██▌     └██▌
██ ▐█▌ ██      ╟█  █▌ ╟█     ██▌      ▐██  ██ └███ ██  ██▌     ╟██ j██       ╟██
╟█  ██ ╙██    ▄█▀ ▐█▌ ██     ╙██      ██▌  ██   ╙████  ██▌    ▄██▀  ██▌     ,██▀
 ██ "██, ╙▀▀███████████⌐      ╙████████▀   ██     ╙██  ███████▀▀     ╙███████▀`
  ██▄ ╙▀██▄▄▄▄▄,,,                ¬─                                    '─¬
   ╙▀██▄ '╙╙╙▀▀▀▀▀▀▀▀
      ╙▀▀██████R⌐

 */
pragma solidity 0.8.16;

// Proxy admin contract used in OZ upgrades plugin
import "contracts/external/openzeppelin/contracts/proxy/ProxyAdmin.sol";
import "contracts/Proxy.sol";
import "contracts/ousg/rOUSG.sol";
import "contracts/interfaces/IMulticall.sol";

/**
 * @title ROUSGFactory
 * @author Ondo Finance
 * @notice This contract serves as a Factory for the upgradable rOUSG token contract.
 *         Upon calling `deployRebasingOUSG` the `guardian` address (set in constructor) will
 *         deploy the following:
 *         1) rOUSG - The implementation contract, ERC20 contract with the initializer disabled
 *         2) ProxyAdmin - OZ ProxyAdmin contract, used to upgrade the proxy instance.
 *                         @notice Owner is set to `guardian` address.
 *         3) TransparentUpgradeableProxy - OZ, proxy contract. Admin is set to `address(proxyAdmin)`.
 *                                          `_logic' is set to `address(rOUSG)`.
 * @notice `guardian` address in constructor is a msig.
 */
contract ROUSGFactory is IMulticall {
  bytes32 public constant DEFAULT_ADMIN_ROLE = bytes32(0);

  address internal immutable guardian;
  ROUSG public rOUSGImplementation;
  ProxyAdmin public rOUSGProxyAdmin;
  TokenProxy public rOUSGProxy;

  bool public initialized = false;

  constructor(address _guardian) {
    guardian = _guardian;
  }

  /**
   * @dev This function will deploy an upgradable instance of rOUSG
   *
   * @param kycRegistry      The address of the KYC Registry
   * @param requirementGroup The requirement group of the KYC Registry
   * @param ousg             The address of OUSG
   * @param oracle           The address of the OUSG price oracle
   *
   * @return address The address of the proxy contract.
   * @return address The address of the proxyAdmin contract.
   * @return address The address of the implementation contract.
   *
   * @notice
   *         1) Will grant DEFAULT_ADMIN, PAUSER_ROLE, BURNER_ROLE, and CONFIGURER_ROLE to `guardian`
   *            address, as specified in rOUSG constructor.
   *         2) Will transfer ownership of the proxyAdmin to guardian
   *            address.
   *
   */
  function deployRebasingOUSG(
    address kycRegistry,
    uint256 requirementGroup,
    address ousg,
    address oracle
  ) external onlyGuardian returns (address, address, address) {
    require(!initialized, "ROUSGFactory: rOUSG already deployed");
    rOUSGImplementation = new ROUSG();
    rOUSGProxyAdmin = new ProxyAdmin();
    rOUSGProxy = new TokenProxy(
      address(rOUSGImplementation),
      address(rOUSGProxyAdmin),
      ""
    );
    ROUSG rOUSGProxied = ROUSG(address(rOUSGProxy));
    rOUSGProxied.initialize(
      kycRegistry,
      requirementGroup,
      ousg,
      guardian,
      oracle
    );

    rOUSGProxyAdmin.transferOwnership(guardian);
    assert(rOUSGProxyAdmin.owner() == guardian);
    initialized = true;
    emit rOUSGDeployed(
      address(rOUSGProxy),
      address(rOUSGProxyAdmin),
      address(rOUSGImplementation),
      rOUSGProxied.name(),
      rOUSGProxied.symbol()
    );
    return (
      address(rOUSGProxy),
      address(rOUSGProxyAdmin),
      address(rOUSGImplementation)
    );
  }

  /**
   * @notice Allows for arbitrary batched calls
   *
   * @dev All external calls made through this function will
   *      msg.sender == contract address
   *
   * @param exCallData Struct consisting of
   *       1) target - contract to call
   *       2) data - data to call target with
   *       3) value - eth value to call target with
   */
  function multiexcall(
    ExCallData[] calldata exCallData
  ) external payable override onlyGuardian returns (bytes[] memory results) {
    results = new bytes[](exCallData.length);
    for (uint256 i = 0; i < exCallData.length; ++i) {
      (bool success, bytes memory ret) = address(exCallData[i].target).call{
        value: exCallData[i].value
      }(exCallData[i].data);
      require(success, "Call Failed");
      results[i] = ret;
    }
  }

  /**
   * @dev Event emitted when upgradable rOUSG is deployed
   *
   * @param proxy             The address for the proxy contract
   * @param proxyAdmin        The address for the proxy admin contract
   * @param implementation    The address for the implementation contract
   */
  event rOUSGDeployed(
    address proxy,
    address proxyAdmin,
    address implementation,
    string name,
    string ticker
  );

  modifier onlyGuardian() {
    require(msg.sender == guardian, "ROUSGFactory: You are not the Guardian");
    _;
  }
}
