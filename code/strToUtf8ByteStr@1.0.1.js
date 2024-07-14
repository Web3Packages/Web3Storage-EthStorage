
  // equal to solidity.bytes(string)
  // string "1234" => bytes 0x31323334(output as string "0x31323334")
  // string "中文" => bytes 0xe4b8ade69687(output as string "0xe4b8ade69687");
  var strToUtf8ByteStr = function(text){
    const code = encodeURIComponent(text);  // string: %E6%88%91
    // console.log(typeof(code), code);
    const bytes = [];  
    for(let i=0; i<code.length;i++){
      const c = code.charAt(i);
      if(c === '%'){
        const hex = code.charAt(i+1) + code.charAt(i+2);
        const hexval = parseInt(hex, 16);
        bytes.push(hexval);
        i += 2;
      } else {
        bytes.push(c.charCodeAt(0));
      }
    }
    // return bytes;  // [230, 123 ...]  // Decimal representation of each byte
    // console.log(bytes);
    let bytesStr = "";
    for(let i=0; i<bytes.length;i++){
      if(bytes[i] < 16){
        bytesStr += "0" + bytes[i].toString(16);
      }else{
        bytesStr += bytes[i].toString(16);
      }
    }
    bytesStr = "0x" + bytesStr;
    return bytesStr;  // "0x31e789..."
  }

