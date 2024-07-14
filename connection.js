require('dotenv').config();
const {ethers} = require("hardhat");

const RPC_URL = process.env.RPC_ENDPOINT;
const PRIVATE_KEY = process.env.PRIVATE_KEY;

if (!RPC_URL) {
  throw new Error("Please set the RPC_URL environment variable");
}

if (!PRIVATE_KEY) {
  throw new Error("Please set the PRIVATE_KEY environment variable");
}

// const provider = new ethers.providers.JsonRpcProvider(RPC_URL);
const provider = new ethers.JsonRpcProvider(RPC_URL);
const wallet = new ethers.Wallet(PRIVATE_KEY || "UNSET");
const signer = wallet.connect(provider);

module.exports = { provider, wallet, signer };
