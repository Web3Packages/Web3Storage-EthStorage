// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../ERC5018.sol";
  
contract FlatDirectory is ERC5018 {
    

    bytes public defaultFile = "";

    // slotLimit: 0
    // maxChunkSize: 0
    // storageAddress: 0x0000000000000000000000000000000000000000
    constructor(uint8 slotLimit, uint32 maxChunkSize, address storageAddress) ERC5018(slotLimit, maxChunkSize, storageAddress) {}

    function resolveMode() external pure virtual returns (bytes32) {
        return "manual";
    }
  

    // single file name: name@version.txt (for example: test@1.0.0.txt)
    // name: exclude "_"
    // version: x.x.x (x only num, x<1000_000)
    // single file: pathinfo = bytes("/name@version.txt");
    // multi-files: pathinfo = bytes("/name1@version1_name2@version2_name3@version3.txt");
    fallback(bytes calldata pathinfo) external returns (bytes memory)  {

        StorageHelper.returnBytesInplace(_fallback(pathinfo));
    }

    function _fallback(bytes calldata pathinfo) internal view returns (bytes memory)  {
        string[] memory fullNamesWithoutSuffix;// test@1.2.3
        string[] memory names;  // test
        uint[] memory vertions;  // convert into uint, 1*(1000_000**2) + 2*1000_000 + 3

        (fullNamesWithoutSuffix, names, vertions) = getFileNameInfos(pathinfo);


        bytes[] memory contents = new bytes[](fullNamesWithoutSuffix.length);

        for(uint i=0; i<fullNamesWithoutSuffix.length; i++){
            bytes memory _pathinfo = bytes.concat(bytes(fullNamesWithoutSuffix[i]), bytes(".txt"));
            (contents[i], ) = read(_pathinfo);  // exclude first "/" (0x2f)
        }

        uint lenNames;
        for(uint i=0; i<names.length; i++){
            lenNames += bytes(names[i]).length;
        }

        uint len;
        for(uint i=0; i<contents.length; i++){
            len += contents[i].length;
        }

        len = len + lenNames + names.length * 6 + 1; // {"name1":"0xxx","name2":"0xxx",}
        bytes memory _r =new bytes(len); 
        uint index;
        _r[index++] = 0x7b;  // first "{"
        
        for(uint i=0; i<contents.length; i++){
            _r[index++] = 0x22;  // '"'

            bytes memory _name = bytes(names[i]);
            for(uint j=0; j<_name.length; j++){
                _r[index++] = _name[j];
            }

            // '":"' (0x223a22)
            _r[index++] = 0x22;
            _r[index++] = 0x3a;
            _r[index++] = 0x22;

            uint _len = contents[i].length;
            for(uint j=0; j<_len; j++){
                _r[index++] = contents[i][j];
            }

            // '",' (0x222c)
            _r[index++] = 0x22;
            _r[index++] = 0x2c;
        }

        _r[index-1] = 0x7d;  // last modify to "}"

        return _r;
    }


    function setDefault(bytes memory _defaultFile) public onlyOwner virtual {
        defaultFile = _defaultFile;
    }
}
