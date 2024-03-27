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

import "contracts/external/openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "contracts/interfaces/IRestrictedUSDYMetadata.sol";

contract RestrictedUSDYMetadata is
  IRestrictedUSDYMetadata,
  AccessControlEnumerable
{
  bytes32 public constant RESTRICTED_LIST_SETTER =
    keccak256("RESTRICTED_LIST_SETTER");

  mapping(address => Restriction[]) public restrictionList;

  constructor(address admin, address restrictedListSetter) {
    _grantRole(DEFAULT_ADMIN_ROLE, admin);
    _grantRole(RESTRICTED_LIST_SETTER, restrictedListSetter);
  }

  function addToRestrictedList(
    address account,
    Restriction calldata restriction
  ) external onlyRole(RESTRICTED_LIST_SETTER) {
    if (restriction.restrictedUntil < block.timestamp)
      revert RestrictedUntilInPast();
    if (restriction.amountRestricted == 0) revert RestrictionAmountZero();

    restrictionList[account].push(restriction);
    emit RestrictionAdded(account, restriction);
  }

  function removeFromRestrictedList(
    address account,
    Restriction calldata restriction
  ) external onlyRole(RESTRICTED_LIST_SETTER) {
    if (restrictionList[account].length == 0) revert RestrictionNotFound();

    Restriction memory restrictionRemoved;

    for (uint256 i = 0; i < restrictionList[account].length; i++) {
      if (
        restrictionList[account][i].depositId == restriction.depositId &&
        restrictionList[account][i].amountRestricted ==
        restriction.amountRestricted &&
        restrictionList[account][i].restrictedUntil ==
        restriction.restrictedUntil
      ) {
        restrictionRemoved = restrictionList[account][i];
        restrictionList[account][i] = restrictionList[account][
          restrictionList[account].length - 1
        ];
        restrictionList[account].pop();
        break;
      }
    }

    if (restrictionRemoved.amountRestricted == 0) {
      revert RestrictionNotFound();
    } else {
      emit RestrictionRemoved(account, restrictionRemoved);
    }
  }

  function getRestrictedAmount(
    address account
  ) external view returns (uint256) {
    uint256 restrictedAmount = 0;
    for (uint256 i = 0; i < restrictionList[account].length; i++) {
      if (restrictionList[account][i].restrictedUntil > block.timestamp) {
        restrictedAmount += restrictionList[account][i].amountRestricted;
      }
    }
    return restrictedAmount;
  }
}
