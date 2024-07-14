
const fs = require("fs");
const path = require("path");
const { ethers } = require("hardhat");
const { provider, wallet, signer } = require("../connection.js");

const flatDirectoryAbi = require("../package/abi/FlatDirectory.json")


const FlatDirectoryContract = (contractAddress, ABI) => {
  const Contract = new ethers.Contract(contractAddress, ABI, signer); 
  return Contract;

};



const bufferChunk = (buffer, chunkSize) => {
    let i = 0;
    let result = [];
    const len = buffer.length;
    const chunkLength = Math.ceil(len / chunkSize);
    while (i < len) {
      result.push(buffer.slice(i, i += chunkLength));
    }
  
    return result;
}




async function write(){
  const contractAddress = "0x5d0b47BDD72265C0443D6F96065aA45c24677F04";
  const filePath = './code/';
  // const fileName = "strToUtf8ByteStr@1.0.1";
  const fileName = "uint8ArrayToByteStr@1.0.1";

  const hexName = '0x' + Buffer.from(`${fileName}.txt`, 'utf8').toString('hex');  // 
  
  
  const contract = FlatDirectoryContract(contractAddress, flatDirectoryAbi);
  const contentBuffer = fs.readFileSync(filePath + fileName + ".js"); // <Buffer 0a 20 20 2f 2f 20 ...>
  
  const contentBufferToUtf8Str = encodeURIComponent(contentBuffer);  // <string> %0A%20%20%2F...
  const contentUtf8StrToBuffer = Buffer.from(contentBufferToUtf8Str, "utf8");
  let fileSize = contentUtf8StrToBuffer.length;
  


  // Data need to be sliced if file > 475K
  let chunks = [];
  if (fileSize > 475 * 1024) {
    const chunkSize = Math.ceil(fileSize / (475 * 1024));
    chunks = bufferChunk(contentUtf8StrToBuffer, chunkSize);
    fileSize = fileSize / chunkSize;
  } else {
    chunks.push(contentUtf8StrToBuffer);
  }
  // Files larger than 24k need stak tokens
  let cost = 0;
  if (fileSize > 24 * 1024 - 326) {
    cost = Math.floor((fileSize + 326) / 1024 / 24);
  }



  for (const index in chunks) {
    const chunk = chunks[index];
    const hexData = '0x' + chunk.toString('hex');

    const ifFinal = (index == chunks.length-1)?true:false;
    
    const estimatedGas = await contract.writeChunk.estimateGas(hexName, index, hexData, ifFinal,{value: ethers.parseEther(cost.toString())});
    // upload file
    const option = {
      gasLimit: (estimatedGas * 6n / 5n).toString(),
      value: ethers.parseEther(cost.toString())
    };


    // https://0x5d0b47BDD72265C0443D6F96065aA45c24677F04.11155111.w3link.io/strToUtf8ByteStr@1.0.1.txt
    // https://0x5d0b47BDD72265C0443D6F96065aA45c24677F04.11155111.w3link.io/uint8ArrayToByteStr@1.0.1.txt
    const tx = await contract.writeChunk(hexName, index, hexData,ifFinal, option);
    await tx.wait(1);
    console.log(`File ${fileName}.txt chunkId: ${index} uploaded!`);
  }
}


write()
