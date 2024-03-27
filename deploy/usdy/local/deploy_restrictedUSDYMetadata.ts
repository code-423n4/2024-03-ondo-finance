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
  const signers = await ethers.getSigners();

  await deploy("RestrictedUSDYMetadata", {
    from: deployer,
    args: [signers[1].address, signers[2].address],
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

deployRestrictedUSDYMetadata.tags = ["Local", "RestrictedUSDYMetadata"];
export default deployRestrictedUSDYMetadata;
