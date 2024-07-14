# Web3Storage-EthStorage

## Getting Started
1. First, git clone this project.
```
git clone https://github.com/Web3Packages/Web3Storage-EthStorage.git
```
or
```
git clone git@github.com:Web3Packages/Web3Storage-EthStorage.git
```


2. Copy the ".env.example" file and modify it to ".env". Then, make the necessary configuration changes. For example, private key.

3. Install all dependencies
```
npm install
```


## Upload file on chain

1. Write your code under the path "./code"
2. Change name in "/scripts/01_writeFile.js"
```
const fileName = "uint8ArrayToByteStr@1.0.1";  // change it to the name of your code

```
3. run the script to upload file on the chain
```
node ./scripts/01_writeFile.js
```