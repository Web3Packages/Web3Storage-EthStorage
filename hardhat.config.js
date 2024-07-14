require('hardhat-abi-exporter')
require('dotenv').config()
require("@nomicfoundation/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("@nomicfoundation/hardhat-chai-matchers");

const {PRIVATE_KEY, CHAIN_NAME ,RPC_ENDPOINT} = process.env
 
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  defaultNetwork: CHAIN_NAME,
  networks: {

    local: {
      url: RPC_ENDPOINT,
      accounts: [PRIVATE_KEY],
    },

  },
  solidity: {
    compilers: [
      {
        version: '0.8.20',
        settings: {
          optimizer: {
            enabled: true,
            runs: 999999,
          },
        },
      },
  
    ],
  },
  abiExporter: {
    path: `./package/abi`,
    clear: true,
    flat: true,
    only: ["FlatDirectory"],
    spacing: 2,
    format: 'json',
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY,
  }
}
