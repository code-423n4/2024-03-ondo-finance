import { task } from "hardhat/config";
import {
  addContract,
  BaseProposalRequestParams,
  proposeFunctionCall,
  proposeGrantRole,
} from "../utils/defender-helper";
import Network from "../../network.config";
import { SUCCESS_CHECK } from "../utils/shell";
import { keccak256 } from "ethers/lib/utils";

task(
  "6-ommfRebaseSetter-prod",
  "Add OMMFRebaseSetter to Defender and set OMMF's oracle value to it"
).setAction(async ({}, hre) => {
  const configOMMF = Network.addressConfig().OMMF;
  const ommfRebaseSetter = await hre.ethers.getContract("OMMF_RebaseSetter");
  const ommfRebaseSetterABI = await hre.run("getDeployedContractABI", {
    contract: "OMMF_RebaseSetter",
  });

  const network = await hre.run("getCurrentNetwork");
  await addContract(
    network,
    ommfRebaseSetter.address,
    "OMMFRebaseSetter",
    ommfRebaseSetterABI
  );
  console.log(SUCCESS_CHECK + "Added OMMFRebaseSetter to defender");
  const ommf = await hre.ethers.getContract("OMMF");
  let ommfContract = {
    network: network,
    address: ommf.address,
  };

  let params: BaseProposalRequestParams = {
    via: configOMMF.PROD_MANAGER_ADMIN_OMMF,
    viaType: "Gnosis Safe",
  };
  params.title = "Set OMMF's Oracle";
  params.description = "Set oracle value in OMMF Contract";

  await proposeFunctionCall({
    contract: ommfContract,
    params: params,
    functionName: "setOracle",
    functionInterface: [
      {
        type: "address",
        name: "_oracle",
      },
    ],
    functionInputs: [ommfRebaseSetter.address],
  });
  console.log(SUCCESS_CHECK + "SetOracle Proposal submitted to Defender");

  params.title = "Grant non-critical msig OPS_SETTER_ROLE ";
  params.description = "Grant non-critical msig OPS_SETTER_ROLE";

  const ommfRebaseSetterContract = {
    network,
    address: ommfRebaseSetter.address,
  };

  await proposeGrantRole({
    params: params,
    contract: ommfRebaseSetterContract,
    role: keccak256(Buffer.from("OPS_SETTER_ROLE", "utf-8")),
    account: configOMMF.PROD_NON_CRITICAL_MULTISIG_OMMF,
  });
  console.log(SUCCESS_CHECK + "Grant non-critical msig OPS_SETTER_ROLE");

  params.title = "Grant critical msig SETTER_ROLE on rebase setter contract ";
  params.description =
    "Grant critical msig SETTER_ROLE on rebase setter contract";
  await proposeGrantRole({
    params: params,
    contract: ommfRebaseSetterContract,
    role: keccak256(Buffer.from("SETTER_ROLE", "utf-8")),
    account: configOMMF.PROD_CRITICAL_MULTISIG_OMMF,
  });
  console.log(SUCCESS_CHECK + "Grant non-critical msig OPS_SETTER_ROLE");
});
