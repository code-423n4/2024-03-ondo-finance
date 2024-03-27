import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";

import { CONSTANTS } from "../../constants";

const deployOUSGPricer: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  console.log("deploying from address :", deployer);
  const parameters = CONSTANTS[hre.network.name!].OUSG_PRICER_CONSTRUCTION;
  console.log("Constructor Parameters: ", parameters);
  //   PricerWithOracle::constructor(
  //     address admin,
  //     address priceSetter,
  //     address _rwaOracle
  //   )
  await deploy("PricerWithOracle", {
    from: deployer,
    contract: "PricerWithOracle",
    args: [
      parameters.MANAGEMENT_MULTISIG,
      parameters.PRICE_UPDATE_MULTISIG,
      parameters.OUSG_ORACLE,
    ],
    log: true,
  });
};

deployOUSGPricer.tags = ["PricerWithOracle-OUSG-live"];
export default deployOUSGPricer;
