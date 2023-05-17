import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require("hardhat-abi-exporter");
import "hardhat-gas-reporter";

const config: HardhatUserConfig = {
  solidity: {
  compilers: [
    {
      version: "0.8.4",
      settings: {
        optimizer: {
          enabled: true,
          runs: 99999,
        },
      },
    },
    {
      version: "0.8.17",
      settings: {
        optimizer: {
          enabled: true,
          runs: 99999,
        },
      },
    },
    {
      version: "0.6.6",
      settings: {
        optimizer: {
          enabled: true,
          runs: 99999,
        },
      },
    },
    {
      version: "0.5.16",
      settings: {
        optimizer: {
          enabled: true,
          runs: 99999,
        },
      },
    },
    {
      version: "0.4.18",
      settings: {
        optimizer: {
          enabled: true,
          runs: 99999,
        },
      },
    },
  ],    
  },
  gasReporter: {
    enabled: true,
  },
  abiExporter: {
    path: "./abi/pretty",
    format: "fullName",
  },
};

export default config;
