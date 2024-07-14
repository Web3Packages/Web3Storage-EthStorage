
const fs = require("fs");
const path = require("path");


const filePath = './code/';
const fileName = "example@1.0.1";

const hexName = '0x' + Buffer.from(`${fileName}.txt`, 'utf8').toString('hex');  // 

const contentBuffer = fs.readFileSync(filePath + fileName + ".js"); // <Buffer 0a 20 20 2f 2f 20 ...>
const contentBufferToUtf8Str = encodeURIComponent(contentBuffer);  // <string> %0A%20%20%2F...

var code = decodeURIComponent(contentBufferToUtf8Str);  // get the code



// code = code + "\nreturn test1";
// const returnFunction= new Function([],code);
// const test1 = returnFunction();
// console.log(test1("123"))

// code = code + "\nreturn [test1, test2]";
// const returnFunction= new Function([],code);
// const [test1, test2] = returnFunction();
// console.log(test1("123"))
// console.log(test2("123"))

// code = code + "\nreturn [test1, test2, Test3]";
// const returnFunction= new Function([],code);
// const [test1, test2, Test3] = returnFunction();
// const test3 = new Test3();
// console.log(test3.out("test3"));

// code = code + "\nreturn [test1, test2, Test3, test4]";
// const returnFunction= new Function(["argsInput0", "argsInput1"],code);
// const [test1, test2, Test3, test4] = returnFunction("tt1", "tt2");
// console.log(test4());


code = code + "\nreturn [test1, test2, Test3, test4, testList]";
const returnFunction= new Function(["argsInput0", "args"],code);
const [test1, test2, Test3, test4, testList] = returnFunction("tt1", ["ttt0", "ttt1"]);
console.log(testList.t1);
console.log(testList["800"].url);

