import { task } from "hardhat/config";
import {
  BaseProposalRequestParams,
  addContract,
  proposeGrantRole,
  proposeFunctionCall,
  proposeKYCAddressUpdate,
} from "../utils/defender-helper";
import { SUCCESS_CHECK } from "../utils/shell";
import Network from "../../network.config";
import { keccak256, parseUnits } from "ethers/lib/utils";
import { BigNumber } from "ethers";

task(
  "5-ommfManager-prod",
  "Grant MINTER_ROLE to ommfManager, and sets the pricer"
).setAction(async ({}, hre) => {
  const configOMMF = Network.addressConfig().OMMF;
  const name = "OMMFManager";
  const ommfManager = await hre.ethers.getContract(name);
  let params: BaseProposalRequestParams = {
    via: configOMMF.PROD_GUARDIAN_OMMF,
    viaType: "Gnosis Safe",
  };
  const network = await hre.run("getCurrentNetwork");
  const abi = await hre.run("getDeployedContractABI", { contract: name });

  // Add ommfManager to defender
  await addContract(network, ommfManager.address, name, abi);
  console.log(SUCCESS_CHECK + "Added ommfManager to Defender");

  /* --------------------
   * OMMF Roles Begin
   * --------------------
   */

  // ------------------------------------------------------------ //

  // Grant MINTER_ROLE to ommfManager on OMMF
  const ommf = await hre.ethers.getContract("OMMF");
  let ommfContract = {
    network: network,
    address: ommf.address,
  };
  params.title = "Grant MINTER_ROLE to ommfManager on OMMF";
  params.description = "Grant MINTER_ROLE to ommfManager on OMMF";
  await proposeGrantRole({
    params: params,
    contract: ommfContract,
    role: keccak256(Buffer.from("MINTER_ROLE", "utf-8")),
    account: ommfManager.address,
  });
  console.log(
    SUCCESS_CHECK + "Grant ommfManager Proposal submitted to Defender"
  );

  /* --------------------
   * OMMF Roles End
   * --------------------
   */

  // ------------------------------------------------------------ //

  /* --------------------
   * Pricer Configuration Begin
   * --------------------
   */

  const pricer = await hre.ethers.getContract("OMMF_Pricer");

  let pricerContract = {
    network: network,
    address: pricer.address,
  };
  params.title = "Add Price";
  params.description = "Add price in pricer contract";
  await proposeFunctionCall({
    contract: pricerContract,
    params: params,
    functionName: "addPrice",
    functionInterface: [
      {
        type: "uint256",
        name: "price",
      },
      {
        type: "uint256",
        name: "timestamp",
      },
    ],
    functionInputs: [
      parseUnits("1", 18).toString(),
      BigNumber.from(
        (
          await hre.ethers.provider.getBlock("latest")
        ).timestamp
      ).toString(),
    ],
  });
  console.log(SUCCESS_CHECK + "Add Price Proposal submitted to Defender");

  /* --------------------
   * Pricer Configuration End
   * --------------------
   */

  // ------------------------------------------------------------ //

  /* --------------------
   * OMMF Manager Roles Begin
   * --------------------
   */
  let ommfManagerContract = {
    network: network,
    address: ommfManager.address,
  };
  params.title = "Set Pricer";
  params.description = "Set pricer in ommf Manager";
  await proposeFunctionCall({
    contract: ommfManagerContract,
    params: params,
    functionName: "setPricer",
    functionInterface: [
      {
        type: "address",
        name: "newPricer",
      },
    ],
    functionInputs: [pricer.address],
  });
  console.log(SUCCESS_CHECK + "SetPricer Proposal submitted to Defender");

  const PRICER_ROLE = keccak256(Buffer.from("PRICE_ID_SETTER_ROLE", "utf-8"));
  params.title =
    "Grant OMMF Managers PRICE_ID_SETTER_ROLE to Critical multisig";
  params.description = "Grant PRICE_ID_SETTER_ROLE Role to critical multisig";
  await proposeGrantRole({
    params: params,
    contract: ommfManagerContract,
    role: PRICER_ROLE,
    account: configOMMF.PROD_CRITICAL_MULTISIG_OMMF,
  });
  console.log(
    SUCCESS_CHECK + "Grant PRICE_ID_SETTER_ROLE proposed in Defender"
  );

  params.title = "Grant OMMFManager RELAYER_ROLE To Critical multisig";
  params.description = "Grant OMMFManager RELAYER_ROLE To Critical multisig";
  await proposeGrantRole({
    params: params,
    contract: ommfManagerContract,
    role: keccak256(Buffer.from("RELAYER_ROLE", "utf-8")),
    account: configOMMF.PROD_CRITICAL_MULTISIG_OMMF,
  });
  console.log(SUCCESS_CHECK + "Grant RELAYER_ROLE proposed in Defender");

  params.title = "Grant Manager Admin RELAYER_ROLE";
  params.description = "Grant Role to managerAdmin";
  await proposeGrantRole({
    params: params,
    contract: ommfManagerContract,
    role: keccak256(Buffer.from("PAUSER_ADMIN", "utf-8")),
    account: configOMMF.PROD_PAUSER_OMMF,
  });
  console.log(
    SUCCESS_CHECK +
      "Grant OMMF PAUSER_ADMIN to pauser multisig Proposal submitted to defender"
  );

  params.title = "Grant Critical msig REDEMPTION_PROVER_ROLE on OMMFManager ";
  params.description =
    "Grant Critical msig REDEMPTION_PROVER_ROLE on OMMFManager";
  await proposeGrantRole({
    params: params,
    contract: ommfManagerContract,
    role: keccak256(Buffer.from("REDEMPTION_PROVER_ROLE", "utf-8")),
    account: configOMMF.PROD_CRITICAL_MULTISIG_OMMF,
  });
  console.log(
    SUCCESS_CHECK +
      "Grant Critical msig REDEMPTION_PROVER_ROLE on OMMFManager Proposal submitted to defender"
  );

  /* --------------------
   * OMMF Manager Roles End
   * --------------------
   */

  // ------------------------------------------------------------ //

  /* --------------------
   * WOMMF Roles Begin
   * --------------------
   */
  const wommf = await hre.ethers.getContract("WOMMF");
  let wommfContract = {
    network: network,
    address: wommf.address,
  };
  params.title = "Grant WOMMFs PAUSER_ROLE to Pauser Multisig";
  params.description = "Grant Role";
  await proposeGrantRole({
    params: params,
    contract: wommfContract,
    role: keccak256(Buffer.from("PAUSER_ROLE", "utf-8")),
    account: configOMMF.PROD_PAUSER_OMMF,
  });
  console.log(
    SUCCESS_CHECK +
      "Grant WOMMF PAUSER_ROLE to pauser Proposal submitted to defender"
  );

  /* --------------------
   * WOMMF Roles End
   * --------------------
   */
  // ------------------------------------------------------------ //

  /* --------------------
   * KYC Registry Modifications Begin
   * --------------------
   */
  // ------------------------------------------------------------ //
  let registryContract = {
    network: network,
    address: configOMMF.PROD_KYC_REGISTRY,
  };

  params.title =
    "Add WOMMF, Critical multisig, amd ommf manager to KYC Registry";
  params.description =
    "Add WOMMF, Critical multisig, amd ommf manager to KYC Registry";
  await proposeKYCAddressUpdate({
    params: params,
    contract: registryContract,
    functionName: "addKYCAddresses",
    addresses: [
      ommfManager.address,
      wommf.address,
      configOMMF.PROD_CRITICAL_MULTISIG_OMMF,
    ],
    kycRequirementGroup: BigNumber.from(1).toString(),
  });
  console.log(SUCCESS_CHECK + "KYC OMMFManager proposed in defender");

  /* --------------------
   * KYC Registry Modifications End
   * --------------------
   */
  // ------------------------------------------------------------ //
});
