import { task } from "hardhat/config";
import {
  addContract,
  BaseProposalRequestParams,
  proposeFunctionCall,
} from "../utils/defender-helper";
import Network from "../../network.config";
import { SUCCESS_CHECK } from "../utils/shell";

task("1-usdy-prod", "Deploy OMMF from factory contract").setAction(
  async ({}, hre) => {
    const configOMMF = Network.addressConfig().USDY;
    const name = "AllowlistFactory";
    let params: BaseProposalRequestParams = {
      via: configOMMF.PROD_GUARDIAN_USDY,
      viaType: "Gnosis Safe",
    };

    const usdyFactory = await hre.ethers.getContract(name);
    const network = await hre.run("getCurrentNetwork");
    const abi = await hre.run("getDeployedContractABI", { contract: name });

    let contract = {
      network: network,
      address: usdyFactory.address,
    };

    // Add USDY Factory contract to defender
    await addContract(network, usdyFactory.address, name, abi);
    console.log(SUCCESS_CHECK + "Added Allowlist Factory to Defender");

    // Propose the deployment in gnosis defender
    params.title = "Deploy Allowlist";
    params.description = "Deploy Allowlist from factory";
    await proposeFunctionCall({
      contract: contract,
      params: params,
      functionName: "deployAllowlist",
      functionInterface: [
        {
          name: "admin",
          type: "address",
        },
        {
          name: "setter",
          type: "address",
        },
      ],
      functionInputs: [
        configOMMF.PROD_GUARDIAN_USDY,
        configOMMF.PROD_GUARDIAN_USDY,
      ],
    });
    console.log(SUCCESS_CHECK + "Propose Allowlist deploy from factory");
  }
);
