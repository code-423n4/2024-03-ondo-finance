
NB: This report has been created using [Solidity-Metrics](https://github.com/Consensys/solidity-metrics)
<sup>

# Solidity Metrics for Scoping for ondoprotocol - rwa-internal

## Table of contents

- [Scope](#t-scope)
    - [Source Units in Scope](#t-source-Units-in-Scope)
    - [Out of Scope](#t-out-of-scope)
        - [Excluded Source Units](#t-out-of-scope-excluded-source-units)
        - [Duplicate Source Units](#t-out-of-scope-duplicate-source-units)
        - [Doppelganger Contracts](#t-out-of-scope-doppelganger-contracts)
- [Report Overview](#t-report)
    - [Risk Summary](#t-risk)
    - [Source Lines](#t-source-lines)
    - [Inline Documentation](#t-inline-documentation)
    - [Components](#t-components)
    - [Exposed Functions](#t-exposed-functions)
    - [StateVariables](#t-statevariables)
    - [Capabilities](#t-capabilities)
    - [Dependencies](#t-package-imports)
    - [Totals](#t-totals)

## <span id=t-scope>Scope</span>

This section lists files that are in scope for the metrics report.

- **Project:** `Scoping for ondoprotocol - rwa-internal`
- **Included Files:** 
5
- **Excluded Files:** 
212
- **Project analysed:** `https://github.com/ondoprotocol/rwa-internal` (`@1fb114abde88c091bd264a92c8d65a0d37a78069`)

### <span id=t-source-Units-in-Scope>Source Units in Scope</span>

Source Units Analyzed: **`5`**<br>
Source Units in Scope: **`5`** (**100%**)

| Type | File   | Logic Contracts | Interfaces | Lines | nLines | SLOC | Comment Lines | Complex. Score | Capabilities |
| ---- | ------ | --------------- | ---------- | ----- | ------ | ----- | ------------- | -------------- | ------------ |
| 📝 | /contracts/ousg/ousg.sol | 1 | **** | 94 | 81 | 59 | 23 | 41 | **<abbr title='Uses Hash-Functions'>🧮</abbr>** |
| 📝 | /contracts/ousg/ousgInstantManager.sol | 1 | **** | 770 | 689 | 435 | 261 | 284 | **<abbr title='Payable Functions'>💰</abbr><abbr title='Initiates ETH Value Transfer'>📤</abbr><abbr title='Uses Hash-Functions'>🧮</abbr>** |
| 📝 | /contracts/ousg/ousgManager.sol | 1 | **** | 162 | 147 | 94 | 54 | 55 | **<abbr title='Uses Hash-Functions'>🧮</abbr>** |
| 📝 | /contracts/ousg/rOUSG.sol | 1 | **** | 661 | 596 | 305 | 290 | 197 | **<abbr title='Initiates ETH Value Transfer'>📤</abbr><abbr title='Uses Hash-Functions'>🧮</abbr>** |
| 📝 | /contracts/ousg/rOUSGFactory.sol | 1 | **** | 153 | 146 | 77 | 66 | 91 | **<abbr title='Payable Functions'>💰</abbr><abbr title='create/create2'>🌀</abbr>** |
| 📝 | **Totals** | **5** | **** | **1840**  | **1659** | **970** | **694** | **668** | **<abbr title='Payable Functions'>💰</abbr><abbr title='Initiates ETH Value Transfer'>📤</abbr><abbr title='Uses Hash-Functions'>🧮</abbr><abbr title='create/create2'>🌀</abbr>** |

##### <span>Legend</span>
<ul>
<li> <b>Lines</b>: total lines of the source unit </li>
<li> <b>nLines</b>: normalized lines of the source unit (e.g. normalizes functions spanning multiple lines) </li>
<li> <b>SLOC</b>: source lines of code</li>
<li> <b>Comment Lines</b>: lines containing single or block comments </li>
<li> <b>Complexity Score</b>: a custom complexity score derived from code statements that are known to introduce code complexity (branches, loops, calls, external interfaces, ...) </li>
</ul>

### <span id=t-out-of-scope>Out of Scope</span>

### <span id=t-out-of-scope-excluded-source-units>Excluded Source Units</span>
Source Units Excluded: **`212`**

| File |
| ---- |
| /forge-tests/usdy/restrictedUSDYMetadata/RestrictedUSDYMetadata.sol |
| /forge-tests/usdy/allowlist/AllowlistUpgradeable_BasicDeployment.sol |
| /forge-tests/usdy/allowlist/AllowlistUpgradeable.t.sol |
| /forge-tests/usdy/USDYManager.t.sol |
| /forge-tests/usdy/USDY.t.sol |
| /forge-tests/rwaOracles/RWAOracleRateCheck.t.sol |
| /forge-tests/rwaOracles/RWAOracleExternalComparisonCheck.t.sol |
| /forge-tests/rwaOracles/RWADynamicOracle.t.sol |
| /forge-tests/rwaHub/Setters.t.sol |
| /forge-tests/rwaHub/Redemption.t.sol |
| /forge-tests/rwaHub/PricerWithOracle.t.sol |
| /forge-tests/rwaHub/Pricer.t.sol |
| /forge-tests/rwaHub/OffChainRedemption.t.sol |
| /forge-tests/rwaHub/NonStableInstantMinting.t.sol |
| /forge-tests/rwaHub/Minting.t.sol |
| /forge-tests/rwaHub/InstantMinting.t.sol |
| /forge-tests/rusdy/rUSDY_harness.t.sol |
| /forge-tests/rusdy/rUSDY_fuzz.t.sol |
| /forge-tests/rusdy/rUSDY_dynamic.t.sol |
| /forge-tests/postDeploymentConfig/prod_constants.t.sol |
| /forge-tests/postDeploymentConfig/mantle/srcBridge_config.t.sol |
| /forge-tests/postDeploymentConfig/mantle/mUSD_config.t.sol |
| /forge-tests/postDeploymentConfig/mantle/dstBridge_config.t.sol |
| /forge-tests/postDeploymentConfig/mantle/USDY_config.t.sol |
| /forge-tests/postDeploymentConfig/mainnet/usdy_config.t.sol |
| /forge-tests/postDeploymentConfig/mainnet/srcBridge_config.t.sol |
| /forge-tests/postDeploymentConfig/mainnet/rusdy_config.t.sol |
| /forge-tests/postDeploymentConfig/mainnet/ommf_config_staging.t.sol |
| /forge-tests/postDeploymentConfig/mainnet/ommf_config.t.sol |
| /forge-tests/postDeploymentConfig/mainnet/dstBridge_config.t.sol |
| /forge-tests/ousg/rOUSG.t.sol |
| /forge-tests/ousg/RWAOracleTestOnly.t.sol |
| /forge-tests/ousg/OUSGManager.t.sol |
| /forge-tests/ousg/OUSGInstantManager/setters.t.sol |
| /forge-tests/ousg/OUSGInstantManager/retrieve_tokens.t.sol |
| /forge-tests/ousg/OUSGInstantManager/redeem.t.sol |
| /forge-tests/ousg/OUSGInstantManager/mint.t.sol |
| /forge-tests/ousg/OUSGInstantManager/getters.t.sol |
| /forge-tests/ousg/OUSGInstantManager/buildl.t.sol |
| /forge-tests/ousg/OUSGInstantManager/buidl_helper.sol |
| /forge-tests/ommf/wOMMF/wommf.t.sol |
| /forge-tests/ommf/wOMMF/Init.t.sol |
| /forge-tests/ommf/wOMMF/Factory.t.sol |
| /forge-tests/ommf/ommf.t.sol |
| /forge-tests/ommf/ommf.fuzz.t.sol |
| /forge-tests/ommf/OMMFRebaseSetter.t.sol |
| /forge-tests/ommf/OMMFManager.t.sol |
| /forge-tests/helpers/mockUSDC.sol |
| /forge-tests/helpers/events/USDYManagerEvents.sol |
| /forge-tests/helpers/events/SourceBridgeEvents.sol |
| /forge-tests/helpers/events/RWAHubOffChainRedemptionsEvents.sol |
| /forge-tests/helpers/events/RWAHubNonStableInstantMintEvents.sol |
| /forge-tests/helpers/events/RWAHubInstantMintEvents.sol |
| /forge-tests/helpers/events/RWAHubEvents.sol |
| /forge-tests/helpers/events/OUSGManagerEvents.sol |
| /forge-tests/helpers/events/OMMFManagerEvents.sol |
| /forge-tests/helpers/events/OMMFEvents.sol |
| /forge-tests/helpers/events/KYCRegistryClientEvents.sol |
| /forge-tests/helpers/events/ERC20Events.sol |
| /forge-tests/helpers/events/DestinationBridgeEvents.sol |
| /forge-tests/helpers/MockSanctionsOracle.sol |
| /forge-tests/helpers/MockRWAOracle.sol |
| /forge-tests/helpers/MockChainlinkPriceOracle.sol |
| /forge-tests/helpers/MockBUIDLRedeemer.sol |
| /forge-tests/helpers/DeltaCheckHarness.sol |
| /forge-tests/helpers/DSTestPlus.sol |
| /forge-tests/helpers/Constants.sol |
| /forge-tests/bridges/SourceBridge.t.sol |
| /forge-tests/bridges/DestinationBridge.t.sol |
| /forge-tests/USDY_BasicDeployment.sol |
| /forge-tests/OUSG_BasicDeployment.t.sol |
| /forge-tests/OMMF_BasicDeployment.sol |
| /forge-tests/MinimalTestRunner.sol |
| /forge-tests/BaseTestRunner.sol |
| /contracts/usdy/usdyw/USDYWFactory.sol |
| /contracts/usdy/usdyw/USDYW.sol |
| /contracts/usdy/usdy/USDYFactory.sol |
| /contracts/usdy/usdy/USDY.sol |
| /contracts/usdy/rusdyw/rUSDYWFactory.sol |
| /contracts/usdy/rusdyw/rUSDYW.sol |
| /contracts/usdy/rusdy/rUSDYFactory.sol |
| /contracts/usdy/rusdy/rUSDY.sol |
| /contracts/usdy/restrictedUSDYMetadata/RestrictedUSDYMetadata.sol |
| /contracts/usdy/blocklist/BlocklistClientUpgradeable.sol |
| /contracts/usdy/blocklist/BlocklistClient.sol |
| /contracts/usdy/blocklist/Blocklist.sol |
| /contracts/usdy/allowlist/AllowlistUpgradeable.sol |
| /contracts/usdy/allowlist/AllowlistProxy.sol |
| /contracts/usdy/allowlist/AllowlistFactory.sol |
| /contracts/usdy/allowlist/AllowlistClientUpgradeable.sol |
| /contracts/usdy/allowlist/AllowlistClient.sol |
| /contracts/usdy/USDYManager.sol |
| /contracts/test/powUtils.sol |
| /contracts/test/RWAOracleTestOnly.sol |
| /contracts/sanctions/SanctionsListClientUpgradeable.sol |
| /contracts/sanctions/SanctionsListClient.sol |
| /contracts/sanctions/ISanctionsListClient.sol |
| /contracts/rwaOracles/RWAOracleRateCheck.sol |
| /contracts/rwaOracles/RWAOracleExternalComparisonCheck.sol |
| /contracts/rwaOracles/RWADynamicOracle.sol |
| /contracts/rwaOracles/IRWAOracleSetter.sol |
| /contracts/rwaOracles/IRWAOracleExternalComparisonCheck.sol |
| /contracts/rwaOracles/IRWAOracle.sol |
| /contracts/rwaOracles/IRWADynamicOracle.sol |
| /contracts/ommf/wrappedOMMF/wOMMF_factory.sol |
| /contracts/ommf/wrappedOMMF/wOMMF.sol |
| /contracts/ommf/ommf_token/ommf_factory.sol |
| /contracts/ommf/ommf_token/ommf.sol |
| /contracts/ommf/ommf_token/OMMFRebaseSetter.sol |
| /contracts/ommf/ommfManager.sol |
| /contracts/kyc/KYCRegistryClientUpgradeable.sol |
| /contracts/kyc/KYCRegistryClient.sol |
| /contracts/kyc/KYCRegistry.sol |
| /contracts/kyc/IKYCRegistryClient.sol |
| /contracts/kyc/IKYCRegistry.sol |
| /contracts/interfaces/IWommf.sol |
| /contracts/interfaces/IUSDYManager.sol |
| /contracts/interfaces/IUSDY.sol |
| /contracts/interfaces/IRestrictedUSDYMetadata.sol |
| /contracts/interfaces/IRWAOracle.sol |
| /contracts/interfaces/IRWALike.sol |
| /contracts/interfaces/IRWAHubOffChainRedemptions.sol |
| /contracts/interfaces/IRWAHubNonStableInstantMint.sol |
| /contracts/interfaces/IRWAHubInstantMints.sol |
| /contracts/interfaces/IRWAHub.sol |
| /contracts/interfaces/IPricerWithOracle.sol |
| /contracts/interfaces/IPricerReader.sol |
| /contracts/interfaces/IPricer.sol |
| /contracts/interfaces/IOmmf.sol |
| /contracts/interfaces/IOUSGInstantManager.sol |
| /contracts/interfaces/IMulticall.sol |
| /contracts/interfaces/IInvestorBasedRateLimiter.sol |
| /contracts/interfaces/IBlocklistClient.sol |
| /contracts/interfaces/IBlocklist.sol |
| /contracts/interfaces/IBUIDLRedeemer.sol |
| /contracts/interfaces/IAxelarGateway.sol |
| /contracts/interfaces/IAxelarGasService.sol |
| /contracts/interfaces/IAxelarExecutable.sol |
| /contracts/interfaces/IAllowlistClient.sol |
| /contracts/interfaces/IAllowlist.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/utils/IERC165Upgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/utils/EnumerableSetUpgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/utils/ERC165Upgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/utils/CounterUpgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/IERC721ReceiverUpgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/IERC721MetadataUpgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/IERC721EnumerableUpgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721PresetMinterPauserAutoIdUpgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721PausableUpgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721EnumerableUpgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/token/ERC721/ERC721BurnableUpgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/IERC20MetadataUpgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/ERC20PresetMinterPauserUpgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/ERC20PausableUpgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/ERC20BurnableUpgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/proxy/Initializable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/access/IAccessControlUpgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/access/IAccessControlEnumerableUpgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol |
| /contracts/external/openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol |
| /contracts/external/openzeppelin/contracts/utils/cryptography/EIP712.sol |
| /contracts/external/openzeppelin/contracts/utils/cryptography/ECDSA.sol |
| /contracts/external/openzeppelin/contracts/utils/Strings.sol |
| /contracts/external/openzeppelin/contracts/utils/StorageSlot.sol |
| /contracts/external/openzeppelin/contracts/utils/IERC165.sol |
| /contracts/external/openzeppelin/contracts/utils/EnumerableSet.sol |
| /contracts/external/openzeppelin/contracts/utils/ERC165.sol |
| /contracts/external/openzeppelin/contracts/utils/Counters.sol |
| /contracts/external/openzeppelin/contracts/utils/Context.sol |
| /contracts/external/openzeppelin/contracts/utils/Address.sol |
| /contracts/external/openzeppelin/contracts/token/SafeERC20.sol |
| /contracts/external/openzeppelin/contracts/token/IERC20Metadata.sol |
| /contracts/external/openzeppelin/contracts/token/IERC20.sol |
| /contracts/external/openzeppelin/contracts/token/ERC20.sol |
| /contracts/external/openzeppelin/contracts/security/ReentrancyGuard.sol |
| /contracts/external/openzeppelin/contracts/security/Pausable.sol |
| /contracts/external/openzeppelin/contracts/proxy/draft-IERC1822.sol |
| /contracts/external/openzeppelin/contracts/proxy/TransparentUpgradeableProxy.sol |
| /contracts/external/openzeppelin/contracts/proxy/ProxyAdmin.sol |
| /contracts/external/openzeppelin/contracts/proxy/Proxy.sol |
| /contracts/external/openzeppelin/contracts/proxy/IBeacon.sol |
| /contracts/external/openzeppelin/contracts/proxy/ERC1967Upgrade.sol |
| /contracts/external/openzeppelin/contracts/proxy/ERC1967Proxy.sol |
| /contracts/external/openzeppelin/contracts/access/Ownable2Step.sol |
| /contracts/external/openzeppelin/contracts/access/Ownable.sol |
| /contracts/external/openzeppelin/contracts/access/IAccessControlEnumerable.sol |
| /contracts/external/openzeppelin/contracts/access/IAccessControl.sol |
| /contracts/external/openzeppelin/contracts/access/AccessControlEnumerable.sol |
| /contracts/external/openzeppelin/contracts/access/AccessControl.sol |
| /contracts/external/chainlink/AggregatorV3Interface.sol |
| /contracts/external/chainalysis/ISanctionsList.sol |
| /contracts/external/axelar/StringAddressUtils.sol |
| /contracts/external/axelar/AxelarExecutable.sol |
| /contracts/bridge/SourceBridge.sol |
| /contracts/bridge/MintRateLimiter.sol |
| /contracts/bridge/DestinationBridge.sol |
| /contracts/RWAHubOffChainRedemptions.sol |
| /contracts/RWAHubNonStableInstantMints.sol |
| /contracts/RWAHubInstantMints.sol |
| /contracts/RWAHub.sol |
| /contracts/Proxy.sol |
| /contracts/PricerWithOracle.sol |
| /contracts/Pricer.sol |
| /contracts/InstantMintTimeBasedRateLimiter.sol |

## <span id=t-report>Report</span>

## Overview

The analysis finished with **`0`** errors and **`0`** duplicate files.





### <span style="font-weight: bold" id=t-inline-documentation>Inline Documentation</span>

- **Comment-to-Source Ratio:** On average there are`1.4` code lines per comment (lower=better).
- **ToDo's:** `0`

### <span style="font-weight: bold" id=t-components>Components</span>

| 📝Contracts   | 📚Libraries | 🔍Interfaces | 🎨Abstract |
| ------------- | ----------- | ------------ | ---------- |
| 5 | 0  | 0  | 0 |

### <span style="font-weight: bold" id=t-exposed-functions>Exposed Functions</span>

This section lists functions that are explicitly declared public or payable. Please note that getter methods for public stateVars are not included.

| 🌐Public   | 💰Payable |
| ---------- | --------- |
| 59 | 2  |

| External   | Internal | Private | Pure | View |
| ---------- | -------- | ------- | ---- | ---- |
| 37 | 79  | 0 | 3 | 18 |

### <span style="font-weight: bold" id=t-statevariables>StateVariables</span>

| Total      | 🌐Public  |
| ---------- | --------- |
| 39  | 35 |

### <span style="font-weight: bold" id=t-capabilities>Capabilities</span>

| Solidity Versions observed | 🧪 Experimental Features | 💰 Can Receive Funds | 🖥 Uses Assembly | 💣 Has Destroyable Contracts |
| -------------------------- | ------------------------ | -------------------- | ---------------- | ---------------------------- |
| `0.8.16` |  | `yes` | **** | **** |

| 📤 Transfers ETH | ⚡ Low-Level Calls | 👥 DelegateCall | 🧮 Uses Hash Functions | 🔖 ECRecover | 🌀 New/Create/Create2 |
| ---------------- | ----------------- | --------------- | ---------------------- | ------------ | --------------------- |
| `yes` | **** | **** | `yes` | **** | `yes`<br>→ `NewContract:ROUSG`<br/>→ `NewContract:ProxyAdmin`<br/>→ `NewContract:TokenProxy` |

| ♻️ TryCatch | Σ Unchecked |
| ---------- | ----------- |
| **** | **** |

### <span style="font-weight: bold" id=t-package-imports>Dependencies / External Imports</span>

| Dependency / Import Path | Count  |
| ------------------------ | ------ |
| contracts/InstantMintTimeBasedRateLimiter.sol | 1 |
| contracts/Proxy.sol | 1 |
| contracts/RWAHubOffChainRedemptions.sol | 1 |
| contracts/external/openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol | 1 |
| contracts/external/openzeppelin/contracts-upgradeable/proxy/Initializable.sol | 1 |
| contracts/external/openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol | 1 |
| contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/ERC20PresetMinterPauserUpgradeable.sol | 1 |
| contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/IERC20MetadataUpgradeable.sol | 1 |
| contracts/external/openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol | 1 |
| contracts/external/openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol | 1 |
| contracts/external/openzeppelin/contracts/access/AccessControlEnumerable.sol | 1 |
| contracts/external/openzeppelin/contracts/proxy/ProxyAdmin.sol | 1 |
| contracts/external/openzeppelin/contracts/security/ReentrancyGuard.sol | 1 |
| contracts/external/openzeppelin/contracts/token/IERC20.sol | 1 |
| contracts/external/openzeppelin/contracts/token/IERC20Metadata.sol | 1 |
| contracts/interfaces/IBUIDLRedeemer.sol | 1 |
| contracts/interfaces/IInvestorBasedRateLimiter.sol | 1 |
| contracts/interfaces/IMulticall.sol | 2 |
| contracts/interfaces/IOUSGInstantManager.sol | 1 |
| contracts/interfaces/IPricerWithOracle.sol | 1 |
| contracts/interfaces/IRWALike.sol | 1 |
| contracts/kyc/KYCRegistryClient.sol | 1 |
| contracts/kyc/KYCRegistryClientUpgradeable.sol | 2 |
| contracts/ousg/rOUSG.sol | 2 |
| contracts/rwaOracles/IRWAOracle.sol | 1 |


##### Contract Summary

 Sūrya's Description Report

 Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| /contracts/ousg/ousg.sol | 61361c6760778100ec45bb88782580bf5c02a6e7 |
| /contracts/ousg/ousgInstantManager.sol | ff69b43daa114f9baef58041d8343f736e4d005b |
| /contracts/ousg/ousgManager.sol | 703c15e7a2b5332b6ea19cbaedce90a2c19f84cd |
| /contracts/ousg/rOUSG.sol | 22cbb571b03e9c57697ed2ee6f4cdfdaaf2c0148 |
| /contracts/ousg/rOUSGFactory.sol | fb4a806b27a132f863fbfa843b64fc38a9adb7a7 |


 Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **CashKYCSenderReceiver** | Implementation | ERC20PresetMinterPauserUpgradeable, KYCRegistryClientUpgradeable |||
| └ | <Constructor> | Public ❗️ | 🛑  |NO❗️ |
| └ | setKYCRequirementGroup | External ❗️ | 🛑  | onlyRole |
| └ | setKYCRegistry | External ❗️ | 🛑  | onlyRole |
| └ | initialize | Public ❗️ | 🛑  | initializer |
| └ | _beforeTokenTransfer | Internal 🔒 | 🛑  | |
| └ | burn | External ❗️ | 🛑  | onlyRole |
||||||
| **OUSGInstantManager** | Implementation | ReentrancyGuard, InstantMintTimeBasedRateLimiter, AccessControlEnumerable, IOUSGInstantManager, IMulticall |||
| └ | <Constructor> | Public ❗️ | 🛑  | InstantMintTimeBasedRateLimiter |
| └ | mint | External ❗️ | 🛑  | nonReentrant whenMintNotPaused |
| └ | mintRebasingOUSG | External ❗️ | 🛑  | nonReentrant whenMintNotPaused |
| └ | _mint | Internal 🔒 | 🛑  | |
| └ | redeem | External ❗️ | 🛑  | nonReentrant whenRedeemNotPaused |
| └ | redeemRebasingOUSG | External ❗️ | 🛑  | nonReentrant whenRedeemNotPaused |
| └ | _redeem | Internal 🔒 | 🛑  | |
| └ | getOUSGPrice | Public ❗️ |   |NO❗️ |
| └ | setInstantMintLimit | External ❗️ | 🛑  | onlyRole |
| └ | setInstantRedemptionLimit | External ❗️ | 🛑  | onlyRole |
| └ | setInstantMintLimitDuration | External ❗️ | 🛑  | onlyRole |
| └ | setInstantRedemptionLimitDuration | External ❗️ | 🛑  | onlyRole |
| └ | setMintFee | External ❗️ | 🛑  | onlyRole |
| └ | setRedeemFee | External ❗️ | 🛑  | onlyRole |
| └ | setMinimumDepositAmount | External ❗️ | 🛑  | onlyRole |
| └ | setMinimumRedemptionAmount | External ❗️ | 🛑  | onlyRole |
| └ | setOracle | External ❗️ | 🛑  | onlyRole |
| └ | setFeeReceiver | External ❗️ | 🛑  | onlyRole |
| └ | setInvestorBasedRateLimiter | External ❗️ | 🛑  | onlyRole |
| └ | _getMintAmount | Internal 🔒 |   | |
| └ | _getRedemptionAmount | Internal 🔒 |   | |
| └ | _getInstantMintFees | Internal 🔒 |   | |
| └ | _getInstantRedemptionFees | Internal 🔒 |   | |
| └ | _scaleUp | Internal 🔒 |   | |
| └ | _scaleDown | Internal 🔒 |   | |
| └ | pauseMint | External ❗️ | 🛑  | onlyRole |
| └ | unpauseMint | External ❗️ | 🛑  | onlyRole |
| └ | pauseRedeem | External ❗️ | 🛑  | onlyRole |
| └ | unpauseRedeem | External ❗️ | 🛑  | onlyRole |
| └ | multiexcall | External ❗️ |  💵 | onlyRole |
| └ | retrieveTokens | External ❗️ | 🛑  | onlyRole |
||||||
| **OUSGManager** | Implementation | RWAHubOffChainRedemptions, KYCRegistryClient |||
| └ | <Constructor> | Public ❗️ | 🛑  | RWAHubOffChainRedemptions |
| └ | _checkRestrictions | Internal 🔒 |   | |
| └ | setKYCRequirementGroup | External ❗️ | 🛑  | onlyRole |
| └ | addRedemptionProof | External ❗️ | 🛑  | onlyRole checkRestrictions |
| └ | setKYCRegistry | External ❗️ | 🛑  | onlyRole |
| └ | setPriceIdForDeposits | Public ❗️ | 🛑  | onlyRole |
| └ | setPriceIdForRedemptions | Public ❗️ | 🛑  | onlyRole |
||||||
| **ROUSG** | Implementation | Initializable, ContextUpgradeable, PausableUpgradeable, AccessControlEnumerableUpgradeable, KYCRegistryClientUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable |||
| └ | <Constructor> | Public ❗️ | 🛑  |NO❗️ |
| └ | initialize | Public ❗️ | 🛑  | initializer |
| └ | __rOUSG_init | Internal 🔒 | 🛑  | onlyInitializing |
| └ | __rOUSG_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | name | Public ❗️ |   |NO❗️ |
| └ | symbol | Public ❗️ |   |NO❗️ |
| └ | decimals | Public ❗️ |   |NO❗️ |
| └ | totalSupply | Public ❗️ |   |NO❗️ |
| └ | balanceOf | Public ❗️ |   |NO❗️ |
| └ | transfer | Public ❗️ | 🛑  |NO❗️ |
| └ | allowance | Public ❗️ |   |NO❗️ |
| └ | approve | Public ❗️ | 🛑  |NO❗️ |
| └ | transferFrom | Public ❗️ | 🛑  |NO❗️ |
| └ | increaseAllowance | Public ❗️ | 🛑  |NO❗️ |
| └ | decreaseAllowance | Public ❗️ | 🛑  |NO❗️ |
| └ | getTotalShares | Public ❗️ |   |NO❗️ |
| └ | sharesOf | Public ❗️ |   |NO❗️ |
| └ | getSharesByROUSG | Public ❗️ |   |NO❗️ |
| └ | getROUSGByShares | Public ❗️ |   |NO❗️ |
| └ | getOUSGPrice | Public ❗️ |   |NO❗️ |
| └ | transferShares | Public ❗️ | 🛑  |NO❗️ |
| └ | wrap | External ❗️ | 🛑  | whenNotPaused |
| └ | unwrap | External ❗️ | 🛑  | whenNotPaused |
| └ | _transfer | Internal 🔒 | 🛑  | |
| └ | _approve | Internal 🔒 | 🛑  | whenNotPaused |
| └ | _sharesOf | Internal 🔒 |   | |
| └ | _transferShares | Internal 🔒 | 🛑  | whenNotPaused |
| └ | _mintShares | Internal 🔒 | 🛑  | whenNotPaused |
| └ | _burnShares | Internal 🔒 | 🛑  | whenNotPaused |
| └ | _beforeTokenTransfer | Internal 🔒 |   | |
| └ | setOracle | External ❗️ | 🛑  | onlyRole |
| └ | burn | External ❗️ | 🛑  | onlyRole |
| └ | pause | External ❗️ | 🛑  | onlyRole |
| └ | unpause | External ❗️ | 🛑  | onlyRole |
| └ | setKYCRegistry | External ❗️ | 🛑  | onlyRole |
| └ | setKYCRequirementGroup | External ❗️ | 🛑  | onlyRole |
||||||
| **ROUSGFactory** | Implementation | IMulticall |||
| └ | <Constructor> | Public ❗️ | 🛑  |NO❗️ |
| └ | deployRebasingOUSG | External ❗️ | 🛑  | onlyGuardian |
| └ | multiexcall | External ❗️ |  💵 | onlyGuardian |


 Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |

____

