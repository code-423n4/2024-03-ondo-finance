import { BigNumber } from "ethers";

export type Address = string;

export type USDY_CONFIG = {
  PROD_GUARDIAN_USDY: Address;
  PROD_PAUSER_USDY: Address;
  PROD_ASSET_SENDER_USDY: Address;
  PROD_FEE_RECIPIENT_USDY: Address;
  PROD_MANAGER_ADMIN_USDY: Address;
  USE_ALLOWLIST: Boolean;
  COLLATERAL: Address;
  AXELAR_GATEWAY: Address;
  AXELAR_GAS_SERVICE: Address;
  PROD_SANCTIONS_ADDRESS: Address;
  PROD_BRIDGE_APPROVER_ONDO: Address;
  PROD_DRO_SETTER: Address;
  PROD_DRO_PAUSER: Address;
  RESTRICTED_LIST_MANAGER: Address;
};

export type OMMF_CONFIG = {
  PROD_GUARDIAN_OMMF: Address;
  PROD_ASSET_SENDER_OMMF: Address;
  PROD_FEE_RECIPIENT_OMMF: Address;
  PROD_PAUSER_OMMF: Address;
  PROD_MANAGER_ADMIN_OMMF: Address;
  PROD_INSTANT_MINTER_ADMIN_OMMF: Address;
  PROD_OMMF_KYC_GROUP: String;
  PROD_KYC_REGISTRY: Address;
  COLLATERAL: Address;
  PROD_NON_CRITICAL_MULTISIG_OMMF: Address;
  PROD_CRITICAL_MULTISIG_OMMF: Address;
};

export const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
export const KYC_REGISTRY = "0x7cE91291846502D50D635163135B2d40a602dc70";
export const USDC_MAINNET = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
export const SANCTION_ADDRESS = "0x40c57923924b5c5c5455c48d93317139addac8fb";
