/**
 * Helper functions related to network configuration.
 * @NOTE: Do not import "hardhat"
 */

import "dotenv/config";

import { DeployFunction } from "hardhat-deploy/types";
import {
  HardhatNetworkForkingUserConfig,
  HardhatRuntimeEnvironment,
} from "hardhat/types";
import { MAINNET_USDY_CONFIG, MAINNET_OMMF_CONFIG } from "./constants/mainnet";
import { USDY_CONFIG, OMMF_CONFIG } from "./constants/constants";
import { MANTLE_OMMF_CONFIG, MANTLE_USDY_CONFIG } from "./constants/mantle";
/**
 * Network Type Config Guide
 * 1. Add XYZ type element below
 * 2. Set XYZ_RPC_URL environment variable
 * 3. Add FORM_FROM_BLOCK_NUMBER_XYZ environment variable
 * 4. Add xyz in hardhat networks config
 * 5. Update env.example file
 */
export type SUPPORTED_NETWORK_TYPE = "MAINNET" | "MANTLE";

const getNetworkType = (): SUPPORTED_NETWORK_TYPE => {
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const hre: HardhatRuntimeEnvironment = require("hardhat");
  return hre.network.live
    ? (hre.network.name.toUpperCase() as SUPPORTED_NETWORK_TYPE)
    : (process.env.FORKING_NETWORK?.toUpperCase() as SUPPORTED_NETWORK_TYPE) ??
        "MAINNET";
};

/**
 * Get RPC URL used to fork a local network.
 * This function is designed to be used for the default forking in hardhat config
 * and tests that require individual forking rather than the default.
 */
const getNetworkForkingConfig = (): HardhatNetworkForkingUserConfig => {
  const forkingNetworkType =
    (process.env.FORKING_NETWORK?.toUpperCase() as SUPPORTED_NETWORK_TYPE) ??
    "MAINNET";
  const rpcEnvVar = `${forkingNetworkType}_RPC_URL`;
  const url = process.env[rpcEnvVar];
  if (!url) {
    throw Error(`Ondo Network Forking Config Error: ${rpcEnvVar} Not Found`);
  }
  const blockEnvVar = `FORK_FROM_BLOCK_NUMBER_${forkingNetworkType}`;
  const block = process.env[blockEnvVar];
  if (!block) {
    throw Error(`Ondo Network Forking Config Error: ${blockEnvVar} Not Found`);
  }
  switch (forkingNetworkType) {
    case "MAINNET":
      return {
        url,
        blockNumber: parseInt(block),
      };
    case "MANTLE":
      return {
        url,
        blockNumber: parseInt(block),
      };
    default:
      break;
  }
  throw Error("Ondo Network Forking Config Error: Unsupported Network");
};

/**
 * Guarantee to deploy contracts only to supported networks.
 * Every deploy script must use this function.
 * @param fn Deploy function
 * @param supportedNetworks Network types where the contracts being deployed to, optional for all network types
 * @returns The deploy function or an empty depending on the supported network
 */
const getNetworkDeployFunction = (
  fn: DeployFunction,
  supportedNetworks?: SUPPORTED_NETWORK_TYPE[]
) => {
  const networkType = getNetworkType();
  if (
    supportedNetworks === undefined ||
    supportedNetworks.includes(networkType)
  )
    return fn;
  return () => {};
};

/**
 * Retrieve pre defined address config depending on the network type.
 */
const getNetworkAddressConfig = (): NetworkAddressConfig => {
  const networkType = getNetworkType();
  const networkAddressConfig = networkAddressConfigs[networkType];
  return networkAddressConfig;
};

const Network = {
  type: getNetworkType,
  forkingConfig: getNetworkForkingConfig,
  deployFunction: getNetworkDeployFunction,
  addressConfig: getNetworkAddressConfig,
};

export default Network;

/**
 * Network Address Config Guide
 * 1. Update the type in constants.ts
 * 2. Set the default value in constants.ts
 * 3. Update address config properly for each network
 */
export type NetworkAddressConfig = {
  USDY: USDY_CONFIG;
  OMMF: OMMF_CONFIG;
};

const networkAddressConfigs: Record<
  SUPPORTED_NETWORK_TYPE,
  NetworkAddressConfig
> = {
  MAINNET: {
    USDY: MAINNET_USDY_CONFIG,
    OMMF: MAINNET_OMMF_CONFIG,
  },
  MANTLE: {
    USDY: MANTLE_USDY_CONFIG,
    OMMF: MANTLE_OMMF_CONFIG,
  },
};
