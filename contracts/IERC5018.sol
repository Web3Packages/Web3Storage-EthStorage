// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC5018 {
    // Large storage methods
    // function write(bytes memory name, bytes memory data) external payable;

    function read(bytes memory nameWithVersionAndSuffix) external view returns (bytes memory, bool);

    // return (size, # of chunks)
    function size(bytes memory nameWithVersionAndSuffix) external view returns (uint256, uint256);

    // function remove(bytes memory name) external returns (uint256);

    function countChunks(bytes memory nameWithVersionAndSuffix) external view returns (uint256);

    // Chunk-based large storage methods
    function writeChunk(
        bytes memory nameWithVersionAndSuffix,
        uint256 chunkId,
        bytes memory data,
        bool ifFinal
    ) external payable;

    // function writeChunks(bytes memory name, uint256[] memory chunkIds, uint256[] memory sizes) external payable;

    function readChunk(bytes memory nameWithVersionAndSuffix, uint256 chunkId) external view returns (bytes memory, bool);

    function chunkSize(bytes memory nameWithVersionAndSuffix, uint256 chunkId) external view returns (uint256, bool);

    // function removeChunk(bytes memory name, uint256 chunkId) external returns (bool);

    function truncate(bytes memory name, uint256 chunkId) external returns (uint256);

    function refund() external;

    // function destruct() external;

    function getChunkHash(bytes memory nameWithVersionAndSuffix, uint256 chunkId) external view returns (bytes32);
}
