import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { parseUnits } from "ethers/lib/utils";
const { ethers } = require("hardhat");

const deploy_ousgPricer: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  const signers = await ethers.getSigners();

  const guardian = signers[1];
  const managerAdmin = signers[2];
  await deploy("RWAOracleTestOnly", {
    from: deployer,
    contract: "RWAOracleTestOnly",
    args: [guardian.address, parseUnits("1", 18)],
    log: true,
  });

  const testOracle = await ethers.getContract("RWAOracleTestOnly");
  await deploy("PricerWithOracle", {
    from: deployer,
    contract: "PricerWithOracle",
    args: [guardian.address, managerAdmin.address, testOracle.address],
    log: true,
  });
};
deploy_ousgPricer.tags = ["Local", "OUSGPricer"];
export default deploy_ousgPricer;
