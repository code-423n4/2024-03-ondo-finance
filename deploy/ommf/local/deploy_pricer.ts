import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { keccak256, parseUnits } from "ethers/lib/utils";
const { ethers } = require("hardhat");

const deploy_ommfPricer: DeployFunction = async function (
  hre: HardhatRuntimeEnvironment
) {
  const { deployments, getNamedAccounts } = hre;
  const { deployer } = await getNamedAccounts();
  const { deploy } = deployments;
  const signers = await ethers.getSigners();

  const guardian = signers[1];
  const managerAdmin = signers[2];

  await deploy("OMMF_Pricer", {
    from: deployer,
    contract: "Pricer",
    args: [guardian.address, managerAdmin.address],
    log: true,
  });

  const pricer = await ethers.getContract("OMMF_Pricer");
  await pricer.connect(managerAdmin).addPrice(parseUnits("1", 18), "1");

  // Set pricer in rwaHub
  const ommfManager = await ethers.getContract("OMMFManager");
  await ommfManager.connect(managerAdmin).setPricer(pricer.address);

  const ommf = await ethers.getContract("OMMF");
  await ommf
    .connect(guardian)
    .grantRole(
      keccak256(Buffer.from("MINTER_ROLE", "utf-8")),
      ommfManager.address
    );
  await ommf.connect(guardian).setOracle(guardian.address);
};

deploy_ommfPricer.tags = ["Local", "pricer"];
deploy_ommfPricer.dependencies = ["ommfManager"];
export default deploy_ommfPricer;
