// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC5018.sol";
import "./LargeStorageManager.sol";
import "./BlobStorageManager.sol";

import "./LiteralConvertLib.sol";
import "./BytesLib.sol";

contract ERC5018 is IERC5018, LargeStorageManager, BlobStorageManager {

    using LiteralConvertLib for string;
    using BytesLib for bytes;

    mapping(bytes => bool) finalAt;  // bytes("test@1.0.0.txt")
    mapping(string => address) public fileOwner;  // name: "test"
    mapping(string => uint) public latestVersionAt;  // name: "test"
    mapping(string => string[]) public fullNamesOf;  // fullNamesOf["test"] => ["test@1.0.1", "test@1.0.2"];
    

    enum StorageMode {
        Uninitialized,
        OnChain,
        Blob
    }
    mapping(bytes32 => StorageMode) storageModes;

    

    constructor(
        uint8 slotLimit,
        uint32 maxChunkSize,
        address storageAddress
    ) LargeStorageManager(slotLimit) BlobStorageManager(maxChunkSize, storageAddress) {}

    function getStorageMode(bytes memory name) public view returns (StorageMode) {
        return storageModes[keccak256(name)];
    }

    function _setStorageMode(bytes memory name, StorageMode mode) internal {
        storageModes[keccak256(name)] = mode;
    }

    // // Large storage methods
    // function write(bytes memory name, bytes calldata data) public onlyOwner payable virtual override {
    //     // TODO: support multiple chunks
    //     return writeChunk(name, 0, data);
    // }

    // name: bytes("test@1.0.1.txt)
    function read(bytes memory nameWithVersionAndSuffix) public view virtual override returns (bytes memory, bool) {
        require(finalAt[nameWithVersionAndSuffix] == true, "not final");
        StorageMode mode = getStorageMode(nameWithVersionAndSuffix);
        if (mode == StorageMode.Blob) {
            return _getFromBlob(keccak256(nameWithVersionAndSuffix));
        } else if (mode == StorageMode.OnChain) {
            return _get(keccak256(nameWithVersionAndSuffix));
        }
        return (new bytes(0), false);
    }

    // nameWithVersionAndSuffix: bytes("test@1.0.1.txt)
    function getFileHash(bytes memory nameWithVersionAndSuffix) public view returns (bytes32) {
        require(finalAt[nameWithVersionAndSuffix] == true, "not final");
        bytes memory _content;
        bool _bool;
        (_content, _bool) = read(nameWithVersionAndSuffix);
        require(_bool == true, "no file");
        return keccak256(_content);
    }

    // nameWithVersionAndSuffix: bytes("test@1.0.1.txt)
    function size(bytes memory nameWithVersionAndSuffix) public view virtual override returns (uint256, uint256) {
        StorageMode mode = getStorageMode(nameWithVersionAndSuffix);
        if (mode == StorageMode.Blob) {
            return _sizeFromBlob(keccak256(nameWithVersionAndSuffix));
        } else if (mode == StorageMode.OnChain) {
            return _size(keccak256(nameWithVersionAndSuffix));
        }
        return (0, 0);
    }

    // function remove(bytes memory name) public virtual override onlyOwner returns (uint256) {
    //     StorageMode mode = getStorageMode(name);
    //     if (mode == StorageMode.Blob) {
    //         return _removeFromBlob(keccak256(name), 0);
    //     } else if (mode == StorageMode.OnChain) {
    //         return _remove(keccak256(name), 0);
    //     }
    //     return 0;
    // }

    // name: bytes("test@1.0.1.txt)
    function countChunks(bytes memory nameWithVersionAndSuffix) public view virtual override returns (uint256) {
        StorageMode mode = getStorageMode(nameWithVersionAndSuffix);
        if (mode == StorageMode.Blob) {
            return _countChunksFromBlob(keccak256(nameWithVersionAndSuffix));
        } else if (mode == StorageMode.OnChain) {
            return _countChunks(keccak256(nameWithVersionAndSuffix));
        }
        return 0;
    }


    // Chunk-based large storage methods
    // nameWithVersionAndSuffix: bytes("test@1.0.0.txt")
    function writeChunk(
        bytes memory nameWithVersionAndSuffix,
        uint256 chunkId,
        bytes calldata data,
        bool ifFinal
    ) public payable onlyOwner virtual override {
        require(finalAt[nameWithVersionAndSuffix] == false, "final");  // can not modify, expand or remove
        
        string[] memory fullNamesWithoutSuffix; // test@1.2.3
        string[] memory names; // test
        uint[] memory versions;  // convert into uint, 10203

        (fullNamesWithoutSuffix, names, versions) = getFileNameInfos(bytes.concat(bytes("/"), nameWithVersionAndSuffix));
        require(fullNamesWithoutSuffix.length == 1, "only one file");
        

        // first write, set owner
        if(fileOwner[names[0]] == address(0) && chunkId == 0){
            fileOwner[names[0]] = msg.sender;
            require(latestVersionAt[names[0]] < versions[0], "only accept version greater");
            latestVersionAt[names[0]] = versions[0];
        }else{  // only accept expansion
            require(fileOwner[names[0]] == msg.sender,  "only file owner");
            (, uint256 chunkNum) = size(nameWithVersionAndSuffix);
            require(chunkId == chunkNum, "chunkId error");
        }
        if(ifFinal == true) {
            finalAt[nameWithVersionAndSuffix] = true;  // set final
            fullNamesOf[names[0]].push(fullNamesWithoutSuffix[0]);  // store the version
        }

        StorageMode mode = getStorageMode(nameWithVersionAndSuffix);
        require(mode == StorageMode.Uninitialized || mode == StorageMode.OnChain, "Invalid storage mode");
        
        if (mode == StorageMode.Uninitialized) {
            _setStorageMode(nameWithVersionAndSuffix, StorageMode.OnChain);
        }
       
        _putChunkFromCalldata(
            keccak256(nameWithVersionAndSuffix), 
            chunkId, 
            data, 
            msg.value
            );
    }

    // function writeChunks(
    //     bytes calldata name,
    //     uint256[] memory chunkIds,
    //     uint256[] memory sizes
    // ) public onlyOwner override payable {
    //     require(isSupportBlob(), "The current network does not support blob upload");

    //     StorageMode mode = getStorageMode(name);
    //     require(mode == StorageMode.Uninitialized || mode == StorageMode.Blob, "Invalid storage mode");
    //     if (mode == StorageMode.Uninitialized) {
    //         _setStorageMode(name, StorageMode.Blob);
    //     }
    //     _putChunks(keccak256(name), chunkIds, sizes);
    // }

    function readChunk(bytes memory nameWithVersionAndSuffix, uint256 chunkId) public view virtual override returns (bytes memory, bool) {
        StorageMode mode = getStorageMode(nameWithVersionAndSuffix);
        if (mode == StorageMode.Blob) {
            return _getChunkFromBlob(keccak256(nameWithVersionAndSuffix), chunkId);
        } else if (mode == StorageMode.OnChain) {
            return _getChunk(keccak256(nameWithVersionAndSuffix), chunkId);
        }
        return (new bytes(0), false);
    }

    function chunkSize(bytes memory nameWithVersionAndSuffix, uint256 chunkId) public view virtual override returns (uint256, bool) {
        StorageMode mode = getStorageMode(nameWithVersionAndSuffix);
        if (mode == StorageMode.Blob) {
            return _chunkSizeFromBlob(keccak256(nameWithVersionAndSuffix), chunkId);
        } else if (mode == StorageMode.OnChain) {
            return _chunkSize(keccak256(nameWithVersionAndSuffix), chunkId);
        }
        return (0, false);
    }

    // function removeChunk(bytes memory name, uint256 chunkId) public virtual onlyOwner override returns (bool) {
    //     StorageMode mode = getStorageMode(name);
    //     if (mode == StorageMode.Blob) {
    //         return _removeChunkFromBlob(keccak256(name), chunkId);
    //     } else if (mode == StorageMode.OnChain) {
    //         return _removeChunk(keccak256(name), chunkId);
    //     }
    //     return false;
    // }

    function truncate(bytes memory name, uint256 chunkId) public virtual onlyOwner override returns (uint256) {
        StorageMode mode = getStorageMode(name);
        if (mode == StorageMode.Blob) {
            return _removeFromBlob(keccak256(name), chunkId);
        } else if (mode == StorageMode.OnChain) {
            return _remove(keccak256(name), chunkId);
        }
        return 0;
    }

    function refund() public onlyOwner override {
        payable(owner()).transfer(address(this).balance);
    }

    // function destruct() public onlyOwner override {
    //     selfdestruct(payable(owner()));
    // }

    function getChunkHash(bytes memory nameWithVersionAndSuffix, uint256 chunkId) public override view returns (bytes32) {
        StorageMode mode = getStorageMode(nameWithVersionAndSuffix);
        if (mode == StorageMode.Blob) {
            return _getChunkHashFromBlob(keccak256(nameWithVersionAndSuffix), chunkId);
        } else if (mode == StorageMode.OnChain) {
            (bytes memory localData,) = readChunk(nameWithVersionAndSuffix, chunkId);
            return keccak256(localData);
        }
        return 0;
    }

    // name: "test"
    // without suffix and version
    function getFullNamesOfAll(string memory name) public view returns(string[] memory fullNamesWithoutSuffixList){
        uint len = fullNamesOf[name].length;
        return getFullNamesOfRange(name, 0, len-1);
    }

    // [_start, _end]
    function getFullNamesOfRange(string memory name, uint _start, uint _end) public view returns(string[] memory){
        string[] memory fullNamesWithoutSuffixList;

        uint len = fullNamesOf[name].length;

        if(len == 0) return fullNamesWithoutSuffixList;
        
        if(_end > len-1) _end = len-1;

        require(_start <= _end, "range error");

        fullNamesWithoutSuffixList = new string[](_end - _start + 1);

        for(uint i=_start; i<=_end; i++){
            fullNamesWithoutSuffixList[i] = fullNamesOf[name][i];
        }

        return fullNamesWithoutSuffixList;
    }

    
    // pathinfo: /test@1.0.0.txt; /test@1.0.0_test2@1.0.2.txt; 
    function getFileNameInfos(bytes memory pathinfo) public pure returns(
        string[] memory fullNamesWithoutSuffix, // test@1.2.3
        string[] memory names, // test
        uint[] memory versions  // convert into uint,
        ){

        // exclude ".txt" (0x2e747874)
        // exclude first "/" (0x2f)
        uint len = pathinfo.length;
        fullNamesWithoutSuffix = string(pathinfo.slice(1, (len-5))).splitString("_");

        names = new string[](fullNamesWithoutSuffix.length);
        versions = new uint[](fullNamesWithoutSuffix.length);
        for(uint i=0; i<fullNamesWithoutSuffix.length; i++){
            names[i] = fullNamesWithoutSuffix[i].splitString("@")[0];
            require(nameCheck(names[i]) == true, "name error");
            string[] memory _v = fullNamesWithoutSuffix[i].splitString("@")[1].splitString(".");
            require(_v.length == 3, "version error1");
            for(uint j=0; j<_v.length; j++){
                uint _num = _v[j].getUintFromStringLiteral();
                require( _num < 1000000, "version error2");
                versions[i] +=  _num * (1000000**(2-j));  // a.b.c => a*(1000_000**2) + b*1000_000 + c
            }
        }
    }

    // name: "test", "test2"
    function nameCheck(string memory name) public pure returns(bool){
        bytes memory _name = bytes(name);
        uint8 _n;
        for(uint i=0; i<_name.length; i++){
            _n = uint8(_name[i]);
            if(!(_n >= 0x41 && _n <= 0x5a || _n >= 0x61 && _n <= 0x7a || _n >= 0x30 && _n <= 0x39 || _n == 0x2d)) return false;  // "A~Z" || "a~z" || "0~9" || "-"
        }
        return true;
    }
}
