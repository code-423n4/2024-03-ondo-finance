import { task } from "hardhat/config";
import {
  BaseProposalRequestParams,
  addContract,
  proposeGrantRole,
  proposeFunctionCall,
  proposeKYCAddressUpdate,
} from "../../utils/defender-helper";
import { SUCCESS_CHECK } from "../../utils/shell";
import { CONSTANTS } from "../../../deploy/ousg/constants";
import { keccak256 } from "ethers/lib/utils";

task(
  "1-configure-rwahub-upgrade",
  "configure OUSGManager and PricerWithOracle for RWAHub upgrade"
).setAction(async ({}, hre) => {
  const networkHardhat = await hre.run("getCurrentNetwork");
  console.log("network for hardhat: ", networkHardhat);
  const networkDefender = networkHardhat.split("_")[0];
  console.log("network for defender: ", networkDefender);

  // ********** Save new Contracts to Defender **********
  const ousgManager = await hre.ethers.getContract("OUSGManager");
  {
    const ousgManagerABI = await hre.run("getDeployedContractABI", {
      contract: "OUSGManager",
    });
    await addContract(
      networkDefender,
      ousgManager.address,
      "OUSGManager-" + networkHardhat,
      ousgManagerABI
    );
    console.log(SUCCESS_CHECK + "Added OUSGManager to Defender");
  }

  const pricer = await hre.ethers.getContract("PricerWithOracle");
  {
    const pricerABI = await hre.run("getDeployedContractABI", {
      contract: "PricerWithOracle",
    });
    await addContract(
      networkDefender,
      pricer.address,
      "PricerWithOracle-" + networkHardhat,
      pricerABI
    );

    console.log(SUCCESS_CHECK + "Added PricerWithOracle contract to Defender");
  }

  if (networkHardhat != "mainnet_prod") {
    const testOnlyOracle = await hre.ethers.getContract("RWAOracleTestOnly");
    const testOnlyOracleABI = await hre.run("getDeployedContractABI", {
      contract: "RWAOracleTestOnly",
    });
    await addContract(
      networkDefender,
      testOnlyOracle.address,
      "RWAOracleTestOnly-" + networkHardhat,
      testOnlyOracleABI
    );
    console.log(SUCCESS_CHECK + "Added TestOnlyOracle contract to Defender");
  }
  // ********** Propose configuration actions **********
  const baseParams: BaseProposalRequestParams = {
    via: CONSTANTS[networkHardhat]!.OUSG_MANAGER_CONSTRUCTION!
      .MANAGEMENT_MULTISIG!,
    viaType: "Gnosis Safe",
  };
  {
    const msg = "Setting Pricer value in OUSGManager";
    console.log(msg);
    await proposeFunctionCall({
      contract: {
        network: networkDefender,
        address: ousgManager.address,
      },
      params: { ...baseParams, title: msg, description: msg },
      functionName: "setPricer",
      functionInterface: [
        {
          type: "address",
          name: "newPricer",
        },
      ],
      functionInputs: [pricer.address],
    });
    console.log(SUCCESS_CHECK + " " + msg + " submitted to Defender");
  }
  //   {
  //     const msg = "Grant MINTER_ROLE to OUSGManager on OUSG Token";
  //     console.log(msg);
  //     const MINTER_ROLE = keccak256(Buffer.from("MINTER_ROLE", "utf-8"));
  //     await proposeGrantRole({
  //       params: {
  //         ...baseParams,
  //         title: msg,
  //         description: msg,
  //       },
  //       contract: {
  //         network: networkDefender,
  //         address: CONSTANTS[networkHardhat].OUSG_MANAGER_CONSTRUCTION!.OUSG!,
  //       },
  //       role: MINTER_ROLE,
  //       account: ousgManager.address,
  //     });
  //     console.log(SUCCESS_CHECK + " " + msg + " submitted to Defender");
  //   }

  {
    const msg = "Grant RELAYER_ROLE to critical operational Multisig";
    console.log(msg);
    const RELAYER_ROLE = keccak256(Buffer.from("RELAYER_ROLE", "utf-8"));
    await proposeGrantRole({
      params: {
        ...baseParams,
        title: msg,
        description: msg,
      },
      contract: {
        network: networkDefender,
        address: ousgManager.address,
      },
      role: RELAYER_ROLE,
      account: CONSTANTS[networkHardhat].OUSG_CRITICAL_MULTISIG!,
    });
    console.log(SUCCESS_CHECK + " " + msg + " submitted to defender");
  }
  {
    const msg = "Grant RELAYER_ROLE to severe operational Multisig";
    console.log(msg);
    const RELAYER_ROLE = keccak256(Buffer.from("RELAYER_ROLE", "utf-8"));
    await proposeGrantRole({
      params: {
        ...baseParams,
        title: msg,
        description: msg,
      },
      contract: {
        network: networkDefender,
        address: ousgManager.address,
      },
      role: RELAYER_ROLE,
      account: CONSTANTS[networkHardhat].OUSG_SEVERE_MULTISIG!,
    });
    console.log(SUCCESS_CHECK + " " + msg + " submitted to defender");
  }
  {
    const msg =
      "Grant PRICE_ID_SETTER_ROLE to non critical operational Multisig";
    console.log(msg);
    const PRICE_ID_SETTER_ROLE = keccak256(
      Buffer.from("PRICE_ID_SETTER_ROLE", "utf-8")
    );
    await proposeGrantRole({
      params: {
        ...baseParams,
        title: msg,
        description: msg,
      },
      contract: {
        network: networkDefender,
        address: ousgManager.address,
      },
      role: PRICE_ID_SETTER_ROLE,
      account: CONSTANTS[networkHardhat].OUSG_NON_CRITICAL_MULTISIG!,
    });
    console.log(SUCCESS_CHECK + " " + msg + " submitted to defender");
  }
  {
    const msg = "Grant PRICE_ID_SETTER_ROLE to critical operational Multisig";
    console.log(msg);
    const PRICE_ID_SETTER_ROLE = keccak256(
      Buffer.from("PRICE_ID_SETTER_ROLE", "utf-8")
    );
    await proposeGrantRole({
      params: {
        ...baseParams,
        title: msg,
        description: msg,
      },
      contract: {
        network: networkDefender,
        address: ousgManager.address,
      },
      role: PRICE_ID_SETTER_ROLE,
      account: CONSTANTS[networkHardhat].OUSG_CRITICAL_MULTISIG!,
    });
    console.log(SUCCESS_CHECK + " " + msg + " submitted to defender");
  }
  {
    const msg = "Grant ADD_PRICE_OPS_ROLE to non critical operational Multisig";
    console.log(msg);
    const ADD_PRICE_OPS_ROLE = keccak256(
      Buffer.from("ADD_PRICE_OPS_ROLE", "utf-8")
    );
    await proposeGrantRole({
      params: {
        ...baseParams,
        title: msg,
        description: msg,
      },
      contract: {
        network: networkDefender,
        address: pricer.address,
      },
      role: ADD_PRICE_OPS_ROLE,
      account:
        CONSTANTS[networkHardhat].OUSG_PRICER_CONFIGURATION!
          .OPS_PRICE_UPDATE_MULTISIG!,
    });
    console.log(SUCCESS_CHECK + " " + msg + " submitted to defender");
  }

  {
    const msg = "Add new OUSGManager to KYC Registry";
    console.log(msg);
    const registry = await hre.ethers.getContractAt(
      "KYCRegistry",
      CONSTANTS[networkHardhat].OUSG_MANAGER_CONSTRUCTION!.KYC_REGISTRY!
    );
    await proposeKYCAddressUpdate({
      params: {
        ...baseParams,
        title: msg,
        description: msg,
      },
      contract: {
        network: networkDefender,
        address: registry.address,
      },
      functionName: "addKYCAddresses",
      addresses: [ousgManager.address],
      kycRequirementGroup:
        CONSTANTS[
          networkHardhat
        ].OUSG_MANAGER_CONSTRUCTION!.KYC_REQUIREMENT_GROUP!.toString(),
    });
    console.log(SUCCESS_CHECK + " " + msg + " submitted to defender");
  }
});
