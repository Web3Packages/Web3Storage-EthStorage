
const fs = require("fs");
const path = require("path");
const { ethers } = require("hardhat");
const { provider, wallet, signer } = require("../connection.js");

const flatDirectoryAbi = require("../package/abi/FlatDirectory.json")


function utf8ArrayToStr(utf8Bytes){
  var unicodeStr ="";
  for (var pos = 0; pos < utf8Bytes.length;){
      var flag= utf8Bytes[pos];
      var unicode = 0 ;
      if ((flag >>>7) === 0 ) {
          unicodeStr+= String.fromCharCode(utf8Bytes[pos]);
          pos += 1;

      } else if ((flag &0xFC) === 0xFC ){
          unicode = (utf8Bytes[pos] & 0x3) << 30;
          unicode |= (utf8Bytes[pos+1] & 0x3F) << 24;
          unicode |= (utf8Bytes[pos+2] & 0x3F) << 18;
          unicode |= (utf8Bytes[pos+3] & 0x3F) << 12;
          unicode |= (utf8Bytes[pos+4] & 0x3F) << 6;
          unicode |= (utf8Bytes[pos+5] & 0x3F);
          unicodeStr+= String.fromCodePoint(unicode) ;
          pos += 6;

      }else if ((flag &0xF8) === 0xF8 ){
          unicode = (utf8Bytes[pos] & 0x7) << 24;
          unicode |= (utf8Bytes[pos+1] & 0x3F) << 18;
          unicode |= (utf8Bytes[pos+2] & 0x3F) << 12;
          unicode |= (utf8Bytes[pos+3] & 0x3F) << 6;
          unicode |= (utf8Bytes[pos+4] & 0x3F);
          unicodeStr+= String.fromCodePoint(unicode) ;
          pos += 5;

      } else if ((flag &0xF0) === 0xF0 ){
          unicode = (utf8Bytes[pos] & 0xF) << 18;
          unicode |= (utf8Bytes[pos+1] & 0x3F) << 12;
          unicode |= (utf8Bytes[pos+2] & 0x3F) << 6;
          unicode |= (utf8Bytes[pos+3] & 0x3F);
          unicodeStr+= String.fromCodePoint(unicode) ;
          pos += 4;

      } else if ((flag &0xE0) === 0xE0 ){
          unicode = (utf8Bytes[pos] & 0x1F) << 12;;
          unicode |= (utf8Bytes[pos+1] & 0x3F) << 6;
          unicode |= (utf8Bytes[pos+2] & 0x3F);
          unicodeStr+= String.fromCharCode(unicode) ;
          pos += 3;

      } else if ((flag &0xC0) === 0xC0 ){ //110
          unicode = (utf8Bytes[pos] & 0x3F) << 6;
          unicode |= (utf8Bytes[pos+1] & 0x3F);
          unicodeStr+= String.fromCharCode(unicode) ;
          pos += 2;

      } else{
          unicodeStr+= String.fromCharCode(utf8Bytes[pos]);
          pos += 1;
      }
  }
  return unicodeStr;
}

  // bytes 0x010f20(input as string "0x010f20") => Uint8Array(3) [ 1, 15, 32 ]
  var byteStrToUint8Array = function(str){
    str = str.replaceAll("0x", "");
    let length = str.length;
    if(length % 2 == 1) throw Error("Invalid string input1");
    /*
    0:48
    9:57

    A:65
    F:70

    a:97
    f:102

    */
    for(let i=0; i<length; i++){
      let num = str[i].charCodeAt();
      if(num < 48 || num >57&&num<65 || num>70&&num<97 || num > 102) throw Error("Invalid string input2");
    }

    let uint8Array = new Uint8Array(length / 2);

    let j=0;
    for(let i=0; i<length; i=i+2){
      let subStr = str.slice(i, i+2);
      uint8Array[j++] = parseInt(subStr, 16);
    }
    return uint8Array;
  }



const FlatDirectoryContract = (contractAddress, ABI) => {
  const Contract = new ethers.Contract(contractAddress, ABI, signer); 
  return Contract;
};


async function read(contractAddress, fileName){

  const hexName = '0x' + Buffer.from(`/${fileName}.txt`, 'utf8').toString('hex');  // 
  
  const contract = FlatDirectoryContract(contractAddress, flatDirectoryAbi);

  const returnByteStr = await contract.getFiles(hexName);
  const returnUint8Array = byteStrToUint8Array(returnByteStr);
  const returnStr = utf8ArrayToStr(returnUint8Array);

  const returnJson = JSON.parse(returnStr);
  const contentEncode = returnJson[fileName.split("@")[0]];
  const contentDecode = decodeURIComponent(contentEncode);
  
  console.log(contentDecode);
}


async function getFileList(contractAddress, fileName){

  const contract = FlatDirectoryContract(contractAddress, flatDirectoryAbi);

  const returnList = await contract.getFullNamesOfAll(fileName.split("@")[0]);

  console.log(returnList);  // [ 'uint8ArrayToByteStr@1.0.1' ]
}



const ContractAddress = "0xf5E92c452BC65073dAD94F3432c15ee1BB840FfF";
const fileNameWithVersion = "uint8ArrayToByteStr@1.0.1";

read(ContractAddress, fileNameWithVersion)

getFileList(ContractAddress, fileNameWithVersion)
