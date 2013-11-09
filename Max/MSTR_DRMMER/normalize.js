inlets = 1;
outlets = 1;

var max_val;

function msg_float (input) {
    max_val = input;
}

function list(input) {
    for(var index=0; index<arguments.length; index = index+1) {
        arguments[index] = arguments[index]/max_val;
        outlet(0,arguments[index]);
    }
}