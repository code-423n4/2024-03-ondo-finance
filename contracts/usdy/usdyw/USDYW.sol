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

import "contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/ERC20PresetMinterPauserUpgradeable.sol";
import "contracts/usdy/blocklist/BlocklistClientUpgradeable.sol";

contract USDYW is
  ERC20PresetMinterPauserUpgradeable,
  BlocklistClientUpgradeable
{
  bytes32 public constant LIST_CONFIGURER_ROLE =
    keccak256("LIST_CONFIGURER_ROLE");
  bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");
  // Used to hold current terms and condition information
  string public currentTerms;

  /// @custom:oz-upgrades-unsafe-allow constructor
  constructor() {
    _disableInitializers();
  }

  function initialize(
    string memory name,
    string memory symbol,
    address blocklist
  ) public initializer {
    __ERC20PresetMinterPauser_init(name, symbol);
    __BlocklistClientInitializable_init(blocklist);
  }

  /**
   * @notice Sets the blocklist address
   *
   * @param blocklist New blocklist address
   */
  function setBlocklist(
    address blocklist
  ) external override onlyRole(LIST_CONFIGURER_ROLE) {
    _setBlocklist(blocklist);
  }

  /***
   * @notice Sets the current Terms for USDY
   *
   * @param newTerm New Terms to update to
   */
  function updateTerm(
    string calldata newTerm
  ) external onlyRole(LIST_CONFIGURER_ROLE) {
    string memory oldTerms = currentTerms;
    currentTerms = newTerm;
    emit TermsUpdated(oldTerms, currentTerms);
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal override {
    super._beforeTokenTransfer(from, to, amount);
    // Check constraints when `transferFrom` is called to facilitate
    // a transfer between two parties that are not `from` or `to`.
    if (from != msg.sender && to != msg.sender) {
      require(!_isBlocked(msg.sender), "USDY: 'sender' address blocked");
    }

    if (from != address(0)) {
      // If not minting
      require(!_isBlocked(from), "USDY: 'from' address blocked");
    }

    if (to != address(0)) {
      // If not burning
      require(!_isBlocked(to), "USDY: 'to' address blocked");
    }
  }

  /**
   * @notice Burns a specific amount of tokens
   *
   * @param from The account whose tokens will be burned
   * @param amount The amount of token to be burned
   *
   * @dev This function can be considered an admin-burn and is only callable
   *      by an address with the `BURNER_ROLE`
   */
  function burn(address from, uint256 amount) external onlyRole(BURNER_ROLE) {
    _burn(from, amount);
  }

  /**
   * @notice Event emitted when the terms are update
   *
   * @param oldTerms The old terms being updated
   * @param newTerms The new terms we are updating to
   */
  event TermsUpdated(string oldTerms, string newTerms);
}
