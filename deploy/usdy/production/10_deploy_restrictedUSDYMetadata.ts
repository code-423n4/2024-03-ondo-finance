import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import Network from "../../../network.config";
const { ethers } = require("hardhat");

const deployRestrictedUSDYMetadata: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy, save } = deployments;
  const usdyConfig = Network.addressConfig().USDY;

  console.log(
    "Deploying RestrictedUSDYMetadata with manager: ",
    usdyConfig.RESTRICTED_LIST_MANAGER
  );
  console.log("Deploying RestrictedUSDYMetadata with deployer: ", deployer);

  await deploy("RestrictedUSDYMetadata", {
    from: deployer,
    args: [
      usdyConfig.RESTRICTED_LIST_MANAGER,
      usdyConfig.RESTRICTED_LIST_MANAGER,
    ],
    log: true,
  });

  const contract = await ethers.getContract("RestrictedUSDYMetadata");

  console.log(
    `\nThe RestrictedUSDYMetadata is deployed @: ${contract.address}\n`
  );

  let restrictedUSDYMetadata = {
    address: contract,
    ...contract,
  };

  await save("RestrictedUSDYMetadata", restrictedUSDYMetadata);
};

deployRestrictedUSDYMetadata.tags = ["Prod-RestrictedUSDYMetadata"];
export default deployRestrictedUSDYMetadata;
