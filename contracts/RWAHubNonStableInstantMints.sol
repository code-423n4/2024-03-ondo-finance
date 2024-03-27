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

import "contracts/RWAHubOffChainRedemptions.sol";
import "contracts/InstantMintTimeBasedRateLimiter.sol";
import "contracts/interfaces/IRWAHubNonStableInstantMint.sol";

abstract contract RWAHubNonStableInstantMints is
  RWAHubOffChainRedemptions,
  InstantMintTimeBasedRateLimiter,
  IRWAHubNonStableInstantMint
{
  using SafeERC20 for IERC20;

  // Fee collected when instant minting RWA-nonStable (in basis points)
  uint256 public instantMintFee = 10;

  // The % (in bps) of rwa to instantly give to the user
  uint256 public instantMintAmountBps = 9_000;

  // Flag whether instantMint is paused
  bool public instantMintPaused = true;
  bool public claimExcessPaused = true;

  // Address to manage instant mints/redeems
  address public instantMintAssetManager;

  // Mapping used to store the instantMint amount for a given deposit Id
  mapping(bytes32 => uint256) public depositIdToInstantMintAmount;

  constructor(
    address _collateral,
    address _rwa,
    address managerAdmin,
    address pauser,
    address _assetSender,
    address _feeRecipient,
    uint256 _minimumDepositAmount,
    uint256 _minimumRedemptionAmount,
    address _instantMintAssetManager
  )
    RWAHubOffChainRedemptions(
      _collateral,
      _rwa,
      managerAdmin,
      pauser,
      _assetSender,
      _feeRecipient,
      _minimumDepositAmount,
      _minimumRedemptionAmount
    )
    InstantMintTimeBasedRateLimiter(0, 0, 0, 0)
  {
    instantMintAssetManager = _instantMintAssetManager;
  }

  /*//////////////////////////////////////////////////////////////
                     Instant Mint Functions
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Function to allow for investors to instantly mint a fraction of
   *         their total deposited amount.
   *
   * @param amount The amount of collateral to `instantMint`
   *
   *
   * @dev The daily ∆ price for the rwa Asset must not exceed:
   *      10_000 - `instantMintAmountBps`
   *      eg: 10_000 - 9_000 -> 1_000 (in bps) -> 10% ∆ in price
   *      If this condition is violated there will be problems!
   */
  function instantMint(
    uint256 amount
  )
    external
    nonReentrant
    ifNotPaused(instantMintPaused)
    checkRestrictions(msg.sender)
  {
    if (amount < minimumDepositAmount) {
      revert DepositTooSmall();
    }

    // Calculate fees
    uint256 instantMintFeesInCollateral = _getInstantMintFees(amount);
    uint256 depositAmountAfterFees = amount - instantMintFeesInCollateral;

    // Transfer collateral
    collateral.safeTransferFrom(msg.sender, instantMintAssetManager, amount);

    // Calculate mint amount
    uint256 price = pricer.getLatestPrice();
    uint256 rwaGiven = _getInstantMintAmount(depositAmountAfterFees, price);

    // Check mint limit
    _checkAndUpdateInstantMintLimit(rwaGiven);

    bytes32 depositId = bytes32(subscriptionRequestCounter++);
    depositIdToDepositor[depositId] = Depositor(
      msg.sender,
      depositAmountAfterFees,
      0
    );

    depositIdToInstantMintAmount[depositId] = rwaGiven;

    rwa.mint(msg.sender, rwaGiven);

    emit InstantMint(
      msg.sender,
      amount,
      depositAmountAfterFees,
      instantMintFeesInCollateral,
      rwaGiven,
      price,
      depositId
    );
  }

  /**
   * @notice Function for users to claim their remain excess after their priceId
   *         has been set.
   *
   * @param instantMintIds The DepositIds corresponding to instant mint
   *                       requests
   *
   * @dev Function will revert if a deposit Id was not generated through
   *      `instantMint`
   */
  function claimExcess(
    bytes32[] calldata instantMintIds
  )
    external
    nonReentrant
    ifNotPaused(claimExcessPaused)
    checkRestrictions(msg.sender)
  {
    uint256 excessSize = instantMintIds.length;
    for (uint256 i; i < excessSize; ++i) {
      _claimExcess(instantMintIds[i]);
    }
  }

  /**
   * @notice Internal function used to claim excess for a given depositId
   *
   * @param instantMintId The depositId correspond to an instant mint
   *                      request
   */
  function _claimExcess(bytes32 instantMintId) internal virtual {
    // Get depositor info and instant mint amount
    Depositor memory depositor = depositIdToDepositor[instantMintId];
    uint256 rwaGiven = depositIdToInstantMintAmount[instantMintId];

    if (depositor.priceId == 0) {
      revert PriceIdNotSet();
    }
    if (rwaGiven == 0) {
      revert CannotClaimExcess();
    }

    // Get price and rwaOwed
    uint256 price = pricer.getPrice(depositor.priceId);
    uint256 rwaOwed = _getMintAmountForPrice(
      depositor.amountDepositedMinusFees,
      price
    );

    uint256 rwaDue = rwaOwed - rwaGiven;

    delete depositIdToDepositor[instantMintId];
    delete depositIdToInstantMintAmount[instantMintId];

    rwa.mint(depositor.user, rwaDue);

    emit ExcessMintClaimed(
      depositor.user,
      rwaOwed,
      rwaDue,
      depositor.amountDepositedMinusFees,
      price,
      instantMintId
    );
  }

  /*//////////////////////////////////////////////////////////////
                 Override base for new accounting
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Overriden function from rwaHub, checks that a depositId does not
   *         correspond to an instant mint
   *
   * @param depositIds Array for depositIds to claim
   */
  function claimMint(
    bytes32[] calldata depositIds
  ) external override nonReentrant ifNotPaused(subscriptionPaused) {
    uint256 depositsSize = depositIds.length;
    for (uint256 i; i < depositsSize; ++i) {
      if (depositIdToInstantMintAmount[depositIds[i]] != 0) {
        revert CannotClaimMint();
      }
      _claimMint(depositIds[i]);
    }
  }

  /*//////////////////////////////////////////////////////////////
                        Pause Utils
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Guarded function to pause instant mints
   */
  function pauseInstantMint() external onlyRole(PAUSER_ADMIN) {
    instantMintPaused = true;
    emit InstantMintPaused(msg.sender);
  }

  /**
   * @notice Guarded function to unpause instant mints
   */
  function unpauseInstantMint() external onlyRole(MANAGER_ADMIN) {
    instantMintPaused = false;
    emit InstantMintUnpaused(msg.sender);
  }

  /**
   * @notice Guarded function to pause claims of excess resulting from
   *         instant mints
   */
  function pauseClaimExcess() external onlyRole(PAUSER_ADMIN) {
    claimExcessPaused = true;
    emit ClaimExcessPaused(msg.sender);
  }

  /**
   * @notice Gurarded function to unpause claims of excess resulting from
   *         instant mints
   */
  function unpauseClaimExcess() external onlyRole(MANAGER_ADMIN) {
    claimExcessPaused = false;
    emit ClaimExcessUnpaused(msg.sender);
  }

  /*//////////////////////////////////////////////////////////////
                      Rate limiting utils
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Set the mintLimit constraint inside the TimeBasedRateLimiter
   *         base contract
   *
   * @param newMintLimit New limit that dictates how much RWA can be minted
   *                     in a specified duration
   *                     (in 18 decimals per the RWA contract)
   */
  function setInstantMintLimit(
    uint256 newMintLimit
  ) external onlyRole(MANAGER_ADMIN) {
    _setInstantMintLimit(newMintLimit);
  }

  /**
   * @notice Sets mintLimitDuration constraint inside the TimeBasedRateLimiter
   *         base contract
   *
   * @param newMintLimitDuration New limit that specifies the interval
   *                             (in seconds) in which only mintLimit RWA
   *                             can be minted within
   */
  function setInstantMintLimitDuration(
    uint256 newMintLimitDuration
  ) external onlyRole(MANAGER_ADMIN) {
    _setInstantMintLimitDuration(newMintLimitDuration);
  }

  /*//////////////////////////////////////////////////////////////
                           Admin Utils
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Admin function to overwrite entries in the `depositIdToInstantMintAmount`
   *         mapping
   *
   * @param depositId   The depositId of the entry we wish to overwrite
   * @param amountGiven The new amount of rwa instantly minted
   */
  function overwriteInstantMintAmountGiven(
    bytes32 depositId,
    uint256 amountGiven
  ) external onlyRole(MANAGER_ADMIN) {
    uint256 oldGiven = depositIdToInstantMintAmount[depositId];
    depositIdToInstantMintAmount[depositId] = amountGiven;
    emit InstantMintGivenOverriden(depositId, oldGiven, amountGiven);
  }

  /**
   * @notice Guarded function to set the `instantMintAssetManager`
   *
   * @param _instantMintAssetManager The address to update
   *                                 `instantMintAssetManager` to
   */
  function setInstantMintAssetManager(
    address _instantMintAssetManager
  ) external onlyRole(MANAGER_ADMIN) {
    address oldInstantMintAssetManager = instantMintAssetManager;
    instantMintAssetManager = _instantMintAssetManager;
    emit InstantMintAssetManagerSet(
      oldInstantMintAssetManager,
      instantMintAssetManager
    );
  }

  /**
   * @notice Sets the instant mint fee
   *
   * @param _instantMintFee new mint fee specified in basis points
   *
   * @dev `_instantMintFee` must not exceed 100% (or 10_000 bps)
   */
  function setInstantMintFee(
    uint256 _instantMintFee
  ) external onlyRole(MANAGER_ADMIN) {
    if (_instantMintFee > BPS_DENOMINATOR) {
      revert FeeTooLarge();
    }
    uint256 oldInstantMintFee = instantMintFee;
    instantMintFee = _instantMintFee;
    emit InstantMintFeeSet(oldInstantMintFee, _instantMintFee);
  }

  /**
   * @notice Sets the % (in bps) for the portion of a deposit amount
   *         that is to be instantly minted
   *
   * @dev This value really should not be above 90% -> 9_000 bps
   */
  function setInstantMintAmount(
    uint256 bpsToInstantMint
  ) external onlyRole(MANAGER_ADMIN) {
    if (bpsToInstantMint > BPS_DENOMINATOR) {
      revert FeeTooLarge();
    }
    uint256 oldInstantMintAmt = instantMintAmountBps;
    instantMintAmountBps = bpsToInstantMint;
    emit InstantMintAmountSet(oldInstantMintAmt, instantMintAmountBps);
  }

  /*//////////////////////////////////////////////////////////////
                        Calculation utils
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Internal function to get the fees corresponding to
   *          instantly minting
   */
  function _getInstantMintFees(
    uint256 collateralAmount
  ) internal view returns (uint256) {
    return (collateralAmount * instantMintFee) / BPS_DENOMINATOR;
  }

  /**
   * @notice Internal function to calculate the amount due given the latest price
   *         and the `instantMintAmountBps` (Fraction of deposits to instantly mint)
   */
  function _getInstantMintAmount(
    uint256 collateralAmountIn,
    uint256 price
  ) internal view returns (uint256 rwaInstantMint) {
    uint256 amountE36 = _scaleUp(collateralAmountIn) * 1e18;
    uint256 rwaOwedLatestRate = amountE36 / price;
    rwaInstantMint =
      (rwaOwedLatestRate * instantMintAmountBps) /
      BPS_DENOMINATOR;
  }
}
