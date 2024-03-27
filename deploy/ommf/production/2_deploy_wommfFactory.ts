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
  await deploy("WOMMFFactory", {
    from: deployer,
    args: [ommfConfig.PROD_GUARDIAN_OMMF],
    log: true,
  });
};

deployOMMF_Factory.tags = ["Prod-WOMMF-Factory", "Prod-OMMF-2"];
export default deployOMMF_Factory;
