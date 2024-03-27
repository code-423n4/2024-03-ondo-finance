import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
const { ethers } = require("hardhat");
import Network from "../../../network.config";

const deploy_ommfPricer: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;

  const ommfConfig = Network.addressConfig().OMMF;

  await deploy("OMMF_Pricer", {
    from: deployer,
    contract: "Pricer",
    args: [ommfConfig.PROD_GUARDIAN_OMMF, ommfConfig.PROD_MANAGER_ADMIN_OMMF],
    log: true,
  });
};

deploy_ommfPricer.tags = ["Prod-OMMF-Pricer", "Prod-OMMF-4"];
export default deploy_ommfPricer;
