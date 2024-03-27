import "forge-tests/helpers/DSTestPlus.sol";
import "forge-tests/helpers/DSTestPlus.sol";

contract BUIDLHelper is DSTestPlus {
  address public constant USDC_POOL_BUIDL =
    0x13e003a57432062e4EdA204F687bE80139AD622f;
  // inferred from https://etherscan.io/tx/0x77a4d9b7ddd5558a304e2f085c420f3af03215cdb570388fe1676249d5568ebc#eventlog &
  // https://etherscan.io/tx/0xf723727e0a6e779d20581c19c2c7d78354b24d744ce3acbca23ac6242a054fb4
  address public constant BUIDL_REDEEMER =
    0x31D3F59Ad4aAC0eeE2247c65EBE8Bf6E9E470a53;
  address public constant BUIDL_REGISTRY_SERVICE =
    0x0Dac900f26DE70336f2320F7CcEDeE70fF6A1a5B;
  address public constant BUIDL_PERMISSIONED_REGISTRY_SETTER =
    0x008075B22bEc05C7D0fb789e3420b76056D76cab;

  // Owned by Ondo ILP
  address public constant BUIDL_WHALE =
    0x72Be8C14B7564f7a61ba2f6B7E50D18DC1D4B63D;
  // BUIDL investor ID for Ondo ILP
  string public constant BUIDL_WHALE_INVESTOR_ID =
    "f89dc1c39955493888fde24ae3cec5cf";

  function _whitelistBUIDLWallet(address toWhitelist) internal {
    IBUIDLRegistryService registry = IBUIDLRegistryService(
      BUIDL_REGISTRY_SERVICE
    );
    vm.startPrank(BUIDL_PERMISSIONED_REGISTRY_SETTER);
    registry.addWallet(address(toWhitelist), BUIDL_WHALE_INVESTOR_ID);
    vm.stopPrank();
  }
}

// https://github.com/securitize-io/DSTokenInterfaces/blob/master/contracts/dsprotocol/registry/DSRegistryServiceInterface.sol
interface IBUIDLRegistryService {
  function isInvestor(string memory _id) external view returns (bool);

  function isWallet(address _address) external view returns (bool);

  function addWallet(
    address _address,
    string memory _id
  ) external returns (bool);
}
