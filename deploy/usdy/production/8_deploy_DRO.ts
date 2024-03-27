import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { parseUnits } from "ethers/lib/utils";
const { ethers } = require("hardhat");
import Network from "../../../network.config";

const deploy_USDY_DRO: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;

  const usdyConfig = Network.addressConfig().USDY;

  /// @notice UPDATE PRIOR TO DEPLOYMENT!!!!
  const firstRangeStart = 1690848000; // Corresponding to backend UTC Time: Aug 2023
  const firstRangeEnd = 1693526400; // Corresponding to backend UTC Time: Aug 2023
  const dailyIR = parseUnits("1.00013368", 27);
  const rangeStartPrice = parseUnits("1", 18);

  // Static for both variants of USDY
  await deploy("RWADynamicOracle", {
    from: deployer,
    args: [
      usdyConfig.PROD_GUARDIAN_USDY,
      usdyConfig.PROD_DRO_SETTER,
      usdyConfig.PROD_DRO_PAUSER,
      firstRangeStart,
      firstRangeEnd,
      dailyIR,
      rangeStartPrice,
    ],
    log: true,
  });
  if (!usdyConfig.USE_ALLOWLIST) {
    // const oracle = await ethers.getContract("RWADynamicOracle");
    // await oracle.setRange(1696118400, parseUnits("1.00013368", 27)); -- SEPT
    // await oracle.setRange(1698796800, parseUnits("1.00013629", 27)); -- OCT
    // await oracle.setRange(1701388800, parseUnits("1.00013629", 27)); --NOV
    // console.log("Oracle Prices have been pushed to the deployed oracle!");
  }
};
deploy_USDY_DRO.tags = ["Prod-USDY-DRO", "Prod-USDY-8"];
export default deploy_USDY_DRO;
