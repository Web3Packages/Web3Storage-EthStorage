// SPDX-License-Identifier: MIT



pragma solidity ^0.8.19;

import "./BytesLib.sol";

library LiteralConvertLib{

    // ";" => 0x3b (ascii 59)
    // "0" => 0x30 (ascii 48)
    // "9" => 0x39 (ascii 57)

    // "A" => (ascii 65)
    // "F" => (ascii 70)
    // "X" => (ascii 88) not used

    // "a" => (ascii 97)
    // "f" => (ascii 102)
    // "x" => 0x78 (ascii 120)

    // string "0x....09;0x...88" by ";" split to stringList ["0x...09", "0x...88"]     
    function splitString(string memory _s, string memory _split) internal pure returns(
        string[] memory _stringList
        ){

        require(bytes(_split).length == 1, "split string only accept 1 character");

        bytes memory _b = bytes(_s);
        bytes1 _bsplit = bytes(_split)[0];  // string ";" => bytes1: 0x3b (ascii 59)

        uint256 length = _b.length;
        
        uint256 numberSplit; 

        for(uint256 i=0; i<length; i++){    
            if(_b[i] == _bsplit) numberSplit = numberSplit + 1;    
        }

        _stringList = new string[](numberSplit+1);

        uint256 _indexOfList;
        uint256 _start;
        uint256 _length;
        for(uint256 i=0; i<length; i++){    
            if(_b[i] == _bsplit){
                // store to string list
                if(_length != 0) _stringList[_indexOfList] = string(BytesLib.slice(_b, _start, _length));

                // reset
                _indexOfList = _indexOfList + 1;
                _start = i + 1;
                _length = 0;
                   
            }else{
                _length = _length + 1;
                // last
                if(i == length - 1 && _length != 0) _stringList[_indexOfList] = string(BytesLib.slice(_b, _start, _length));
            }    
        }
    }



    // string "a3" convert to 2 bytes1 (_b0, _b1) => byte1 0xa3
    // only accept 0~9, A~F, a~f
    function _toBytes1(bytes1 _b0, bytes1 _b1) internal pure returns(bytes1){
        uint8 num0 = uint8(_b0);
        uint8 num1 = uint8(_b1);

        uint8 numReturn;

        uint8 _num;

        _num = num0;
        require(_num>=48 && _num<=57 || _num>=65 && _num<=70 || _num>=97 && _num<=102, "bytes error1");
        if(_num>=48 && _num<=57){ // 0~9
            numReturn = (_num-48) * 2**4;
        }else if(_num>=65 && _num<=70){ // A~F
            numReturn = (_num-55) * 2**4;
        }else{ // a~f
            numReturn = (_num-87) * 2**4;
        }

        _num = num1;
        require(_num>=48 && _num<=57 || _num>=65 && _num<=70 || _num>=97 && _num<=102, "bytes error2");
        if(_num>=48 && _num<=57){ // 0~9
            numReturn = numReturn + (_num-48);
        }else if(_num>=65 && _num<=70){ // A~F
            numReturn = numReturn + (_num-55);
        }else{ // a~f
            numReturn = numReturn + (_num-87);
        }

        return bytes1(numReturn);
        
    }


    // string "12345"  => 12345
    // "0" => 0x30 (ascii 48)
    // "9" => 0x39 (ascii 57)
    function getUintFromStringLiteral(string memory _s) internal pure returns(uint256 returnUint){
        bytes memory _b = bytes(_s);
        uint256 length = _b.length;
        for(uint256 i=0; i<length; i++){
            uint8 num = uint8(_b[i]);
            require(num>=48 && num<=57, "incorrect input");
            returnUint = returnUint + uint256(num-48) * 10**(length-1-i);
        }
    }


    // bytes "0x1234" => 1234
    function getUintFromBytesLiteral(bytes memory _b) internal pure returns(uint256 returnUint){
        uint256 length = _b.length;
        for(uint256 i=0; i<length; i++){
            uint8 num = uint8(_b[i]);
            uint8 num0 = num / 2**4;
            uint8 num1 = num % 2**4;
            require(num0 >= 0 && num0 <=9, "incorrect input 1");
            require(num1 >= 0 && num1 <=9, "incorrect input 2");

            returnUint = returnUint + uint256(num0) * 10**(length*2-1-2*i);
            returnUint = returnUint + uint256(num1) * 10**(length*2-2-2*i);
        }
    }



    // string "0xadb...09" => bytes: 0xadb...09
    function getBytesFromStringLiteral(string memory _s) internal pure returns(
        bytes memory
        ){

        bytes memory _b = bytes(_s);
        uint256 length = _b.length;

        // remove prefix "0x"
        if(uint8(_b[0]) == 48 && uint8(_b[1]) == 120) _s = string(BytesLib.slice(_b, 2, length-2));
        
        // reset
        _b = bytes(_s);
        length = _b.length;

        // insure the length of string(without prefix "0x") is a multiple of 2
        if(length % 2 == 1){
            _s = stringConcat("0", _s);  // add "0" to the front
            _b = bytes(_s);
            length = _b.length;
        }

        // convert
        bytes memory _temp = new bytes(length/2);
        uint256 j;
        for(uint256 i=0; i<length; i=i+2){    
            if(uint8(_b[i]) == 48 && uint8(_b[i+1]) == 120)  continue;  // prefix "0x"
            _temp[j++] = _toBytes1(_b[i], _b[i+1]);
        }
        return _temp;
    }

    // string "0xadb...09" => address: 0xadb...09
    function getAddressFromStringLiteral(string memory _s) internal pure returns(address){
        return BytesLib.toAddress(getBytesFromStringLiteral(_s), 0);
    }

    function stringConcat(string memory s1, string memory s2) internal pure returns(string memory){
        bytes memory b1 = bytes(s1);
        bytes memory b2 = bytes(s2);
        bytes memory b = new bytes(b1.length + b2.length);

        uint k;
        for(uint i=0; i<b1.length; i++) b[k++] = b1[i];
        for(uint i=0; i<b2.length; i++) b[k++] = b2[i];

        return string(b);
    }

}