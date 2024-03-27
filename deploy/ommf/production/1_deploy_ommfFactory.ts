import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
const { ethers } = require("hardhat");
import Network from "../../../network.config";

const deployOMMF_Factory: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;

  const ommfConfig = Network.addressConfig().OMMF;

  // Deploy the factory
  await deploy("OMMFFactory", {
    from: deployer,
    args: [ommfConfig.PROD_GUARDIAN_OMMF],
    log: true,
  });
};

deployOMMF_Factory.tags = ["Prod-OMMF-Factory", "Prod-OMMF-1"];
export default deployOMMF_Factory;
