[![Node.js CI](https://github.com/ondoprotocol/rwa-internal/actions/workflows/main.yml/badge.svg?branch=main&event=push)](https://github.com/ondoprotocol/rwa-internal/actions/workflows/main.yml)
# Ondo RWA
Ondo's RWA protocol allows for whitelisted (KYC'd) users to hold exposure to Real World Assets (RWAs) through yield-bearing or rebasing ERC20 tokens.

# OMMF
OMMF (Ondo Money Market Fund) - Is an rebasing ERC20 token that represents one dollar invested within a [Money Market Fund](https://en.wikipedia.org/wiki/Money_market_fund). Income that is generated through the money market fund is passed along to the holders of OMMF through a rebasing mechanism similar to that of stETH. OMMF is designed s.t. 1 OMMF Token represent 1 dollar invested in a money market fund. As a security token, OMMF is subject to the same KYC restrictions as [OUSG](https://docs.ondo.finance/funds-and-cash-management/asset-strategy#ousg-and-ostb).

# USDY
USDY - Is a non-rebasing ERC20 token that represents United States Dollar Yielding deposit. Since this token in non-rebasing the value accrual mechanism occurs exclusively through price appreciation (most similar to [OUSG](https://docs.ondo.finance/funds-and-cash-management/asset-strategy#ousg-and-ostb)). This tokens is not subject to the same KYC requirements as OUSG/OMMF and instead gates transfers based on an allowlist and blocklist.

# Contracts
## RWAHubs
### [RWAHub](contracts/RWAHub.sol)

**The largest and most important contract in the protocol.** RWAHub is an abstract contract which governs the subscription and redemption RWATokens (OMMF/USDY/OUSG) tokens. The contract facilitates giving holders exposure to RWAs by transferring the deposited USDC to 3rd-party custodians. The RWAHub tracks deposits and redemptions linearly. Each deposit and redemption is given a unique subscription or redemption Id which is the numerical value represented as a `bytes32` object.

To mint RWA tokens, a user must send USDC to the contract and call `requestSubscription`. At some point after the funds have been off-ramped and the RWA has been purchased through the custodian, a `priceId` is set by a trusted EOA for a given `depositId` through a call to `setPriceIdForDeposits`. This `priceId` determines the exchange rate between USDC and the desired RWA. Once the exchange rate is set, users can claim their CASH token by calling `claimMint`. The price associated for each `priceId` is stored in the `Pricer.sol` contract. Each RWAHub will have a corresponding pricer. More information on the Pricer is below.

Users can also mint RWA tokens by sending USDC to a specified address. An EOA with the `RELAYER_ROLE` will monitor the off-chain address for deposits and add a proof of the deposit through calling `addProof`. The depositId will be the transaction hash of the transfer that send USDC to the specified address. A `priceId` must also be set for these off-chain deposits. The RWAHub will make **external-calls** to the pricer for retrieving prices on all mints and redemptions.

To redeem a RWA for USDC, users must burn their RWA tokens by calling `requestRedemption`. At some point after the RWA has been sold by the custodian and funds have been on-ramped to USDC, a `priceId` is set for the corresponding `redemptionId` by a trusted EOA through a call to `setPriceIdForRedemptions`. After the `priceId` has been set for a given redemption, the user may claim their USDC through a call to `claimRedemption`.

The base contract that inherits from `RWAHub` must implement the `_checkRestrictions` function which will make the same transfer checks that the RWA itself makes. The reason for this check is to not allow invalid accounts to be able to request subscriptions or claim redemptions of the rwa.

### [RWAHubOffChainRedemptions](contracts/RWAHubOffChainRedemptions.sol)
Is a child contract of RWAHub, which adds functionality to have users request that their redemption be serviced through an off-chain wire transfer.

### [RWAHubInstantMints](contracts/RWAHubInstantMints.sol)
Is a child contract of RWAHub, which adds functionality for instant minting and instant redemption of pegged RWA assets (OMMF). All proceeds from instant redemptions and instant mints are sent/withdrawn from the address designated as the `instantMintAssetManager`. RWAHubInstantMints also implements InstantMintTimeBasedRateLimiter which as the name implies gates the the amount of funds that can pass through the instant mint and instant redemption functions over a period of time. (We are aware that this can be DDOSed, please do not come back with this as a bug).

### [RWAHubNonStableInstantMints](contracts/RWAHubNonStableInstantMints.sol)
Is a child contract of RWAHub, which adds functionality for partial instant minting of non-pegged RWA assets. When a user requests to instantly mint a non-pegged RWA asset, they are minted a set proportion of that asset at the previously set asset price. Once their execution price has been determined, users may claim the remaining portion of their deposit through the `claimExcess` function.

So long as the asset does not appreciate by 10%:
```
1 - .90 (Percent of deposit instantly minted) -> 10%
```
users will not receive more RWA tokens than they ought to.

## [Pricer](contracts/Pricer.sol)
The pricer contract sets priceIds for given prices. The contract expects an rwaOracle contract that confirms to the `IRWAOracleSetter` interface to which the pricer can update prices. Every time a price is added through `addPrice`, the pricer adds a new priceId with an associated price and makes an **external-call** to  `setPrice` in the rwaOracle. If the rwaOracle and pricer are not in sync with their latest prices, the pricer can catch up to the rwaOracle's price with a call to `addLatestOraclePrice`. A priceId of 0 should never be used and clients should revert with a 0 priceId. The `rwaOracles` were audited previously and a link to the report can be found [here](https://drive.google.com/file/d/1hdP63ACMdXz-a70Hu6Kromfnw6ixAx-4/view?usp=sharing) and an abridged version [here](https://hackmd.io/CQf5dztDTzWBu29Qat8X7A?view).

## [SanctionsListClient](contracts/sanctions/SanctionsListClientUpgradeable.sol)
Contracts that want to interface with a SanctionsList can do so by inheriting from `SanctionsListClient` or `SanctionsListClientUpgradeable`. We currently use [Chainalysis sanctions oracle](https://go.chainalysis.com/chainalysis-oracle-docs.html) as the sanctions list.

## Upgradeable Token Architecture & Factories
All Tokens and the allowlist contract in this repo conform to an EIP-1967 Upgradable Proxy convention. Each Token exists as an array of 3 contracts:
- `Proxy.sol`: The proxy contract
- `ProxyAdmin.sol`: The OZ Proxy Admin Contract, given the ability to upgrade the implementation contract of the proxy
- `Implementation`: The Contract to which `proxy.sol` delegate calls to.

These upgradable Proxies are deployed through a `<>_factory.sol` contract, which will handle some of the role transfers, and complete the first step of initialization.

## OMMF

### [OMMF Token](contracts/ommf/ommf_token/ommf.sol)
OMMF is a rebasing token based on the stETH's rebasing mechanism. users are minted some amount of OMMF tokens which internally maps to their % share of `depositedCash`. As yield is accrued to the protocol `depositedCash` will increase and the numerical value of a user's OMMF tokens will increase proportional to the amount of shares a user owns.

OMMF is required to enforce the same transfer restrictions as OUSG. As such only user's who have completed KYC will be allowed to hold, send, or receive the token itself. As such on `transfer` and `transferFrom` the OMMF token (and wrapped variant will check KYC status of `to` and `from` w/n the Ondo [KYCRegistry](https://etherscan.io/address/0x7cE91291846502D50D635163135B2d40a602dc70#code)).

### [OMMF Rebase Setter](contracts/ommf/ommf_token/OMMFRebaseSetter.sol)
As mentioned earlier, yield for OMMF token is passed on through daily rebases. These rebases are set by an a call to `handleOracleReport` in the OMMF token. The `OMMFRebaseSetter` makes calls to the `handleOracleReport` function. This contract, which is based on `RWAOracleRateCheck`, allows an EOA with the `SETTER_ROLE` to set rebases once every 23 hours within 100bps of the `underlyingCash` backing OMMF. For example, if a user mints $100 worth of OMMF, the `underlyingCash` is 100 units and the rebase can be set at 101 or 99.

### [OMMF Manager](contracts/ommf/ommfManager.sol)
The `OMMFManager` is the gateway from minting/redeeming OMMF tokens. The manager allows for instant mints by inheriting from `RWAHubInstantMints`. KYC checks are made within the manager through `_checkRestrictions`. Since OMMF is pegged to $1, there will only be 1 priceId that is used in deployment, that which corresponds to a price of $1 (1e18);

### [WOMMF](contracts/ommf/wrappedOMMF/wOMMF.sol)
wOMMF (Wrapped Ondo Money Market Fund) - Is a non-rebasing variant of OMMF Token. This token uses shares based math to represent ownership of the OMMF token locked within the wOMMF contract. Users may elect to `wrap` their OMMF tokens for wOMMF tokens, or `unwrap` their wOMMF for OMMF tokens. The exchange rate between OMMF and wOMMF is based on the shares of OMMF tokens being burned.

eg: If I have 100 OMMF tokens, which maps to 1 share of OMMF, I will be able to `wrap` these 100 tokens and receive 1 wOMMF token in return.

## USDY

### [USDY Token](contracts/usdy/USDY.sol)
The USDY contract is an upgradeable (Transparent Upgradeable Proxy) with transfer restrictions. USDY is not required to abide by the same transfer restrictions as OUSG/OMMF. In order to hold, send and receive USDY. A user will need to add themselves to the [allowlist](contracts/usdy/allowlist/AllowlistUpgradeable.sol), not be present on the [blocklist](contracts/usdy/blocklist/Blocklist.sol), and not be on a [sanctionsList](https://etherscan.io/address/0x40C57923924B5c5c5455c48D93317139ADDaC8fb).
Thus, every transfer makes an **external-call** to each of these 3 contracts.

### [USDY Manager](contracts/usdy/USDYManager.sol)
The `USDYManager` is the gateway for minting/redeeming USDY tokens. The contract allows for off chain redemptions by inheriting from `RWAHubOffChainRedemptions`. The `_checkRestrictions` function does not check if the account is on the allowlist because the user can always add itself to the allowlist for a given term (see below). The USDY Manager has additional functions to set when a user can claim. For a list of `depositIds`, the `TIMESTAMP_SETTER_ROLE` sets when a user can claim the USDY they have requested to mint. The `_claimMint` function enforces that the timestamp to claim has been passed for the given `depositId`.

### [Allowlist](contracts/usdy/allowlist/AllowlistUpgradeable.sol)
The allowlist is an upgradeable contract that maintains a list of allowed addresses. By default, all contracts pass the allowlist check in `isAllowed`. An EOA is "allowed" if it has added itself to the allowlist for a *valid term*. A term is a string of conditions that the EOA must verify it has read and agreed to. A *valid term* is a term that the `ALLOWLIST_ADMIN` has marked as valid to be on the allowlist with. Valid terms are denoted as an array of `validIndexes` that map to valid terms in the `terms` array. The valid terms are set by the `ALLOWLIST_ADMIN` calling `setValidTermIndexes`. An EOA can add itself to the allowlist either by calling `addSelfToAllowlist` for a given term or by passing in a signature signing a given term through `addAccountToAllowlist`.

Contracts that want to utilize the Allowlist can do so either by inherited `AllowlistClient` or `AllowlistClientUpgradeable` and implementing the method to set the allowlist.

### [Blocklist](contracts/usdy/blocklist/Blocklist.sol)
The blocklist is a non-upgradeable contract that maintains a list of addresses that are blocked from interacting with a set of contracts. Addresses can be added and removed to the blocklist by the owner of the contract. Contracts that want to utilize the Blocklist can do so either by inherited `BlocklistClient` or `BlocklistUpgradeable` and implementing a method to set the blocklist.

## [rUSDY](contracts/usdy/rUSDY.sol)
rUSDY is the rebasing variant of [USDY](https://etherscan.io/address/0x96F6eF951840721AdBF46Ac996b59E0235CB985C) token, and is heavily based on other rebasing tokens such as `stETH`. Users are able to acquire rUSDY tokens by calling the `wrap(uint256)` function on the contract. Where as the price of a single USDY token varies over time, the price of a single rUSDY token is fixed at a price of 1 Dollar, with yield being accrued in the form of additional rUSDY tokens. Similarly when a user wishes to convert their `rUSDY` to `USDY` they are able to call the `unwrap(uint256)` function, and receive their corresponding amount of `USDY`.

In order to determine the USD value of the USDY locked in the contract, rUSDY will call into `RWADynamicRateOracle.sol` in order to fetch the current price.


Because `rUSDY` is the rebasing variant of `USDY` the same transfer restrictions for `USDY` will also be applied to the `rUSDY` token in the `beforeTransfer(address,address,uint256)` hook.

## [RWADynamicRateOracle](contracts/rwaOracles/IRWADynamicOracle.sol)
The RWADynamcRateOracle contract is used to post price evolution for USDY on chain. This contract will accept a [`Range`](https://github.com/code-423n4/2023-09-ondo/blob/main/contracts/rwaOracles/RWADynamicOracle.sol#L295) as input from a trusted admin, and will apply the following conversion to the `lastSetPrice` for a given range:

```
currentPrice = (Range.dailyInterestRate ** (Days Elapsed + 1)) * Range.lastSetPrice
```
When plotted as a function of `block.timestamp`, the resulting plot should look identical to that of [FIG-01](#usdy). There is also functionality within the contract that if a range has elapsed and there is no subsequent range set, the oracle will return the maximum price of the previous range for all `block.timestamp` > `Range.end`

It is also important to note that when setting price's outside of the first range, the admin will only specify the `Range.end` and the `Range.dailyInterestRate` as the other parameters are calculated within the contract.


## [SourceBridge](contracts/bridge/SourceBridge.sol)
This contract is designed to handle calls into the Axelar Gateway for bridging USDY or an RWA token and is to be deployed on the source chain. The contract will burn the bridging token that it supports and foreward over gas along with a payload to the Axelar gas service and Axelar gateway respectively. You can reference the Axelar documentation for more info [*Axelar Docs*](https://docs.axelar.dev/dev/intro).

## [DestinationBridge](contracts/bridge/DestinationBridge.sol)
This contract is designed to handle calls from the Axelar Gateway, and is to be deployed on the destination chain. `DestinationBridge.sol` requires that the address which originates the Axelar message passing is registered with the Receiver contract. Once the message has been received via the Axelar gateway it is queued and will be processed once it has the required number of approvals. The number of approvals corresponding to a transaction can vary based on the source chain and the amount being bridged.

This contract also implements a rate limit that will set a ceiling for the amount of tokens which the Receiver contract can mint over some fixed duration of time.


# Testing and Development

## Setup
- Install Node >= 16
- Run `yarn install`
- Install forge
- Copy `.env.example` to a new file `.env` in the root directory of the repo. Keep the `FORK_FROM_BLOCK_NUMBER_MAINNET` value the same. Fill in a dummy mnemonic and add a RPC_URL to populate `ETHEREUM_RPC_URL`.
- Run `yarn init-repo`

## Commands
- Start a local blockchain: `yarn local-node`
  - The scripts found under `scripts/ci/event_coverage.ts` aim to interact with the contracts in a way that maximizes the count of distinct  event types emitted. For example:

```sh
yarn hardhat run --network localhost scripts/ci/event_coverage.ts
```

- Run Tests: `yarn test-forge`

- Generate Gas Report: `yarn test-forge --gas-report`

## Writing Tests and Forge Scripts
For testing with Foundry, `forge-tests/OMMF_BasicDeployment.sol` & `forge-tests/USDY_BasicDeployment.sol` were added to allow for users to easily deploy and setup the OMMF & USDY protocol for local testing.

To setup and write tests for contracts within foundry from a deployed state please include the following layout within your testing file. Helper functions are provided within each of these respective setup files.
```solidity
pragma solidity 0.8.16;

import "forge-tests/OMMF_BasicDeployment.sol";

contract Test_case_someDescription is OMMF_BasicDeployment {
  function testName() public {
    console.log(ommf.name());
  }
}
```
*Note*:
- Within the foundry tests `address(this)` is given certain permissioned roles. Please use a freshly generated address when writing POC's related to bypassing access controls.

## VS Code
CTRL+Click in Vs Code may not work due to usage of relative and absolute import paths.

## Slither

If you feel inclined to run [slither](https://github.com/crytic/slither), the following command will run it on a specified contract in the repository.

```
slither <Relative Path of Contract> --foundry-out-directory artifactsforge
```
eg
```
slither contracts/bridge/Receiver.sol --foundry-out-directory artifactsforge
```
