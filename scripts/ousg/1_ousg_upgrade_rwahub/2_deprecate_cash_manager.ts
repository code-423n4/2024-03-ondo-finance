import { task } from "hardhat/config";
import {
  BaseProposalRequestParams,
  proposeRevokeRole,
} from "../../utils/defender-helper";
import { SUCCESS_CHECK } from "../../utils/shell";
import { CONSTANTS } from "../../../deploy/ousg/constants";
import { keccak256 } from "ethers/lib/utils";

task(
  "2-deprecate-cash-manager",
  "Deprecate existing CashManager contract and its associated pricer"
).setAction(async ({}, hre) => {
  const networkHardhat = await hre.run("getCurrentNetwork");
  console.log("network for hardhat: ", networkHardhat);
  const networkDefender = networkHardhat.split("_")[0];
  console.log("network for defender: ", networkDefender);
  const baseParams: BaseProposalRequestParams = {
    via: CONSTANTS[networkHardhat]!.OUSG_MANAGER_CONSTRUCTION
      .MANAGEMENT_MULTISIG!,
    viaType: "Gnosis Safe",
  };

  const msg =
    "Deprecate CashManager by revoking MINTER ROLE on OUSG from CashManager";
  const MINTER_ROLE = keccak256(Buffer.from("MINTER_ROLE", "utf-8"));
  await proposeRevokeRole({
    params: {
      ...baseParams,
      title: msg,
      description: msg,
    },
    contract: {
      network: networkDefender,
      address: CONSTANTS[networkHardhat]!.OUSG_MANAGER_CONSTRUCTION!.OUSG!,
    },
    role: MINTER_ROLE,
    account: CONSTANTS[networkHardhat]!.OUSG_DEPRECATED_CASH_MANAGER!,
  });
  console.log(SUCCESS_CHECK + " " + msg + " submitted to Defender");
});
