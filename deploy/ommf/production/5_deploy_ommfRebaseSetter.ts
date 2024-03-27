import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
const { ethers } = require("hardhat");
import Network from "../../../network.config";

const deploy_ommfPricer: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const configOMMF = Network.addressConfig().OMMF;
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  const ommf = await ethers.getContract("OMMF");

  await deploy("OMMF_RebaseSetter", {
    from: deployer,
    contract: "OMMFRebaseSetter",
    args: [
      configOMMF.PROD_GUARDIAN_OMMF,
      configOMMF.PROD_MANAGER_ADMIN_OMMF,
      ommf.address,
    ],
    log: true,
  });
};

deploy_ommfPricer.tags = ["Prod-OMMF-RebaseSetter", "Prod-OMMF-5"];
export default deploy_ommfPricer;
