# Report


## Gas Optimizations


| |Issue|Instances|
|-|:-|:-:|
| [GAS-1](#GAS-1) | Don't use `_msgSender()` if not supporting EIP-2771 | 1 |
| [GAS-2](#GAS-2) | `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings) | 1 |
| [GAS-3](#GAS-3) | Use assembly to check for `address(0)` | 22 |
| [GAS-4](#GAS-4) | `array[index] += amount` is cheaper than `array[index] = array[index] + amount` (or related variants) | 2 |
| [GAS-5](#GAS-5) | Using bools for storage incurs overhead | 3 |
| [GAS-6](#GAS-6) | Cache array length outside of loop | 2 |
| [GAS-7](#GAS-7) | State variables should be cached in stack variables rather than re-reading them from storage | 10 |
| [GAS-8](#GAS-8) | Use calldata instead of memory for function arguments that do not get mutated | 2 |
| [GAS-9](#GAS-9) | For Operations that will not overflow, you could use unchecked | 68 |
| [GAS-10](#GAS-10) | Use Custom Errors instead of Revert Strings to save Gas | 25 |
| [GAS-11](#GAS-11) | Avoid contract existence checks by using low level calls | 4 |
| [GAS-12](#GAS-12) | State variables only set in the constructor should be declared `immutable` | 6 |
| [GAS-13](#GAS-13) | Functions guaranteed to revert when called by normal users can be marked `payable` | 8 |
| [GAS-14](#GAS-14) | Using `private` rather than `public` for constants, saves gas | 13 |
| [GAS-15](#GAS-15) | Increments/decrements can be unchecked in for-loops | 2 |
| [GAS-16](#GAS-16) | Use != 0 instead of > 0 for unsigned integer comparison | 6 |
### <a name="GAS-1"></a>[GAS-1] Don't use `_msgSender()` if not supporting EIP-2771
Use `msg.sender` if the code does not implement [EIP-2771 trusted forwarder](https://eips.ethereum.org/EIPS/eip-2771) support

*Instances (1)*:
```solidity
File: contracts/ousg/ousg.sol

70:       _getKYCStatus(_msgSender()),

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousg.sol)

### <a name="GAS-2"></a>[GAS-2] `a = a + b` is more gas effective than `a += b` for state variables (excluding arrays and mappings)
This saves **16 gas per instance.**

*Instances (1)*:
```solidity
File: contracts/ousg/rOUSG.sol

537:     totalShares += _sharesAmount;

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="GAS-3"></a>[GAS-3] Use assembly to check for `address(0)`
*Saves 6 gas per instance*

*Instances (22)*:
```solidity
File: contracts/ousg/ousg.sol

95: 

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousg.sol)

```solidity
File: contracts/ousg/ousgInstantManager.sol

181:     require(_buidl != address(0), "OUSGInstantManager: BUIDL cannot be 0x0");

183:       address(_buidlRedeemer) != address(0),

187:       IERC20Metadata(_ousg).decimals() == IERC20Metadata(_rousg).decimals(),

189:     );

192:       "OUSGInstantManager: USDC decimals must be equal to BUIDL decimals"

194:     usdc = IERC20(_usdc);

196:     feeReceiver = _feeReceiver;

199:     rousg = ROUSG(_rousg);

308:     ousgAmountOut = _getMintAmount(usdcAmountAfterFee, ousgPrice);

427:       // amount of USDC needed is over minBUIDLRedeemAmount, do a BUIDL redemption

670:     investorBasedRateLimiter = IInvestorBasedRateLimiter(

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/ousgManager.sol

121:   ) external onlyRole(MANAGER_ADMIN) {

128:   ) public virtual override onlyRole(PRICE_ID_SETTER_ROLE) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

498:    * - `_sender` must hold at least `_sharesAmount` shares.

499:    * - the contract must not be paused.

524:    * Requirements:

527:    * - the contract must not be paused.

554:   function _burnShares(

580:    * - when `from` is zero, `amount` tokens will be minted for `to`.

619:    * @notice Admin burn function to burn rOUSG tokens from any account

621:    * @param _amount  The amount of rOUSG tokens to burn

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="GAS-4"></a>[GAS-4] `array[index] += amount` is cheaper than `array[index] = array[index] + amount` (or related variants)
When updating a value in an array with arithmetic, using `array[index] += amount` is cheaper than `array[index] = array[index] + amount`.

This is because you avoid an additional `mload` when the array is stored in memory, and an `sload` when the array is stored in storage.

This can be applied for any arithmetic operation including `+=`, `-=`,`/=`,`*=`,`^=`,`&=`, `%=`, `<<=`,`>>=`, and `>>>=`.

This optimization can be particularly significant if the pattern occurs during a loop.

*Saves 28 gas for a storage array, 38 for a memory array*

*Instances (2)*:
```solidity
File: contracts/ousg/rOUSG.sol

539:     shares[_recipient] = shares[_recipient] + _sharesAmount;

558:     require(_account != address(0), "BURN_FROM_THE_ZERO_ADDRESS");

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="GAS-5"></a>[GAS-5] Using bools for storage incurs overhead
Use uint256(1) and uint256(2) for true/false to avoid a Gwarmaccess (100 gas), and to avoid Gsset (20000 gas) when changing from ‘false’ to ‘true’, after having been ‘true’ in the past. See [source](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/58f635312aa21f947cae5f8578638a85aa2519f5/contracts/security/ReentrancyGuard.sol#L23-L27).

*Instances (3)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

113:   bool public mintPaused;

116:   bool public redeemPaused;

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSGFactory.sol

45:   bool public initialized = false;

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)

### <a name="GAS-6"></a>[GAS-6] Cache array length outside of loop
If not cached, the solidity compiler will always read the length of the array during each iteration. That is, if it is a storage array, this is an extra sload operation (100 additional extra gas for each iteration except for the first) and if it is a memory array, this is an extra mload operation (3 additional gas for each iteration except for the first).

*Instances (2)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

804:     for (uint256 i = 0; i < exCallData.length; ++i) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSGFactory.sol

125:     for (uint256 i = 0; i < exCallData.length; ++i) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)

### <a name="GAS-7"></a>[GAS-7] State variables should be cached in stack variables rather than re-reading them from storage
The instances below point to the second+ access of a state variable within a function. Caching of a state variable replaces each Gwarmaccess (100 gas) with a much cheaper stack read. Other less obvious fixes/optimizations include having local memory caches of state variable structs, or having local caches of state variable contracts/addresses.

*Saves 100 gas per instance*

*Instances (10)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

346:       "OUSGInstantManager::redeem: Insufficient allowance"

458:   function _redeemBUIDL(uint256 buidlAmountToRedeem) internal {

468:       "OUSGInstantManager::_redeemBUIDL: BUIDL:USDC not 1:1"

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSGFactory.sol

117:    *       1) target - contract to call

121:   function multiexcall(

122:     ExCallData[] calldata exCallData

123:   ) external payable override onlyGuardian returns (bytes[] memory results) {

124:     results = new bytes[](exCallData.length);

125:     for (uint256 i = 0; i < exCallData.length; ++i) {

125:     for (uint256 i = 0; i < exCallData.length; ++i) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)

### <a name="GAS-8"></a>[GAS-8] Use calldata instead of memory for function arguments that do not get mutated
When a function with a `memory` array is called externally, the `abi.decode()` step has to use a for-loop to copy each index of the `calldata` to the `memory` index. Each iteration of this for-loop costs at least 60 gas (i.e. `60 * <mem_array>.length`). Using `calldata` directly bypasses this loop. 

If the array is passed to an `internal` function which passes the array to another internal function where the array is modified and therefore `memory` is used in the `external` call, it's still more gas-efficient to use `calldata` when the `external` function uses modifiers, since the modifiers may prevent the internal functions from being called. Structs have the same overhead as an array of length one. 

 *Saves 60 gas per instance*

*Instances (2)*:
```solidity
File: contracts/ousg/ousg.sol

76:       require(

77:         _getKYCStatus(from),

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousg.sol)

### <a name="GAS-9"></a>[GAS-9] For Operations that will not overflow, you could use unchecked

*Instances (68)*:
```solidity
File: contracts/ousg/ousg.sol

18: import "contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/ERC20PresetMinterPauserUpgradeable.sol";

19: import "contracts/kyc/KYCRegistryClientUpgradeable.sol";

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousg.sol)

```solidity
File: contracts/ousg/ousgInstantManager.sol

18: import "contracts/external/openzeppelin/contracts/access/AccessControlEnumerable.sol";

19: import "contracts/external/openzeppelin/contracts/security/ReentrancyGuard.sol";

20: import "contracts/external/openzeppelin/contracts/token/IERC20Metadata.sol";

21: import "contracts/ousg/rOUSG.sol";

22: import "contracts/interfaces/IRWALike.sol";

23: import "contracts/interfaces/IBUIDLRedeemer.sol";

24: import "contracts/InstantMintTimeBasedRateLimiter.sol";

25: import "contracts/interfaces/IOUSGInstantManager.sol";

26: import "contracts/interfaces/IMulticall.sol";

27: import "contracts/interfaces/IInvestorBasedRateLimiter.sol";

72:   IERC20 public immutable usdc; // 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

203:       10 **

204:         (IERC20Metadata(_ousg).decimals() - IERC20Metadata(_usdc).decimals());

217:                             Mint/Redeem

267:       ousgAmountOut * OUSG_TO_ROUSG_SHARES_MULTIPLIER

304:     uint256 usdcAmountAfterFee = usdcAmountIn - usdcfees;

377:     uint256 ousgAmountIn = rousg.getSharesByROUSG(rousgAmountIn) /

416:     usdcAmountOut = usdcAmountToRedeem - usdcFees;

438:         usdcBalance + minBUIDLRedeemAmount - usdcAmountToRedeem

446:         usdcBalance - usdcAmountToRedeem

467:       usdc.balanceOf(address(this)) == usdcBalanceBefore + buidlAmountToRedeem,

547:                     Mint/Redeem Configuration

689:     uint256 amountE36 = _scaleUp(usdcAmountIn) * 1e18;

690:     ousgAmountOut = amountE36 / price;

703:     uint256 amountE36 = ousgAmountBurned * price;

704:     usdcOwed = _scaleDown(amountE36 / 1e18);

716:     return (usdcAmount * mintFee) / FEE_GRANULARITY;

728:     return (usdcAmount * redeemFee) / FEE_GRANULARITY;

738:     return amount * decimalsMultiplier;

748:     return amount / decimalsMultiplier;

752:                           Pause/Unpause

804:     for (uint256 i = 0; i < exCallData.length; ++i) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/ousgManager.sol

19: import "contracts/RWAHubOffChainRedemptions.sol";

20: import "contracts/kyc/KYCRegistryClient.sol";

21: import "contracts/interfaces/IPricerWithOracle.sol";

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

18: import "contracts/external/openzeppelin/contracts/token/IERC20.sol";

19: import "contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

20: import "contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/IERC20MetadataUpgradeable.sol";

21: import "contracts/external/openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

22: import "contracts/external/openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

23: import "contracts/external/openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

24: import "contracts/external/openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";

25: import "contracts/kyc/KYCRegistryClientUpgradeable.sol";

26: import "contracts/rwaOracles/IRWAOracle.sol";

190:       (totalShares * getOUSGPrice()) / (1e18 * OUSG_TO_ROUSG_SHARES_MULTIPLIER);

201:       (_sharesOf(_account) * getOUSGPrice()) /

202:       (1e18 * OUSG_TO_ROUSG_SHARES_MULTIPLIER);

285:     _approve(_sender, msg.sender, currentAllowance - _amount);

309:       allowances[msg.sender][_spender] + _addedValue

337:     _approve(msg.sender, _spender, currentAllowance - _subtractedValue);

367:       (_rOUSGAmount * 1e18 * OUSG_TO_ROUSG_SHARES_MULTIPLIER) / getOUSGPrice();

375:       (_shares * getOUSGPrice()) / (1e18 * OUSG_TO_ROUSG_SHARES_MULTIPLIER);

417:     uint256 ousgSharesAmount = _OUSGAmount * OUSG_TO_ROUSG_SHARES_MULTIPLIER;

439:       ousgSharesAmount / OUSG_TO_ROUSG_SHARES_MULTIPLIER

517:     shares[_sender] = currentSenderShares - _sharesAmount;

518:     shares[_recipient] = shares[_recipient] + _sharesAmount;

537:     totalShares += _sharesAmount;

539:     shares[_recipient] = shares[_recipient] + _sharesAmount;

565:     totalShares -= _sharesAmount;

567:     shares[_account] = accountShares - _sharesAmount;

636:       ousgSharesAmount / OUSG_TO_ROUSG_SHARES_MULTIPLIER

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

```solidity
File: contracts/ousg/rOUSGFactory.sol

19: import "contracts/external/openzeppelin/contracts/proxy/ProxyAdmin.sol";

20: import "contracts/Proxy.sol";

21: import "contracts/ousg/rOUSG.sol";

22: import "contracts/interfaces/IMulticall.sol";

125:     for (uint256 i = 0; i < exCallData.length; ++i) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)

### <a name="GAS-10"></a>[GAS-10] Use Custom Errors instead of Revert Strings to save Gas
Custom errors are available from solidity version 0.8.4. Custom errors save [**~50 gas**](https://gist.github.com/IllIllI000/ad1bd0d29a0101b25e57c293b4b0c746) each time they're hit by [avoiding having to allocate and store the revert string](https://blog.soliditylang.org/2021/04/21/custom-errors/#errors-in-depth). Not defining the strings also save deployment gas

Additionally, custom errors can be used inside and outside of contracts (including interfaces and libraries).

Source: <https://blog.soliditylang.org/2021/04/21/custom-errors/>:

> Starting from [Solidity v0.8.4](https://github.com/ethereum/solidity/releases/tag/v0.8.4), there is a convenient and gas-efficient way to explain to users why an operation failed through the use of custom errors. Until now, you could already use strings to give more information about failures (e.g., `revert("Insufficient funds.");`), but they are rather expensive, especially when it comes to deploy cost, and it is difficult to use dynamic information in them.

Consider replacing **all revert strings** with custom errors in the solution, and particularly those that have multiple occurrences:

*Instances (25)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

179:     require(_ousg != address(0), "OUSGInstantManager: OUSG cannot be 0x0");

180:     require(_rousg != address(0), "OUSGInstantManager: rOUSG cannot be 0x0");

181:     require(_buidl != address(0), "OUSGInstantManager: BUIDL cannot be 0x0");

557:     require(mintFee < 200, "OUSGInstantManager::setMintFee: Fee too high");

570:     require(redeemFee < 200, "OUSGInstantManager::setRedeemFee: Fee too high");

653:     require(_feeReceiver != address(0), "FeeReceiver cannot be 0x0");

757:     require(!mintPaused, "OUSGInstantManager: Mint paused");

763:     require(!redeemPaused, "OUSGInstantManager: Redeem paused");

808:       require(success, "Call Failed");

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

282:     require(currentAllowance >= _amount, "TRANSFER_AMOUNT_EXCEEDS_ALLOWANCE");

416:     require(_OUSGAmount > 0, "rOUSG: can't wrap zero OUSG tokens");

432:     require(_rOUSGAmount > 0, "rOUSG: can't unwrap zero rOUSG tokens");

477:     require(_owner != address(0), "APPROVE_FROM_ZERO_ADDRESS");

478:     require(_spender != address(0), "APPROVE_TO_ZERO_ADDRESS");

506:     require(_sender != address(0), "TRANSFER_FROM_THE_ZERO_ADDRESS");

507:     require(_recipient != address(0), "TRANSFER_TO_THE_ZERO_ADDRESS");

533:     require(_recipient != address(0), "MINT_TO_THE_ZERO_ADDRESS");

558:     require(_account != address(0), "BURN_FROM_THE_ZERO_ADDRESS");

563:     require(_sharesAmount <= accountShares, "BURN_AMOUNT_EXCEEDS_BALANCE");

594:       require(_getKYCStatus(msg.sender), "rOUSG: 'sender' address not KYC'd");

599:       require(_getKYCStatus(from), "rOUSG: 'from' address not KYC'd");

604:       require(_getKYCStatus(to), "rOUSG: 'to' address not KYC'd");

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

```solidity
File: contracts/ousg/rOUSGFactory.sol

76:     require(!initialized, "ROUSGFactory: rOUSG already deployed");

129:       require(success, "Call Failed");

150:     require(msg.sender == guardian, "ROUSGFactory: You are not the Guardian");

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)

### <a name="GAS-11"></a>[GAS-11] Avoid contract existence checks by using low level calls
Prior to 0.8.10 the compiler inserted extra code, including `EXTCODESIZE` (**100 gas**), to check for contract existence for external function calls. In more recent solidity versions, the compiler will not insert these checks if the external call has a return value. Similar behavior can be achieved in earlier versions by using low-level calls, since low level calls never check for contract existence

*Instances (4)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

424:     uint256 usdcBalance = usdc.balanceOf(address(this));

460:       buidl.balanceOf(address(this)) >= minBUIDLRedeemAmount,

463:     uint256 usdcBalanceBefore = usdc.balanceOf(address(this));

467:       usdc.balanceOf(address(this)) == usdcBalanceBefore + buidlAmountToRedeem,

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

### <a name="GAS-12"></a>[GAS-12] State variables only set in the constructor should be declared `immutable`
Variables only set in the constructor and never edited afterwards should be marked as immutable, as it would avoid the expensive storage-writing operation in the constructor (around **20 000 gas** per variable) and replace the expensive storage-reading operations (around **2100 gas** per reading) to a less expensive value reading (**3 gas**)

*Instances (6)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

211:     _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);

212:     _grantRole(CONFIGURER_ROLE, defaultAdmin);

216:   /*//////////////////////////////////////////////////////////////

217:                             Mint/Redeem

218:   //////////////////////////////////////////////////////////////*/

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSGFactory.sol

64:    *         1) Will grant DEFAULT_ADMIN, PAUSER_ROLE, BURNER_ROLE, and CONFIGURER_ROLE to `guardian`

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)

### <a name="GAS-13"></a>[GAS-13] Functions guaranteed to revert when called by normal users can be marked `payable`
If a function modifier such as `onlyOwner` is used, the function will revert if a normal user tries to pay the function. Marking the function as `payable` will lower the gas cost for legitimate callers because the compiler will not include checks for whether a payment was provided.

*Instances (8)*:
```solidity
File: contracts/ousg/ousg.sol

91:   function burn(address from, uint256 amount) external onlyRole(BURNER_ROLE) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousg.sol)

```solidity
File: contracts/ousg/ousgInstantManager.sol

768:   function pauseMint() external onlyRole(PAUSER_ROLE) {

774:   function unpauseMint() external onlyRole(DEFAULT_ADMIN_ROLE) {

780:   function pauseRedeem() external onlyRole(PAUSER_ROLE) {

786:   function unpauseRedeem() external onlyRole(DEFAULT_ADMIN_ROLE) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

613:   function setOracle(address _oracle) external onlyRole(DEFAULT_ADMIN_ROLE) {

642:   function pause() external onlyRole(PAUSER_ROLE) {

646:   function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="GAS-14"></a>[GAS-14] Using `private` rather than `public` for constants, saves gas
If needed, the values can be read from the verified contract source code, or if there are multiple values there can be a single getter function that [returns a tuple](https://github.com/code-423n4/2022-08-frax/blob/90f55a9ce4e25bceed3a74290b854341d8de6afa/src/contracts/FraxlendPair.sol#L156-L178) of the values of all currently-public constants. Saves **3406-3606 gas** in deployment gas due to the compiler not having to create non-payable getter functions for deployment calldata, not having to store the bytes of the value outside of where it's used, and not adding another entry to the method ID table

*Instances (13)*:
```solidity
File: contracts/ousg/ousg.sol

30:   bytes32 public constant KYC_CONFIGURER_ROLE =

33:   bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousg.sol)

```solidity
File: contracts/ousg/ousgInstantManager.sol

57:   bytes32 public constant CONFIGURER_ROLE = keccak256("CONFIGURER_ROLE");

60:   bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

63:   uint256 public constant MINIMUM_OUSG_PRICE = 105e18;

66:   uint256 public constant FEE_GRANULARITY = 10_000;

69:   uint256 public constant OUSG_TO_ROUSG_SHARES_MULTIPLIER = 10_000;

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/ousgManager.sol

24:   bytes32 public constant REDEMPTION_PROVER_ROLE =

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

87:   uint256 public constant OUSG_TO_ROUSG_SHARES_MULTIPLIER = 10_000;

93:   bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

94:   bytes32 public constant BURNER_ROLE = keccak256("BURN_ROLE");

95:   bytes32 public constant CONFIGURER_ROLE = keccak256("CONFIGURER_ROLE");

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

```solidity
File: contracts/ousg/rOUSGFactory.sol

38:   bytes32 public constant DEFAULT_ADMIN_ROLE = bytes32(0);

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)

### <a name="GAS-15"></a>[GAS-15] Increments/decrements can be unchecked in for-loops
In Solidity 0.8+, there's a default overflow check on unsigned integers. It's possible to uncheck this in for-loops and save some gas at each iteration, but at the cost of some code readability, as this uncheck cannot be made inline.

[ethereum/solidity#10695](https://github.com/ethereum/solidity/issues/10695)

The change would be:

```diff
- for (uint256 i; i < numIterations; i++) {
+ for (uint256 i; i < numIterations;) {
 // ...  
+   unchecked { ++i; }
}  
```

These save around **25 gas saved** per instance.

The same can be applied with decrements (which should use `break` when `i == 0`).

The risk of overflow is non-existent for `uint256`.

*Instances (2)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

804:     for (uint256 i = 0; i < exCallData.length; ++i) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSGFactory.sol

125:     for (uint256 i = 0; i < exCallData.length; ++i) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)

### <a name="GAS-16"></a>[GAS-16] Use != 0 instead of > 0 for unsigned integer comparison

*Instances (6)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

311:       ousgAmountOut > 0,

316:     if (usdcfees > 0) {

418:       usdcAmountOut > 0,

450:     if (usdcFees > 0) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

416:     require(_OUSGAmount > 0, "rOUSG: can't wrap zero OUSG tokens");

432:     require(_rOUSGAmount > 0, "rOUSG: can't unwrap zero rOUSG tokens");

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)


## Non Critical Issues


| |Issue|Instances|
|-|:-|:-:|
| [NC-1](#NC-1) | Missing checks for `address(0)` when assigning values to address state variables | 3 |
| [NC-2](#NC-2) | `require()` should be used instead of `assert()` | 1 |
| [NC-3](#NC-3) | `constant`s should be defined rather than using magic numbers | 13 |
| [NC-4](#NC-4) | Control structures do not follow the Solidity Style Guide | 2 |
| [NC-5](#NC-5) | Critical Changes Should Use Two-step Procedure | 1 |
| [NC-6](#NC-6) | Event missing indexed field | 1 |
| [NC-7](#NC-7) | Events that mark critical parameter changes should contain both the old and the new value | 9 |
| [NC-8](#NC-8) | Function ordering does not follow the Solidity style guide | 4 |
| [NC-9](#NC-9) | Functions should not be longer than 50 lines | 25 |
| [NC-10](#NC-10) | Change int to int256 | 2 |
| [NC-11](#NC-11) | Lack of checks in setters | 13 |
| [NC-12](#NC-12) | Missing Event for critical parameters change | 9 |
| [NC-13](#NC-13) | NatSpec is completely non-existent on functions that should have them | 6 |
| [NC-14](#NC-14) | Incomplete NatSpec: `@param` is missing on actually documented functions | 6 |
| [NC-15](#NC-15) | Incomplete NatSpec: `@return` is missing on actually documented functions | 3 |
| [NC-16](#NC-16) | Use a `modifier` instead of a `require/if` statement for a special `msg.sender` actor | 3 |
| [NC-17](#NC-17) | Constant state variables defined more than once | 8 |
| [NC-18](#NC-18) | Consider using named mappings | 2 |
| [NC-19](#NC-19) | `address`s shouldn't be hard-coded | 1 |
| [NC-20](#NC-20) | Take advantage of Custom Error's return value property | 8 |
| [NC-21](#NC-21) | Strings should use double quotes rather than single quotes | 3 |
| [NC-22](#NC-22) | Contract does not follow the Solidity style guide's suggested layout ordering | 4 |
| [NC-23](#NC-23) | Internal and private variables and functions names should begin with an underscore | 3 |
| [NC-24](#NC-24) | Event is missing `indexed` fields | 3 |
| [NC-25](#NC-25) | `public` functions not called by the contract should be declared `external` instead | 15 |
| [NC-26](#NC-26) | Variables need not be initialized to zero | 4 |
### <a name="NC-1"></a>[NC-1] Missing checks for `address(0)` when assigning values to address state variables

*Instances (3)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

212:     _grantRole(CONFIGURER_ROLE, defaultAdmin);

213:     _grantRole(PAUSER_ROLE, defaultAdmin);

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSGFactory.sol

64:    *         1) Will grant DEFAULT_ADMIN, PAUSER_ROLE, BURNER_ROLE, and CONFIGURER_ROLE to `guardian`

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)

### <a name="NC-2"></a>[NC-2] `require()` should be used instead of `assert()`
Prior to solidity version 0.8.0, hitting an assert consumes the **remainder of the transaction's available gas** rather than returning it, as `require()`/`revert()` do. `assert()` should be avoided even past solidity version 0.8.0 as its [documentation](https://docs.soliditylang.org/en/v0.8.14/control-structures.html#panic-via-assert-and-error-via-require) states that "The assert function creates an error of type Panic(uint256). ... Properly functioning code should never create a Panic, not even on invalid external input. If this happens, then there is a bug in your contract which you should fix. Additionally, a require statement (or a custom error) are more friendly in terms of understanding what happened."

*Instances (1)*:
```solidity
File: contracts/ousg/rOUSGFactory.sol

94:     assert(rOUSGProxyAdmin.owner() == guardian);

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)

### <a name="NC-3"></a>[NC-3] `constant`s should be defined rather than using magic numbers
Even [assembly](https://github.com/code-423n4/2022-05-opensea-seaport/blob/9d7ce4d08bf3c3010304a0476a785c70c0e90ae7/contracts/lib/TokenTransferrer.sol#L35-L39) can benefit from using readable constants instead of hex/numeric literals

*Instances (13)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

106:   uint256 public minimumDepositAmount = 100_000e6;

110:   uint256 public minimumRedemptionAmount = 50_000e6;

120:   uint256 public minBUIDLRedeemAmount = 250_000e6;

203:       10 **

283:       IERC20Metadata(address(usdc)).decimals() == 6,

284:       "OUSGInstantManager::_mint: USDC decimals must be 6"

392:       IERC20Metadata(address(usdc)).decimals() == 6,

393:       "OUSGInstantManager::_redeem: USDC decimals must be 6"

396:       IERC20Metadata(address(buidl)).decimals() == 6,

397:       "OUSGInstantManager::_redeem: BUIDL decimals must be 6"

557:     require(mintFee < 200, "OUSGInstantManager::setMintFee: Fee too high");

570:     require(redeemFee < 200, "OUSGInstantManager::setRedeemFee: Fee too high");

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

182:     return 18;

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="NC-4"></a>[NC-4] Control structures do not follow the Solidity Style Guide
See the [control structures](https://docs.soliditylang.org/en/latest/style-guide.html#control-structures) section of the Solidity Style Guide

*Instances (2)*:
```solidity
File: contracts/ousg/rOUSG.sol

434:     if (ousgSharesAmount < OUSG_TO_ROUSG_SHARES_MULTIPLIER)

629:     if (ousgSharesAmount < OUSG_TO_ROUSG_SHARES_MULTIPLIER)

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="NC-5"></a>[NC-5] Critical Changes Should Use Two-step Procedure
The critical procedures should be two step process.

See similar findings in previous Code4rena contests for reference: <https://code4rena.com/reports/2022-06-illuminate/#2-critical-changes-should-use-two-step-procedure>

**Recommended Mitigation Steps**

Lack of two-step procedure for critical operations leaves them error-prone. Consider adding two step procedure on the critical functions.

*Instances (1)*:
```solidity
File: contracts/ousg/rOUSG.sol

613:   function setOracle(address _oracle) external onlyRole(DEFAULT_ADMIN_ROLE) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="NC-6"></a>[NC-6] Event missing indexed field
Index event fields make the field more quickly accessible [to off-chain tools](https://ethereum.stackexchange.com/questions/40396/can-somebody-please-explain-the-concept-of-event-indexing) that parse events. This is especially useful when it comes to filtering based on an address. However, note that each index field costs extra gas during emission, so it's not necessarily best to index the maximum allowed per event (three fields). Where applicable, each `event` should use three `indexed` fields if there are three or more fields, and gas usage is not particularly of concern for the events in question. If there are fewer than three applicable fields, all of the applicable fields should be indexed.

*Instances (1)*:
```solidity
File: contracts/ousg/rOUSGFactory.sol

154: 

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)

### <a name="NC-7"></a>[NC-7] Events that mark critical parameter changes should contain both the old and the new value
This should especially be done if the new value is not required to be different from the old value

*Instances (9)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

576:    * @notice Admin function to set the minimum amount required for a deposit
        *
        * @param _minimumDepositAmount The minimum amount required to submit a deposit
        *                          request

585:       _minimumDepositAmount >= FEE_GRANULARITY,
           "setMinimumDepositAmount: Amount too small"
         );
     
         emit MinimumDepositAmountSet(minimumDepositAmount, _minimumDepositAmount);
         minimumDepositAmount = _minimumDepositAmount;

599:   function setMinimumRedemptionAmount(
         uint256 _minimumRedemptionAmount
       ) external override onlyRole(CONFIGURER_ROLE) {
         require(
           _minimumRedemptionAmount >= FEE_GRANULARITY,
           "setMinimumRedemptionAmount: Amount too small"
         );
         emit MinimumRedemptionAmountSet(

618:    * @notice Admin function to set the minimum amount required to redeem BUIDL
        *
        * @param _minimumBUIDLRedemptionAmount The minimum amount required to redeem BUIDL
        */
       function setMinimumBUIDLRedemptionAmount(
         uint256 _minimumBUIDLRedemptionAmount
       ) external override onlyRole(DEFAULT_ADMIN_ROLE) {

641:     emit OracleSet(address(oracle), _oracle);
         oracle = IRWAOracle(_oracle);
       }
     
       /**
        * @notice Admin function to set the fee receiver address
     
        * @param _feeReceiver The address to receive the mint and redemption fees

659:    * @notice Admin function to set the optional investor-based rate limiter
        *
        * @param _investorBasedRateLimiter The address of the investor-based rate limiter contract

667:       address(investorBasedRateLimiter),
           _investorBasedRateLimiter
         );
         investorBasedRateLimiter = IInvestorBasedRateLimiter(
           _investorBasedRateLimiter
         );
       }

681:    *
        * @param usdcAmountIn The amount deposited in units of USDC
        * @param price        The price at which to mint
        */
       function _getMintAmount(

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

629:     if (ousgSharesAmount < OUSG_TO_ROUSG_SHARES_MULTIPLIER)
           revert UnwrapTooSmall();
     
         _burnShares(_account, ousgSharesAmount);

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="NC-8"></a>[NC-8] Function ordering does not follow the Solidity style guide
According to the [Solidity style guide](https://docs.soliditylang.org/en/v0.8.17/style-guide.html#order-of-functions), functions should be laid out in the following order :`constructor()`, `receive()`, `fallback()`, `external`, `public`, `internal`, `private`, but the cases below do not follow this pattern

*Instances (4)*:
```solidity
File: contracts/ousg/ousg.sol

1: 
   Current order:
   external setKYCRequirementGroup
   external setKYCRegistry
   public initialize
   internal _beforeTokenTransfer
   external burn
   
   Suggested order:
   external setKYCRequirementGroup
   external setKYCRegistry
   external burn
   public initialize
   internal _beforeTokenTransfer

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousg.sol)

```solidity
File: contracts/ousg/ousgInstantManager.sol

1: 
   Current order:
   external mint
   external mintRebasingOUSG
   internal _mint
   external redeem
   external redeemRebasingOUSG
   internal _redeem
   internal _redeemBUIDL
   public getOUSGPrice
   external setInstantMintLimit
   external setInstantRedemptionLimit
   external setInstantMintLimitDuration
   external setInstantRedemptionLimitDuration
   external setMintFee
   external setRedeemFee
   external setMinimumDepositAmount
   external setMinimumRedemptionAmount
   external setMinimumBUIDLRedemptionAmount
   external setOracle
   external setFeeReceiver
   external setInvestorBasedRateLimiter
   internal _getMintAmount
   internal _getRedemptionAmount
   internal _getInstantMintFees
   internal _getInstantRedemptionFees
   internal _scaleUp
   internal _scaleDown
   external pauseMint
   external unpauseMint
   external pauseRedeem
   external unpauseRedeem
   external multiexcall
   external retrieveTokens
   
   Suggested order:
   external mint
   external mintRebasingOUSG
   external redeem
   external redeemRebasingOUSG
   external setInstantMintLimit
   external setInstantRedemptionLimit
   external setInstantMintLimitDuration
   external setInstantRedemptionLimitDuration
   external setMintFee
   external setRedeemFee
   external setMinimumDepositAmount
   external setMinimumRedemptionAmount
   external setMinimumBUIDLRedemptionAmount
   external setOracle
   external setFeeReceiver
   external setInvestorBasedRateLimiter
   external pauseMint
   external unpauseMint
   external pauseRedeem
   external unpauseRedeem
   external multiexcall
   external retrieveTokens
   public getOUSGPrice
   internal _mint
   internal _redeem
   internal _redeemBUIDL
   internal _getMintAmount
   internal _getRedemptionAmount
   internal _getInstantMintFees
   internal _getInstantRedemptionFees
   internal _scaleUp
   internal _scaleDown

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/ousgManager.sol

1: 
   Current order:
   internal _checkRestrictions
   external setKYCRequirementGroup
   external addRedemptionProof
   external setKYCRegistry
   public setPriceIdForDeposits
   public setPriceIdForRedemptions
   
   Suggested order:
   external setKYCRequirementGroup
   external addRedemptionProof
   external setKYCRegistry
   public setPriceIdForDeposits
   public setPriceIdForRedemptions
   internal _checkRestrictions

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

1: 
   Current order:
   public initialize
   internal __rOUSG_init
   internal __rOUSG_init_unchained
   public name
   public symbol
   public decimals
   public totalSupply
   public balanceOf
   public transfer
   public allowance
   public approve
   public transferFrom
   public increaseAllowance
   public decreaseAllowance
   public getTotalShares
   public sharesOf
   public getSharesByROUSG
   public getROUSGByShares
   public getOUSGPrice
   public transferShares
   external wrap
   external unwrap
   internal _transfer
   internal _approve
   internal _sharesOf
   internal _transferShares
   internal _mintShares
   internal _burnShares
   internal _beforeTokenTransfer
   external setOracle
   external burn
   external pause
   external unpause
   external setKYCRegistry
   external setKYCRequirementGroup
   
   Suggested order:
   external wrap
   external unwrap
   external setOracle
   external burn
   external pause
   external unpause
   external setKYCRegistry
   external setKYCRequirementGroup
   public initialize
   public name
   public symbol
   public decimals
   public totalSupply
   public balanceOf
   public transfer
   public allowance
   public approve
   public transferFrom
   public increaseAllowance
   public decreaseAllowance
   public getTotalShares
   public sharesOf
   public getSharesByROUSG
   public getROUSGByShares
   public getOUSGPrice
   public transferShares
   internal __rOUSG_init
   internal __rOUSG_init_unchained
   internal _transfer
   internal _approve
   internal _sharesOf
   internal _transferShares
   internal _mintShares
   internal _burnShares
   internal _beforeTokenTransfer

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="NC-9"></a>[NC-9] Functions should not be longer than 50 lines
Overly complex code can make understanding functionality more difficult, try to further modularize your code to ensure readability 

*Instances (25)*:
```solidity
File: contracts/ousg/ousg.sol

91:   function burn(address from, uint256 amount) external onlyRole(BURNER_ROLE) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousg.sol)

```solidity
File: contracts/ousg/ousgInstantManager.sol

458:   function _redeemBUIDL(uint256 buidlAmountToRedeem) internal {

479:   function getOUSGPrice() public view returns (uint256 price) {

737:   function _scaleUp(uint256 amount) internal view returns (uint256) {

747:   function _scaleDown(uint256 amount) internal view returns (uint256) {

768:   function pauseMint() external onlyRole(PAUSER_ROLE) {

774:   function unpauseMint() external onlyRole(DEFAULT_ADMIN_ROLE) {

780:   function pauseRedeem() external onlyRole(PAUSER_ROLE) {

786:   function unpauseRedeem() external onlyRole(DEFAULT_ADMIN_ROLE) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/ousgManager.sol

62:   function _checkRestrictions(address account) internal view override {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

166:   function name() public pure returns (string memory) {

174:   function symbol() public pure returns (string memory) {

188:   function totalSupply() public view returns (uint256) {

199:   function balanceOf(address _account) public view returns (uint256) {

220:   function transfer(address _recipient, uint256 _amount) public returns (bool) {

251:   function approve(address _spender, uint256 _amount) public returns (bool) {

347:   function getTotalShares() public view returns (uint256) {

356:   function sharesOf(address _account) public view returns (uint256) {

373:   function getROUSGByShares(uint256 _shares) public view returns (uint256) {

378:   function getOUSGPrice() public view returns (uint256 price) {

415:   function wrap(uint256 _OUSGAmount) external whenNotPaused {

431:   function unwrap(uint256 _rOUSGAmount) external whenNotPaused {

487:   function _sharesOf(address _account) internal view returns (uint256) {

613:   function setOracle(address _oracle) external onlyRole(DEFAULT_ADMIN_ROLE) {

646:   function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="NC-10"></a>[NC-10] Change int to int256
Throughout the code base, some variables are declared as `int`. To favor explicitness, consider changing all instances of `int` to `int256`

*Instances (2)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

312:       "OUSGInstantManager::_mint: net mint amount can't be zero"

757:     require(!mintPaused, "OUSGInstantManager: Mint paused");

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

### <a name="NC-11"></a>[NC-11] Lack of checks in setters
Be it sanity checks (like checks against `0`-values) or initial setting checks: it's best for Setter functions to have them

*Instances (13)*:
```solidity
File: contracts/ousg/ousg.sol

63:     address from,
        address to,
        uint256 amount
      ) internal override {
        super._beforeTokenTransfer(from, to, amount);

70:       _getKYCStatus(_msgSender()),
          "CashKYCSenderReceiver: must be KYC'd to initiate transfer"
        );
    
        if (from != address(0)) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousg.sol)

```solidity
File: contracts/ousg/ousgInstantManager.sol

514:   ) external override onlyRole(CONFIGURER_ROLE) {
         _setInstantRedemptionLimit(_instantRedemptionLimit);
       }
     
       /**
        * @notice Sets mintLimitDuration constraint inside the InstantMintTimeBasedRateLimiter

528:   ) external override onlyRole(CONFIGURER_ROLE) {
         _setInstantMintLimitDuration(_instantMintLimitDuration);
       }
     
       /**
        * @notice Sets redeemLimitDuration inside the InstantMintTimeBasedRateLimiter

541:     uint256 _instantRedemptionLimitDuratioin
       ) external override onlyRole(CONFIGURER_ROLE) {
         _setInstantRedemptionLimitDuration(_instantRedemptionLimitDuratioin);

557:     require(mintFee < 200, "OUSGInstantManager::setMintFee: Fee too high");
         emit MintFeeSet(mintFee, _mintFee);
         mintFee = _mintFee;
       }
     
       /**
        * @notice Sets the redeem fee.

641:     emit OracleSet(address(oracle), _oracle);
         oracle = IRWAOracle(_oracle);
       }
     
       /**
        * @notice Admin function to set the fee receiver address
     
        * @param _feeReceiver The address to receive the mint and redemption fees
        */
       function setFeeReceiver(
         address _feeReceiver
       ) external override onlyRole(DEFAULT_ADMIN_ROLE) {

659:    * @notice Admin function to set the optional investor-based rate limiter
        *
        * @param _investorBasedRateLimiter The address of the investor-based rate limiter contract

681:    *
        * @param usdcAmountIn The amount deposited in units of USDC
        * @param price        The price at which to mint
        */
       function _getMintAmount(
         uint256 usdcAmountIn,
         uint256 price
       ) internal view returns (uint256 ousgAmountOut) {
         uint256 amountE36 = _scaleUp(usdcAmountIn) * 1e18;

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/ousgManager.sol

97:     uint256 timestamp
      ) external onlyRole(REDEMPTION_PROVER_ROLE) checkRestrictions(user) {
        if (redemptionIdToRedeemer[txHash].user != address(0)) {

138:   ) public virtual override onlyRole(PRICE_ID_SETTER_ROLE) {
         if (!IPricerWithOracle(address(pricer)).isValid(priceIds)) {
           revert InvalidPriceId();

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

629:     if (ousgSharesAmount < OUSG_TO_ROUSG_SHARES_MULTIPLIER)
           revert UnwrapTooSmall();
     
         _burnShares(_account, ousgSharesAmount);
     
         ousg.transfer(
           msg.sender,
           ousgSharesAmount / OUSG_TO_ROUSG_SHARES_MULTIPLIER

662: 

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="NC-12"></a>[NC-12] Missing Event for critical parameters change
Events help non-contract tools to track changes, and events prevent users from being surprised by changes.

*Instances (9)*:
```solidity
File: contracts/ousg/ousg.sol

63:     address from,
        address to,
        uint256 amount
      ) internal override {
        super._beforeTokenTransfer(from, to, amount);

70:       _getKYCStatus(_msgSender()),
          "CashKYCSenderReceiver: must be KYC'd to initiate transfer"
        );
    
        if (from != address(0)) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousg.sol)

```solidity
File: contracts/ousg/ousgInstantManager.sol

514:   ) external override onlyRole(CONFIGURER_ROLE) {
         _setInstantRedemptionLimit(_instantRedemptionLimit);
       }
     
       /**
        * @notice Sets mintLimitDuration constraint inside the InstantMintTimeBasedRateLimiter

528:   ) external override onlyRole(CONFIGURER_ROLE) {
         _setInstantMintLimitDuration(_instantMintLimitDuration);
       }
     
       /**
        * @notice Sets redeemLimitDuration inside the InstantMintTimeBasedRateLimiter

541:     uint256 _instantRedemptionLimitDuratioin
       ) external override onlyRole(CONFIGURER_ROLE) {
         _setInstantRedemptionLimitDuration(_instantRedemptionLimitDuratioin);

557:     require(mintFee < 200, "OUSGInstantManager::setMintFee: Fee too high");
         emit MintFeeSet(mintFee, _mintFee);
         mintFee = _mintFee;
       }
     
       /**
        * @notice Sets the redeem fee.

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/ousgManager.sol

97:     uint256 timestamp
      ) external onlyRole(REDEMPTION_PROVER_ROLE) checkRestrictions(user) {
        if (redemptionIdToRedeemer[txHash].user != address(0)) {

138:   ) public virtual override onlyRole(PRICE_ID_SETTER_ROLE) {
         if (!IPricerWithOracle(address(pricer)).isValid(priceIds)) {
           revert InvalidPriceId();

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

662: 

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="NC-13"></a>[NC-13] NatSpec is completely non-existent on functions that should have them
Public and external functions that aren't view or pure should have NatSpec comments

*Instances (6)*:
```solidity
File: contracts/ousg/ousg.sol

63:     address from,

70:       _getKYCStatus(_msgSender()),

75:       // Only check KYC if not minting

95: 

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousg.sol)

```solidity
File: contracts/ousg/ousgInstantManager.sol

816:    * @param to The address of the recipient

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

662: 

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="NC-14"></a>[NC-14] Incomplete NatSpec: `@param` is missing on actually documented functions
The following functions are missing `@param` NatSpec comments.

*Instances (6)*:
```solidity
File: contracts/ousg/rOUSG.sol

221:     _transfer(msg.sender, _recipient, _amount);
         return true;
       }
     
       /**
        * @return the remaining number of tokens that `_spender` is allowed to spend
        * on behalf of `_owner` through `transferFrom`. This is zero by default.
        *
        * @dev This value changes when `approve` or `transferFrom` is called.
        */
       function allowance(
         address _owner,
         address _spender
       ) public view returns (uint256) {
         return allowances[_owner][_spender];
       }
     
       /**
        * @notice Sets `_amount` as the allowance of `_spender` over the caller's tokens.
        *
        * @return a boolean value indicating whether the operation succeeded.

257:    * @notice Moves `_amount` tokens from `_sender` to `_recipient` using the
        * allowance mechanism. `_amount` is then deducted from the caller's
        * allowance.
        *
        * @return a boolean value indicating whether the operation succeeded.
        *
        * Emits a `Transfer` event.
        * Emits a `TransferShares` event.
        * Emits an `Approval` event indicating the updated allowance.
        *
        * Requirements:
        *
        * - `_sender` and `_recipient` cannot be the zero addresses.
        * - `_sender` must have a balance of at least `_amount`.

271:    * - the caller must have allowance for `_sender`'s tokens of at least `_amount`.
        * - the contract must not be paused.
        *
        * @dev The `_amount` argument is the amount of tokens, not shares.
        */
       function transferFrom(
         address _sender,
         address _recipient,
         uint256 _amount
       ) public returns (bool) {
         uint256 currentAllowance = allowances[_sender][msg.sender];
         require(currentAllowance >= _amount, "TRANSFER_AMOUNT_EXCEEDS_ALLOWANCE");
     
         _transfer(_sender, _recipient, _amount);
         _approve(_sender, msg.sender, currentAllowance - _amount);
         return true;
       }
     
       /**
        * @notice Atomically increases the allowance granted to `_spender` by the caller by `_addedValue`.
        *
        * This is an alternative to `approve` that can be used as a mitigation for
        * problems described in:
        * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol#L42

305:   ) public returns (bool) {
         _approve(
           msg.sender,
           _spender,
           allowances[msg.sender][_spender] + _addedValue
         );
         return true;
       }
     
       /**
        * @notice Atomically decreases the allowance granted to `_spender` by the caller by `_subtractedValue`.
        *
        * This is an alternative to `approve` that can be used as a mitigation for
        * problems described in:
        * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol#L42
        * Emits an `Approval` event indicating the updated allowance.
        *
        * Requirements:
        *
        * - `_spender` cannot be the zero address.

328:   function decreaseAllowance(
         address _spender,
         uint256 _subtractedValue
       ) public returns (bool) {
         uint256 currentAllowance = allowances[msg.sender][_spender];
         require(
           currentAllowance >= _subtractedValue,
           "DECREASED_ALLOWANCE_BELOW_ZERO"
         );
         _approve(msg.sender, _spender, currentAllowance - _subtractedValue);
         return true;
       }
     
       /**
        * @return the total amount of shares in existence.
        *
        * @dev The sum of all accounts' shares can be an arbitrary number, therefore
        * it is necessary to store it in order to calculate each account's relative share.
        */
       function getTotalShares() public view returns (uint256) {
         return totalShares;

401:     _transferShares(msg.sender, _recipient, _sharesAmount);
         emit TransferShares(msg.sender, _recipient, _sharesAmount);
         uint256 tokensAmount = getROUSGByShares(_sharesAmount);
         emit Transfer(msg.sender, _recipient, tokensAmount);
         return tokensAmount;
       }
     
       /**
        * @notice Function called by users to wrap their OUSG tokens
        *
        * @param _OUSGAmount The amount of OUSG Tokens to wrap
        *
        * @dev KYC checks implicit in OUSG Transfer
        */
       function wrap(uint256 _OUSGAmount) external whenNotPaused {
         require(_OUSGAmount > 0, "rOUSG: can't wrap zero OUSG tokens");

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="NC-15"></a>[NC-15] Incomplete NatSpec: `@return` is missing on actually documented functions
The following functions are missing `@return` NatSpec comments.

*Instances (3)*:
```solidity
File: contracts/ousg/rOUSG.sol

305:   ) public returns (bool) {
         _approve(
           msg.sender,
           _spender,
           allowances[msg.sender][_spender] + _addedValue
         );
         return true;
       }
     
       /**
        * @notice Atomically decreases the allowance granted to `_spender` by the caller by `_subtractedValue`.
        *
        * This is an alternative to `approve` that can be used as a mitigation for
        * problems described in:
        * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol#L42
        * Emits an `Approval` event indicating the updated allowance.
        *
        * Requirements:
        *
        * - `_spender` cannot be the zero address.
        * - `_spender` must have allowance for the caller of at least `_subtractedValue`.

328:   function decreaseAllowance(
         address _spender,
         uint256 _subtractedValue
       ) public returns (bool) {
         uint256 currentAllowance = allowances[msg.sender][_spender];
         require(
           currentAllowance >= _subtractedValue,
           "DECREASED_ALLOWANCE_BELOW_ZERO"
         );
         _approve(msg.sender, _spender, currentAllowance - _subtractedValue);
         return true;
       }
     
       /**
        * @return the total amount of shares in existence.
        *
        * @dev The sum of all accounts' shares can be an arbitrary number, therefore
        * it is necessary to store it in order to calculate each account's relative share.
        */
       function getTotalShares() public view returns (uint256) {
         return totalShares;
       }
     
       /**
        * @return the amount of shares owned by `_account`.

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

```solidity
File: contracts/ousg/rOUSGFactory.sol

126:       (bool success, bytes memory ret) = address(exCallData[i].target).call{
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

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)

### <a name="NC-16"></a>[NC-16] Use a `modifier` instead of a `require/if` statement for a special `msg.sender` actor
If a function is supposed to be access-controlled, a `modifier` should be used instead of a `require/if` statement for more readability.

*Instances (3)*:
```solidity
File: contracts/ousg/rOUSG.sol

593:     if (from != msg.sender && to != msg.sender) {

594:       require(_getKYCStatus(msg.sender), "rOUSG: 'sender' address not KYC'd");

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

```solidity
File: contracts/ousg/rOUSGFactory.sol

150:     require(msg.sender == guardian, "ROUSGFactory: You are not the Guardian");

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)

### <a name="NC-17"></a>[NC-17] Constant state variables defined more than once
Rather than redefining state variable constant, consider using a library to store all constants as this will prevent data redundancy

*Instances (8)*:
```solidity
File: contracts/ousg/ousg.sol

58:     __ERC20PresetMinterPauser_init(name, symbol);

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousg.sol)

```solidity
File: contracts/ousg/ousgInstantManager.sol

72:   IERC20 public immutable usdc; // 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

77:   // Rebasing OUSG Contract

89:   // The address that receives USDC for subscriptions

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

106:     address guardian,

114:     uint256 requirementGroup,

117:     address _oracle

119:     __rOUSG_init_unchained(

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="NC-18"></a>[NC-18] Consider using named mappings
Consider moving to solidity version 0.8.18 or later, and using [named mappings](https://ethereum.stackexchange.com/questions/51629/how-to-name-the-arguments-in-mapping/145555#145555) to make it easier to understand the purpose of each mapping

*Instances (2)*:
```solidity
File: contracts/ousg/rOUSG.sol

72:   mapping(address => uint256) private shares;

75:   mapping(address => mapping(address => uint256)) private allowances;

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="NC-19"></a>[NC-19] `address`s shouldn't be hard-coded
It is often better to declare `address`es as `immutable`, and assign them via constructor arguments. This allows the code to remain the same across deployments on different networks, and avoids recompilation when addresses need to change.

*Instances (1)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

72:   IERC20 public immutable usdc; // 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

### <a name="NC-20"></a>[NC-20] Take advantage of Custom Error's return value property
An important feature of Custom Error is that values such as address, tokenID, msg.value can be written inside the () sign, this kind of approach provides a serious advantage in debugging and examining the revert details of dapps such as tenderly.

*Instances (8)*:
```solidity
File: contracts/ousg/ousgManager.sol

65:       revert KYCCheckFailed();

100:       revert RedemptionProofAlreadyExists();

103:       revert RedemptionTooSmall();

106:       revert RedeemerNull();

130:       revert InvalidPriceId();

140:       revert InvalidPriceId();

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

435:       revert UnwrapTooSmall();

630:       revert UnwrapTooSmall();

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="NC-21"></a>[NC-21] Strings should use double quotes rather than single quotes
See the Solidity Style Guide: https://docs.soliditylang.org/en/v0.8.20/style-guide.html#other-recommendations

*Instances (3)*:
```solidity
File: contracts/ousg/rOUSG.sol

594:       require(_getKYCStatus(msg.sender), "rOUSG: 'sender' address not KYC'd");

599:       require(_getKYCStatus(from), "rOUSG: 'from' address not KYC'd");

604:       require(_getKYCStatus(to), "rOUSG: 'to' address not KYC'd");

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="NC-22"></a>[NC-22] Contract does not follow the Solidity style guide's suggested layout ordering
The [style guide](https://docs.soliditylang.org/en/v0.8.16/style-guide.html#order-of-layout) says that, within a contract, the ordering should be:

1) Type declarations
2) State variables
3) Events
4) Modifiers
5) Functions

However, the contract(s) below do not follow this ordering

*Instances (4)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

1: 
   Current order:
   VariableDeclaration.CONFIGURER_ROLE
   VariableDeclaration.PAUSER_ROLE
   VariableDeclaration.MINIMUM_OUSG_PRICE
   VariableDeclaration.FEE_GRANULARITY
   VariableDeclaration.OUSG_TO_ROUSG_SHARES_MULTIPLIER
   VariableDeclaration.usdc
   VariableDeclaration.ousg
   VariableDeclaration.rousg
   VariableDeclaration.buidl
   VariableDeclaration.buidlRedeemer
   VariableDeclaration.decimalsMultiplier
   VariableDeclaration.usdcReceiver
   VariableDeclaration.oracle
   VariableDeclaration.feeReceiver
   VariableDeclaration.mintFee
   VariableDeclaration.redeemFee
   VariableDeclaration.minimumDepositAmount
   VariableDeclaration.minimumRedemptionAmount
   VariableDeclaration.mintPaused
   VariableDeclaration.redeemPaused
   VariableDeclaration.minBUIDLRedeemAmount
   VariableDeclaration.investorBasedRateLimiter
   FunctionDefinition.constructor
   FunctionDefinition.mint
   FunctionDefinition.mintRebasingOUSG
   FunctionDefinition._mint
   FunctionDefinition.redeem
   FunctionDefinition.redeemRebasingOUSG
   FunctionDefinition._redeem
   FunctionDefinition._redeemBUIDL
   FunctionDefinition.getOUSGPrice
   FunctionDefinition.setInstantMintLimit
   FunctionDefinition.setInstantRedemptionLimit
   FunctionDefinition.setInstantMintLimitDuration
   FunctionDefinition.setInstantRedemptionLimitDuration
   FunctionDefinition.setMintFee
   FunctionDefinition.setRedeemFee
   FunctionDefinition.setMinimumDepositAmount
   FunctionDefinition.setMinimumRedemptionAmount
   FunctionDefinition.setMinimumBUIDLRedemptionAmount
   FunctionDefinition.setOracle
   FunctionDefinition.setFeeReceiver
   FunctionDefinition.setInvestorBasedRateLimiter
   FunctionDefinition._getMintAmount
   FunctionDefinition._getRedemptionAmount
   FunctionDefinition._getInstantMintFees
   FunctionDefinition._getInstantRedemptionFees
   FunctionDefinition._scaleUp
   FunctionDefinition._scaleDown
   ModifierDefinition.whenMintNotPaused
   ModifierDefinition.whenRedeemNotPaused
   FunctionDefinition.pauseMint
   FunctionDefinition.unpauseMint
   FunctionDefinition.pauseRedeem
   FunctionDefinition.unpauseRedeem
   FunctionDefinition.multiexcall
   FunctionDefinition.retrieveTokens
   
   Suggested order:
   VariableDeclaration.CONFIGURER_ROLE
   VariableDeclaration.PAUSER_ROLE
   VariableDeclaration.MINIMUM_OUSG_PRICE
   VariableDeclaration.FEE_GRANULARITY
   VariableDeclaration.OUSG_TO_ROUSG_SHARES_MULTIPLIER
   VariableDeclaration.usdc
   VariableDeclaration.ousg
   VariableDeclaration.rousg
   VariableDeclaration.buidl
   VariableDeclaration.buidlRedeemer
   VariableDeclaration.decimalsMultiplier
   VariableDeclaration.usdcReceiver
   VariableDeclaration.oracle
   VariableDeclaration.feeReceiver
   VariableDeclaration.mintFee
   VariableDeclaration.redeemFee
   VariableDeclaration.minimumDepositAmount
   VariableDeclaration.minimumRedemptionAmount
   VariableDeclaration.mintPaused
   VariableDeclaration.redeemPaused
   VariableDeclaration.minBUIDLRedeemAmount
   VariableDeclaration.investorBasedRateLimiter
   ModifierDefinition.whenMintNotPaused
   ModifierDefinition.whenRedeemNotPaused
   FunctionDefinition.constructor
   FunctionDefinition.mint
   FunctionDefinition.mintRebasingOUSG
   FunctionDefinition._mint
   FunctionDefinition.redeem
   FunctionDefinition.redeemRebasingOUSG
   FunctionDefinition._redeem
   FunctionDefinition._redeemBUIDL
   FunctionDefinition.getOUSGPrice
   FunctionDefinition.setInstantMintLimit
   FunctionDefinition.setInstantRedemptionLimit
   FunctionDefinition.setInstantMintLimitDuration
   FunctionDefinition.setInstantRedemptionLimitDuration
   FunctionDefinition.setMintFee
   FunctionDefinition.setRedeemFee
   FunctionDefinition.setMinimumDepositAmount
   FunctionDefinition.setMinimumRedemptionAmount
   FunctionDefinition.setMinimumBUIDLRedemptionAmount
   FunctionDefinition.setOracle
   FunctionDefinition.setFeeReceiver
   FunctionDefinition.setInvestorBasedRateLimiter
   FunctionDefinition._getMintAmount
   FunctionDefinition._getRedemptionAmount
   FunctionDefinition._getInstantMintFees
   FunctionDefinition._getInstantRedemptionFees
   FunctionDefinition._scaleUp
   FunctionDefinition._scaleDown
   FunctionDefinition.pauseMint
   FunctionDefinition.unpauseMint
   FunctionDefinition.pauseRedeem
   FunctionDefinition.unpauseRedeem
   FunctionDefinition.multiexcall
   FunctionDefinition.retrieveTokens

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/ousgManager.sol

1: 
   Current order:
   VariableDeclaration.REDEMPTION_PROVER_ROLE
   FunctionDefinition.constructor
   FunctionDefinition._checkRestrictions
   FunctionDefinition.setKYCRequirementGroup
   FunctionDefinition.addRedemptionProof
   FunctionDefinition.setKYCRegistry
   FunctionDefinition.setPriceIdForDeposits
   FunctionDefinition.setPriceIdForRedemptions
   EventDefinition.RedemptionProofAdded
   ErrorDefinition.KYCCheckFailed
   ErrorDefinition.InvalidPriceId
   
   Suggested order:
   VariableDeclaration.REDEMPTION_PROVER_ROLE
   ErrorDefinition.KYCCheckFailed
   ErrorDefinition.InvalidPriceId
   EventDefinition.RedemptionProofAdded
   FunctionDefinition.constructor
   FunctionDefinition._checkRestrictions
   FunctionDefinition.setKYCRequirementGroup
   FunctionDefinition.addRedemptionProof
   FunctionDefinition.setKYCRegistry
   FunctionDefinition.setPriceIdForDeposits
   FunctionDefinition.setPriceIdForRedemptions

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

1: 
   Current order:
   VariableDeclaration.shares
   VariableDeclaration.allowances
   VariableDeclaration.totalShares
   VariableDeclaration.oracle
   VariableDeclaration.ousg
   VariableDeclaration.OUSG_TO_ROUSG_SHARES_MULTIPLIER
   ErrorDefinition.UnwrapTooSmall
   VariableDeclaration.PAUSER_ROLE
   VariableDeclaration.BURNER_ROLE
   VariableDeclaration.CONFIGURER_ROLE
   FunctionDefinition.constructor
   FunctionDefinition.initialize
   FunctionDefinition.__rOUSG_init
   FunctionDefinition.__rOUSG_init_unchained
   EventDefinition.TransferShares
   EventDefinition.OracleSet
   FunctionDefinition.name
   FunctionDefinition.symbol
   FunctionDefinition.decimals
   FunctionDefinition.totalSupply
   FunctionDefinition.balanceOf
   FunctionDefinition.transfer
   FunctionDefinition.allowance
   FunctionDefinition.approve
   FunctionDefinition.transferFrom
   FunctionDefinition.increaseAllowance
   FunctionDefinition.decreaseAllowance
   FunctionDefinition.getTotalShares
   FunctionDefinition.sharesOf
   FunctionDefinition.getSharesByROUSG
   FunctionDefinition.getROUSGByShares
   FunctionDefinition.getOUSGPrice
   FunctionDefinition.transferShares
   FunctionDefinition.wrap
   FunctionDefinition.unwrap
   FunctionDefinition._transfer
   FunctionDefinition._approve
   FunctionDefinition._sharesOf
   FunctionDefinition._transferShares
   FunctionDefinition._mintShares
   FunctionDefinition._burnShares
   FunctionDefinition._beforeTokenTransfer
   FunctionDefinition.setOracle
   FunctionDefinition.burn
   FunctionDefinition.pause
   FunctionDefinition.unpause
   FunctionDefinition.setKYCRegistry
   FunctionDefinition.setKYCRequirementGroup
   
   Suggested order:
   VariableDeclaration.shares
   VariableDeclaration.allowances
   VariableDeclaration.totalShares
   VariableDeclaration.oracle
   VariableDeclaration.ousg
   VariableDeclaration.OUSG_TO_ROUSG_SHARES_MULTIPLIER
   VariableDeclaration.PAUSER_ROLE
   VariableDeclaration.BURNER_ROLE
   VariableDeclaration.CONFIGURER_ROLE
   ErrorDefinition.UnwrapTooSmall
   EventDefinition.TransferShares
   EventDefinition.OracleSet
   FunctionDefinition.constructor
   FunctionDefinition.initialize
   FunctionDefinition.__rOUSG_init
   FunctionDefinition.__rOUSG_init_unchained
   FunctionDefinition.name
   FunctionDefinition.symbol
   FunctionDefinition.decimals
   FunctionDefinition.totalSupply
   FunctionDefinition.balanceOf
   FunctionDefinition.transfer
   FunctionDefinition.allowance
   FunctionDefinition.approve
   FunctionDefinition.transferFrom
   FunctionDefinition.increaseAllowance
   FunctionDefinition.decreaseAllowance
   FunctionDefinition.getTotalShares
   FunctionDefinition.sharesOf
   FunctionDefinition.getSharesByROUSG
   FunctionDefinition.getROUSGByShares
   FunctionDefinition.getOUSGPrice
   FunctionDefinition.transferShares
   FunctionDefinition.wrap
   FunctionDefinition.unwrap
   FunctionDefinition._transfer
   FunctionDefinition._approve
   FunctionDefinition._sharesOf
   FunctionDefinition._transferShares
   FunctionDefinition._mintShares
   FunctionDefinition._burnShares
   FunctionDefinition._beforeTokenTransfer
   FunctionDefinition.setOracle
   FunctionDefinition.burn
   FunctionDefinition.pause
   FunctionDefinition.unpause
   FunctionDefinition.setKYCRegistry
   FunctionDefinition.setKYCRequirementGroup

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

```solidity
File: contracts/ousg/rOUSGFactory.sol

1: 
   Current order:
   VariableDeclaration.DEFAULT_ADMIN_ROLE
   VariableDeclaration.guardian
   VariableDeclaration.rOUSGImplementation
   VariableDeclaration.rOUSGProxyAdmin
   VariableDeclaration.rOUSGProxy
   VariableDeclaration.initialized
   FunctionDefinition.constructor
   FunctionDefinition.deployRebasingOUSG
   FunctionDefinition.multiexcall
   EventDefinition.rOUSGDeployed
   ModifierDefinition.onlyGuardian
   
   Suggested order:
   VariableDeclaration.DEFAULT_ADMIN_ROLE
   VariableDeclaration.guardian
   VariableDeclaration.rOUSGImplementation
   VariableDeclaration.rOUSGProxyAdmin
   VariableDeclaration.rOUSGProxy
   VariableDeclaration.initialized
   EventDefinition.rOUSGDeployed
   ModifierDefinition.onlyGuardian
   FunctionDefinition.constructor
   FunctionDefinition.deployRebasingOUSG
   FunctionDefinition.multiexcall

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)

### <a name="NC-23"></a>[NC-23] Internal and private variables and functions names should begin with an underscore
According to the Solidity Style Guide, Non-`external` variable and function names should begin with an [underscore](https://docs.soliditylang.org/en/latest/style-guide.html#underscore-prefix-for-non-external-functions-and-variables)

*Instances (3)*:
```solidity
File: contracts/ousg/rOUSG.sol

92:   /// @dev Role based access control roles

94:   bytes32 public constant BURNER_ROLE = keccak256("BURN_ROLE");

95:   bytes32 public constant CONFIGURER_ROLE = keccak256("CONFIGURER_ROLE");

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="NC-24"></a>[NC-24] Event is missing `indexed` fields
Index event fields make the field more quickly accessible to off-chain tools that parse events. However, note that each index field costs extra gas during emission, so it's not necessarily best to index the maximum allowed per event (three fields). Each event should use three indexed fields if there are three or more fields, and gas usage is not particularly of concern for the events in question. If there are fewer than three fields, all of the fields should be indexed.

*Instances (3)*:
```solidity
File: contracts/ousg/ousgManager.sol

163: 

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

174:   function symbol() public pure returns (string memory) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

```solidity
File: contracts/ousg/rOUSGFactory.sol

154: 

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)

### <a name="NC-25"></a>[NC-25] `public` functions not called by the contract should be declared `external` instead

*Instances (15)*:
```solidity
File: contracts/ousg/ousg.sol

75:       // Only check KYC if not minting

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousg.sol)

```solidity
File: contracts/ousg/rOUSG.sol

190:       (totalShares * getOUSGPrice()) / (1e18 * OUSG_TO_ROUSG_SHARES_MULTIPLIER);

197:    *      by the price of OUSG

202:       (1e18 * OUSG_TO_ROUSG_SHARES_MULTIPLIER);

206:    * @notice Moves `_amount` tokens from the caller's account to the `_recipient` account.

218:    * @dev The `_amount` argument is the amount of tokens, not shares.

239:    * @notice Sets `_amount` as the allowance of `_spender` over the caller's tokens.

252:     _approve(msg.sender, _spender, _amount);

269:    * - `_sender` and `_recipient` cannot be the zero addresses.

294:    * https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol#L42

320:    * Emits an `Approval` event indicating the updated allowance.

347:   function getTotalShares() public view returns (uint256) {

368:   }

375:       (_shares * getOUSGPrice()) / (1e18 * OUSG_TO_ROUSG_SHARES_MULTIPLIER);

415:   function wrap(uint256 _OUSGAmount) external whenNotPaused {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="NC-26"></a>[NC-26] Variables need not be initialized to zero
The default value for variables is zero, so initializing them to zero is superfluous.

*Instances (4)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

99:   uint256 public mintFee = 0;

102:   uint256 public redeemFee = 0;

804:     for (uint256 i = 0; i < exCallData.length; ++i) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSGFactory.sol

125:     for (uint256 i = 0; i < exCallData.length; ++i) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)


## Low Issues


| |Issue|Instances|
|-|:-|:-:|
| [L-1](#L-1) | `approve()`/`safeApprove()` may revert if the current approval is not zero | 2 |
| [L-2](#L-2) | Some tokens may revert when zero value transfers are made | 8 |
| [L-3](#L-3) | Missing checks for `address(0)` when assigning values to address state variables | 3 |
| [L-4](#L-4) | `decimals()` is not a part of the ERC-20 standard | 6 |
| [L-5](#L-5) | Deprecated approve() function | 2 |
| [L-6](#L-6) | Division by zero not prevented | 5 |
| [L-7](#L-7) | External call recipient may consume all transaction gas | 2 |
| [L-8](#L-8) | Initializers could be front-run | 10 |
| [L-9](#L-9) | Prevent accidentally burning tokens | 9 |
| [L-10](#L-10) | Loss of precision | 7 |
| [L-11](#L-11) | Solidity version 0.8.20+ may not work on other chains due to `PUSH0` | 5 |
| [L-12](#L-12) | Use `Ownable2Step.transferOwnership` instead of `Ownable.transferOwnership` | 1 |
| [L-13](#L-13) | `symbol()` is not a part of the ERC-20 standard | 1 |
| [L-14](#L-14) | Unsafe ERC20 operation(s) | 13 |
| [L-15](#L-15) | Upgradeable contract is missing a `__gap[50]` storage variable to allow for new storage variables in later versions | 17 |
| [L-16](#L-16) | Upgradeable contract not initialized | 32 |
### <a name="L-1"></a>[L-1] `approve()`/`safeApprove()` may revert if the current approval is not zero
- Some tokens (like the *very popular* USDT) do not work when changing the allowance from an existing non-zero allowance value (it will revert if the current approval is not zero to protect against front-running changes of approvals). These tokens must first be approved for zero and then the actual allowance can be approved.
- Furthermore, OZ's implementation of safeApprove would throw an error if an approve is attempted from a non-zero value (`"SafeERC20: approve from non-zero to non-zero allowance"`)

Set the allowance to zero immediately before each of the existing allowance calls

*Instances (2)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

264:     ousg.approve(address(rousg), ousgAmountOut);

464:     buidl.approve(address(buidlRedeemer), buidlAmountToRedeem);

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

### <a name="L-2"></a>[L-2] Some tokens may revert when zero value transfers are made
Example: https://github.com/d-xo/weird-erc20#revert-on-zero-value-transfers.

In spite of the fact that EIP-20 [states](https://github.com/ethereum/EIPs/blob/46b9b698815abbfa628cd1097311deee77dd45c5/EIPS/eip-20.md?plain=1#L116) that zero-valued transfers must be accepted, some tokens, such as LEND will revert if this is attempted, which may cause transactions that involve other tokens (such as batch operations) to fully revert. Consider skipping the transfer if the amount is zero, which will also save gas.

*Instances (8)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

339:     override

342:     returns (uint256 usdcAmountOut)

467:       usdc.balanceOf(address(this)) == usdcBalanceBefore + buidlAmountToRedeem,

473:    * @notice Returns the current price of OUSG in USDC

827: 

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

434:     if (ousgSharesAmount < OUSG_TO_ROUSG_SHARES_MULTIPLIER)

457:     emit Transfer(_sender, _recipient, _amount);

658:   ) external override onlyRole(CONFIGURER_ROLE) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="L-3"></a>[L-3] Missing checks for `address(0)` when assigning values to address state variables

*Instances (3)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

212:     _grantRole(CONFIGURER_ROLE, defaultAdmin);

213:     _grantRole(PAUSER_ROLE, defaultAdmin);

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSGFactory.sol

64:    *         1) Will grant DEFAULT_ADMIN, PAUSER_ROLE, BURNER_ROLE, and CONFIGURER_ROLE to `guardian`

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)

### <a name="L-4"></a>[L-4] `decimals()` is not a part of the ERC-20 standard
The `decimals()` function is not a part of the [ERC-20 standard](https://eips.ethereum.org/EIPS/eip-20), and was added later as an [optional extension](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/IERC20Metadata.sol). As such, some valid ERC20 tokens do not support this interface, so it is unsafe to blindly cast all tokens to this interface, and then call this function.

*Instances (6)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

187:       IERC20Metadata(_ousg).decimals() == IERC20Metadata(_rousg).decimals(),

191:       IERC20Metadata(_usdc).decimals() == IERC20Metadata(_buidl).decimals(),

204:         (IERC20Metadata(_ousg).decimals() - IERC20Metadata(_usdc).decimals());

283:       IERC20Metadata(address(usdc)).decimals() == 6,

392:       IERC20Metadata(address(usdc)).decimals() == 6,

396:       IERC20Metadata(address(buidl)).decimals() == 6,

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

### <a name="L-5"></a>[L-5] Deprecated approve() function
Due to the inheritance of ERC20's approve function, there's a vulnerability to the ERC20 approve and double spend front running attack. Briefly, an authorized spender could spend both allowances by front running an allowance-changing transaction. Consider implementing OpenZeppelin's `.safeApprove()` function to help mitigate this.

*Instances (2)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

287:       usdcAmountIn >= minimumDepositAmount,

482:       price > MINIMUM_OUSG_PRICE,

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

### <a name="L-6"></a>[L-6] Division by zero not prevented
The divisions below take an input parameter which does not have any zero-value checks, which may lead to the functions reverting when zero is passed.

*Instances (5)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

690:     ousgAmountOut = amountE36 / price;

748:     return amount / decimalsMultiplier;

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

190:       (totalShares * getOUSGPrice()) / (1e18 * OUSG_TO_ROUSG_SHARES_MULTIPLIER);

367:       (_rOUSGAmount * 1e18 * OUSG_TO_ROUSG_SHARES_MULTIPLIER) / getOUSGPrice();

375:       (_shares * getOUSGPrice()) / (1e18 * OUSG_TO_ROUSG_SHARES_MULTIPLIER);

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="L-7"></a>[L-7] External call recipient may consume all transaction gas
There is no limit specified on the amount of gas used, so the recipient can use up all of the transaction's gas, causing it to revert. Use `addr.call{gas: <amount>}("")` or [this](https://github.com/nomad-xyz/ExcessivelySafeCall) library instead.

*Instances (2)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

805:       (bool success, bytes memory ret) = address(exCallData[i].target).call{

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSGFactory.sol

126:       (bool success, bytes memory ret) = address(exCallData[i].target).call{

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)

### <a name="L-8"></a>[L-8] Initializers could be front-run
Initializers could be front-run, allowing an attacker to either set their own values, take ownership of the contract, and in the best case forcing a re-deployment

*Instances (10)*:
```solidity
File: contracts/ousg/ousg.sol

52:   function initialize(

57:   ) public initializer {

58:     __ERC20PresetMinterPauser_init(name, symbol);

59:     __KYCRegistryClientInitializable_init(kycRegistry, kycRequirementGroup);

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousg.sol)

```solidity
File: contracts/ousg/rOUSG.sol

102:   function initialize(

108:   ) public virtual initializer {

109:     __rOUSG_init(_kycRegistry, requirementGroup, _ousg, guardian, _oracle);

112:   function __rOUSG_init(

135:     __KYCRegistryClientInitializable_init(_kycRegistry, _requirementGroup);

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

```solidity
File: contracts/ousg/rOUSGFactory.sol

85:     rOUSGProxied.initialize(

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)

### <a name="L-9"></a>[L-9] Prevent accidentally burning tokens
Minting and burning tokens to address(0) prevention

*Instances (9)*:
```solidity
File: contracts/ousg/ousg.sol

95: 

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousg.sol)

```solidity
File: contracts/ousg/ousgInstantManager.sol

257:     external

284:       "OUSGInstantManager::_mint: USDC decimals must be 6"

578:    * @param _minimumDepositAmount The minimum amount required to submit a deposit

579:    *                          request

780:   function pauseRedeem() external onlyRole(PAUSER_ROLE) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

433:     uint256 ousgSharesAmount = getSharesByROUSG(_rOUSGAmount);

456:     _transferShares(_sender, _recipient, _sharesToTransfer);

657:     uint256 group

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="L-10"></a>[L-10] Loss of precision
Division by large numbers may result in the result being zero, due to solidity not supporting fractions. Consider requiring a minimum amount for the numerator to ensure that it is always larger than the denominator

*Instances (7)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

716:     return (usdcAmount * mintFee) / FEE_GRANULARITY;

728:     return (usdcAmount * redeemFee) / FEE_GRANULARITY;

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

190:       (totalShares * getOUSGPrice()) / (1e18 * OUSG_TO_ROUSG_SHARES_MULTIPLIER);

367:       (_rOUSGAmount * 1e18 * OUSG_TO_ROUSG_SHARES_MULTIPLIER) / getOUSGPrice();

375:       (_shares * getOUSGPrice()) / (1e18 * OUSG_TO_ROUSG_SHARES_MULTIPLIER);

439:       ousgSharesAmount / OUSG_TO_ROUSG_SHARES_MULTIPLIER

636:       ousgSharesAmount / OUSG_TO_ROUSG_SHARES_MULTIPLIER

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="L-11"></a>[L-11] Solidity version 0.8.20+ may not work on other chains due to `PUSH0`
The compiler for Solidity 0.8.20 switches the default target EVM version to [Shanghai](https://blog.soliditylang.org/2023/05/10/solidity-0.8.20-release-announcement/#important-note), which includes the new `PUSH0` op code. This op code may not yet be implemented on all L2s, so deployment on these chains will fail. To work around this issue, use an earlier [EVM](https://docs.soliditylang.org/en/v0.8.20/using-the-compiler.html?ref=zaryabs.com#setting-the-evm-version-to-target) [version](https://book.getfoundry.sh/reference/config/solidity-compiler#evm_version). While the project itself may or may not compile with 0.8.20, other projects with which it integrates, or which extend this project may, and those projects will have problems deploying these contracts/libraries.

*Instances (5)*:
```solidity
File: contracts/ousg/ousg.sol

25: /// @notice This token enables transfers to and from addresses that have been KYC'd

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousg.sol)

```solidity
File: contracts/ousg/ousgInstantManager.sol

29: /**

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/ousgManager.sol

37:     uint256 _kycRequirementGroup

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

24: import "contracts/external/openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

```solidity
File: contracts/ousg/rOUSGFactory.sol

30:  *         1) rOUSG - The implementation contract, ERC20 contract with the initializer disabled

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)

### <a name="L-12"></a>[L-12] Use `Ownable2Step.transferOwnership` instead of `Ownable.transferOwnership`
Use [Ownable2Step.transferOwnership](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable2Step.sol) which is safer. Use it as it is more secure due to 2-stage ownership transfer.

**Recommended Mitigation Steps**

Use <a href="https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable2Step.sol">Ownable2Step.sol</a>
  
  ```solidity
      function acceptOwnership() external {
          address sender = _msgSender();
          require(pendingOwner() == sender, "Ownable2Step: caller is not the new owner");
          _transferOwnership(sender);
      }
```

*Instances (1)*:
```solidity
File: contracts/ousg/rOUSGFactory.sol

93:     rOUSGProxyAdmin.transferOwnership(guardian);

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)

### <a name="L-13"></a>[L-13] `symbol()` is not a part of the ERC-20 standard
The `symbol()` function is not a part of the [ERC-20 standard](https://eips.ethereum.org/EIPS/eip-20), and was added later as an [optional extension](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/extensions/IERC20Metadata.sol). As such, some valid ERC20 tokens do not support this interface, so it is unsafe to blindly cast all tokens to this interface, and then call this function.

*Instances (1)*:
```solidity
File: contracts/ousg/rOUSGFactory.sol

101:       rOUSGProxied.symbol()

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)

### <a name="L-14"></a>[L-14] Unsafe ERC20 operation(s)

*Instances (13)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

264:     ousg.approve(address(rousg), ousgAmountOut);

269:     rousg.transfer(msg.sender, rousgAmountOut);

317:       usdc.transferFrom(msg.sender, feeReceiver, usdcfees);

319:     usdc.transferFrom(msg.sender, usdcReceiver, usdcAmountAfterFee);

348:     ousg.transferFrom(msg.sender, address(this), ousgAmountIn);

375:     rousg.transferFrom(msg.sender, address(this), rousgAmountIn);

451:       usdc.transfer(feeReceiver, usdcFees);

455:     usdc.transfer(msg.sender, usdcAmountOut);

464:     buidl.approve(address(buidlRedeemer), buidlAmountToRedeem);

824:     IERC20(token).transfer(to, amount);

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

419:     ousg.transferFrom(msg.sender, address(this), _OUSGAmount);

437:     ousg.transfer(

634:     ousg.transfer(

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="L-15"></a>[L-15] Upgradeable contract is missing a `__gap[50]` storage variable to allow for new storage variables in later versions
See [this](https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps) link for a description of this storage variable. While some contracts may not currently be sub-classed, adding the variable now protects against forgetting to add it in the future.

*Instances (17)*:
```solidity
File: contracts/ousg/ousg.sol

18: import "contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/ERC20PresetMinterPauserUpgradeable.sol";

19: import "contracts/kyc/KYCRegistryClientUpgradeable.sol";

27:   ERC20PresetMinterPauserUpgradeable,

28:   KYCRegistryClientUpgradeable

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousg.sol)

```solidity
File: contracts/ousg/rOUSG.sol

19: import "contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

20: import "contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/IERC20MetadataUpgradeable.sol";

21: import "contracts/external/openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

22: import "contracts/external/openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

23: import "contracts/external/openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

24: import "contracts/external/openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";

25: import "contracts/kyc/KYCRegistryClientUpgradeable.sol";

57:   ContextUpgradeable,

58:   PausableUpgradeable,

59:   AccessControlEnumerableUpgradeable,

60:   KYCRegistryClientUpgradeable,

61:   IERC20Upgradeable,

62:   IERC20MetadataUpgradeable

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="L-16"></a>[L-16] Upgradeable contract not initialized
Upgradeable contracts are initialized via an initializer function rather than by a constructor. Leaving such a contract uninitialized may lead to it being taken over by a malicious user

*Instances (32)*:
```solidity
File: contracts/ousg/ousg.sol

18: import "contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/ERC20PresetMinterPauserUpgradeable.sol";

19: import "contracts/kyc/KYCRegistryClientUpgradeable.sol";

27:   ERC20PresetMinterPauserUpgradeable,

28:   KYCRegistryClientUpgradeable

37:     _disableInitializers();

52:   function initialize(

57:   ) public initializer {

58:     __ERC20PresetMinterPauser_init(name, symbol);

59:     __KYCRegistryClientInitializable_init(kycRegistry, kycRequirementGroup);

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousg.sol)

```solidity
File: contracts/ousg/rOUSG.sol

19: import "contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

20: import "contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/IERC20MetadataUpgradeable.sol";

21: import "contracts/external/openzeppelin/contracts-upgradeable/proxy/Initializable.sol";

22: import "contracts/external/openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol";

23: import "contracts/external/openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

24: import "contracts/external/openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";

25: import "contracts/kyc/KYCRegistryClientUpgradeable.sol";

57:   ContextUpgradeable,

58:   PausableUpgradeable,

59:   AccessControlEnumerableUpgradeable,

60:   KYCRegistryClientUpgradeable,

61:   IERC20Upgradeable,

62:   IERC20MetadataUpgradeable

99:     _disableInitializers();

102:   function initialize(

108:   ) public virtual initializer {

109:     __rOUSG_init(_kycRegistry, requirementGroup, _ousg, guardian, _oracle);

112:   function __rOUSG_init(

135:     __KYCRegistryClientInitializable_init(_kycRegistry, _requirementGroup);

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

```solidity
File: contracts/ousg/rOUSGFactory.sol

45:   bool public initialized = false;

76:     require(!initialized, "ROUSGFactory: rOUSG already deployed");

85:     rOUSGProxied.initialize(

95:     initialized = true;

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSGFactory.sol)


## Medium Issues


| |Issue|Instances|
|-|:-|:-:|
| [M-1](#M-1) | Centralization Risk for trusted owners | 33 |
| [M-2](#M-2) | `increaseAllowance/decreaseAllowance` won't work on mainnet for USDT | 2 |
| [M-3](#M-3) | Return values of `transfer()`/`transferFrom()` not checked | 8 |
| [M-4](#M-4) | Unsafe use of `transfer()`/`transferFrom()` with `IERC20` | 8 |
### <a name="M-1"></a>[M-1] Centralization Risk for trusted owners

#### Impact:
Contracts have owners with privileged rights to perform admin tasks and need to be trusted to not perform malicious updates or drain funds.

*Instances (33)*:
```solidity
File: contracts/ousg/ousg.sol

42:   ) external override onlyRole(KYC_CONFIGURER_ROLE) {

48:   ) external override onlyRole(KYC_CONFIGURER_ROLE) {

91:   function burn(address from, uint256 amount) external onlyRole(BURNER_ROLE) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousg.sol)

```solidity
File: contracts/ousg/ousgInstantManager.sol

52:   AccessControlEnumerable,

500:   ) external override onlyRole(CONFIGURER_ROLE) {

514:   ) external override onlyRole(CONFIGURER_ROLE) {

528:   ) external override onlyRole(CONFIGURER_ROLE) {

542:   ) external override onlyRole(CONFIGURER_ROLE) {

556:   ) external override onlyRole(CONFIGURER_ROLE) {

569:   ) external override onlyRole(CONFIGURER_ROLE) {

583:   ) external override onlyRole(CONFIGURER_ROLE) {

601:   ) external override onlyRole(CONFIGURER_ROLE) {

624:   ) external override onlyRole(DEFAULT_ADMIN_ROLE) {

640:   ) external override onlyRole(DEFAULT_ADMIN_ROLE) {

652:   ) external override onlyRole(DEFAULT_ADMIN_ROLE) {

665:   ) external override onlyRole(DEFAULT_ADMIN_ROLE) {

768:   function pauseMint() external onlyRole(PAUSER_ROLE) {

774:   function unpauseMint() external onlyRole(DEFAULT_ADMIN_ROLE) {

780:   function pauseRedeem() external onlyRole(PAUSER_ROLE) {

786:   function unpauseRedeem() external onlyRole(DEFAULT_ADMIN_ROLE) {

800:     onlyRole(DEFAULT_ADMIN_ROLE)

823:   ) external onlyRole(DEFAULT_ADMIN_ROLE) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/ousgManager.sol

81:   ) external onlyRole(MANAGER_ADMIN) {

98:   ) external onlyRole(REDEMPTION_PROVER_ROLE) checkRestrictions(user) {

121:   ) external onlyRole(MANAGER_ADMIN) {

128:   ) public virtual override onlyRole(PRICE_ID_SETTER_ROLE) {

138:   ) public virtual override onlyRole(PRICE_ID_SETTER_ROLE) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

613:   function setOracle(address _oracle) external onlyRole(DEFAULT_ADMIN_ROLE) {

627:   ) external onlyRole(BURNER_ROLE) {

642:   function pause() external onlyRole(PAUSER_ROLE) {

646:   function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {

652:   ) external override onlyRole(CONFIGURER_ROLE) {

658:   ) external override onlyRole(CONFIGURER_ROLE) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="M-2"></a>[M-2] `increaseAllowance/decreaseAllowance` won't work on mainnet for USDT
On mainnet, the mitigation to be compatible with `increaseAllowance/decreaseAllowance` isn't applied: https://etherscan.io/token/0xdac17f958d2ee523a2206206994597c13d831ec7#code, meaning it reverts on setting a non-zero & non-max allowance, unless the allowance is already zero.

*Instances (2)*:
```solidity
File: contracts/ousg/rOUSG.sol

302:   function increaseAllowance(

328:   function decreaseAllowance(

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="M-3"></a>[M-3] Return values of `transfer()`/`transferFrom()` not checked
Not all `IERC20` implementations `revert()` when there's a failure in `transfer()`/`transferFrom()`. The function signature has a `boolean` return value and they indicate errors that way instead. By not checking the return value, operations that should have marked as failed, may potentially go through without actually making a payment

*Instances (8)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

339:     override

342:     returns (uint256 usdcAmountOut)

467:       usdc.balanceOf(address(this)) == usdcBalanceBefore + buidlAmountToRedeem,

473:    * @notice Returns the current price of OUSG in USDC

827: 

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

434:     if (ousgSharesAmount < OUSG_TO_ROUSG_SHARES_MULTIPLIER)

457:     emit Transfer(_sender, _recipient, _amount);

658:   ) external override onlyRole(CONFIGURER_ROLE) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)

### <a name="M-4"></a>[M-4] Unsafe use of `transfer()`/`transferFrom()` with `IERC20`
Some tokens do not implement the ERC20 standard properly but are still accepted by most code that accepts ERC20 tokens.  For example Tether (USDT)'s `transfer()` and `transferFrom()` functions on L1 do not return booleans as the specification requires, and instead have no return value. When these sorts of tokens are cast to `IERC20`, their [function signatures](https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca) do not match and therefore the calls made, revert (see [this](https://gist.github.com/IllIllI000/2b00a32e8f0559e8f386ea4f1800abc5) link for a test case). Use OpenZeppelin's `SafeERC20`'s `safeTransfer()`/`safeTransferFrom()` instead

*Instances (8)*:
```solidity
File: contracts/ousg/ousgInstantManager.sol

339:     override

342:     returns (uint256 usdcAmountOut)

467:       usdc.balanceOf(address(this)) == usdcBalanceBefore + buidlAmountToRedeem,

473:    * @notice Returns the current price of OUSG in USDC

827: 

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/ousgInstantManager.sol)

```solidity
File: contracts/ousg/rOUSG.sol

434:     if (ousgSharesAmount < OUSG_TO_ROUSG_SHARES_MULTIPLIER)

457:     emit Transfer(_sender, _recipient, _amount);

658:   ) external override onlyRole(CONFIGURER_ROLE) {

```
[Link to code](https://github.com/code-423n4/2024-03-ondo-finance/blob/main/contracts/ousg/rOUSG.sol)
