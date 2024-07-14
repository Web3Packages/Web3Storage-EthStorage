
// No external input parameters, but with function parameters
const test1 = function(text){
    var a = "-12";
    var b = function(bb){
        return bb;
    }
    return text+a+b("-123");
}


// No external input parameters, but with function parameters
function test2(text){
    return text
}

// No external input parameters. Class type
class Test3{
    out(test){
        return test;
    }
}

// With external input parameters
function test4(){
    return argsInput0 + argsInput1;
}

// With external input parameters
const testList = {
    "t1":`${argsInput0} && ` + args[1],
    "t2":{"tt2":"tt2"},
    "800":{"url":"https://","text":"text"}
}



