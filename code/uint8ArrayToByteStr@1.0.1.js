
  // Uint8Array([ 1, 15, 32 ]) => bytes 0x010f20(output as string "0x010f20")
  const uint8ArrayToByteStr = function(uint8Array){
    let str ="";
    for(let i=0; i<uint8Array.length; i++){
      let _hex;
      if(uint8Array[i] <= 15){
        _hex = "0" + uint8Array[i].toString(16);
      }else{
        _hex = uint8Array[i].toString(16);
      }
      str = str + _hex;
      
    }
    return "0x" + str;
  }
