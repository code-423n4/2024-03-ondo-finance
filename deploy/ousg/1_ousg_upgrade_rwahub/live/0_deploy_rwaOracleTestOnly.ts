import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { CONSTANTS } from "../../constants";

const deployOUSGTestOracle: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  console.log("deploying from address :", deployer);
  // This should not be defined for mainnet-prod.
  const parameters = CONSTANTS[hre.network.name!].OUSG_TEST_ORACLE_CONSTRUCTION;
  if (
    hre.network.name === "mainnet_prod" ||
    hre.network.name === "matic_prod"
  ) {
    throw new Error(
      "This should not be deployed on mainnet-prod or matic-prod"
    );
  }
  console.log("Constructor Parameters: ", parameters);
  //   RWAOracleTestOnly::constructor(
  //     address owner,
  //     uint256 _startingPrice
  //   )
  await deploy("RWAOracleTestOnly", {
    from: deployer,
    args: [parameters.OWNER_MULTISIG, parameters.START_PRICE],
    log: true,
  });
};

deployOUSGTestOracle.tags = ["OUSGTestOracle-live"];
export default deployOUSGTestOracle;
