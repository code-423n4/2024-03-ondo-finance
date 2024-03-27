import { task } from "hardhat/config";
import * as fs from "fs";
// e.g: yarn hardhat output-json --rel-path artifacts/build-info/07e84b7296eac41a83f23020b20d768c.json --contract-name FACTORY
task("output-json", "Get the standard JSON output for UI Contract Verification")
  .addParam("relPath", "The relative path to the build Object")
  .addParam("contractName", "The name of the contract")
  .setAction(async (taskArgs) => {
    let obj = JSON.parse(fs.readFileSync(taskArgs.relPath, "utf-8"));
    fs.writeFileSync(
      `scripts/utils/verification-json/${taskArgs.contractName}.json`,
      JSON.stringify(obj.input),
      "utf-8"
    );
    console.log(
      `✅ Output printed to: scripts/utils/verification-json/${taskArgs.contractName}.json`
    );
  });
