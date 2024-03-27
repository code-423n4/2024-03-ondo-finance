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

interface IRestrictedUSDYMetadata {
  // Struct to contain the deposit information for a given depositId
  struct Restriction {
    bytes32 depositId;
    uint256 amountRestricted;
    uint256 restrictedUntil;
  }

  /// @notice Adds a restriction to the restricted list for the given account
  function addToRestrictedList(
    address account,
    Restriction calldata restriction
  ) external;

  /// @notice Attempts to remove a restriction from the restricted list for the given account
  function removeFromRestrictedList(
    address account,
    Restriction calldata restriction
  ) external;

  /// @notice Error for when caller attempts to add a restriction with a restrictedUntil in the past
  error RestrictedUntilInPast();

  /// @notice Error for when caller attempts to add a restriction with an amount of 0
  error RestrictionAmountZero();

  /// @notice Error for when caller attempts to remove a non-existent restriction
  error RestrictionNotFound();

  /**
   * @notice Event emitted when addresses are added to the restricted list
   *
   * @param account The address that was added to the restricted list
   * @param restriction The restriction placed on the address
   */
  event RestrictionAdded(address account, Restriction restriction);

  /**
   * @notice Event emitted when addresses are removed from the blocklist
   *
   * @param account The address that was removed from the restricted list
   * @param restriction The restriction removed from the address
   */
  event RestrictionRemoved(address account, Restriction restriction);
}
