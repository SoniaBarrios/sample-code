inlets = 1;
outlets = 1;
this.autowatch = 1; //automatically recompile everytime script is saved

var mu;
var length;
var standard_deviation;
var input_length;

//convolve gaussian function with incoming list
//-------------------------------------------------------------------
//---MAIN------------------------------------------------------------
//-------------------------------------------------------------------
function list(v) {
    //assign functions to convolve
    var u = gaussian();                     //generate gaussian
    input_length = arguments.length;
    var w = new Array(2*input_length-1);    //initialize output array
    
    //convolve functions
    w = convolve(u,arguments);

    //output result
    outlet(0,w);    //send convolved function out the outlet
}

//Set Gaussian function attributes via function input
//-------------------------------------------------------------------
//use jsarguments to use arguments in object
function mean(input) {
    mu = input;
}

function sd(input) {
    standard_deviation = input;
}

//Generate Gaussian function
//-------------------------------------------------------------------
function gaussian() {
    //---HARD CODE VALUES FOR TESTING
    standard_deviation = 0.9;
    mu = 32;

    var max = 0;    //for normalization of gaussian function

    //calculate Gaussian function coefficients
    var a = 1/(standard_deviation*Math.sqrt(2*Math.PI));
    var b = mu;
    var c = standard_deviation;

    //make generated gaussian function the same length as the input list
    var gauss = new Array(input_length);

    //generate gaussian function
    for (var index=0; index<gauss.length; index=index+1) {
        gauss[index] = a*Math.exp(-Math.pow((index-b),2)/(2*Math.pow(c,2)));

        //track maximum number for normalization purposes
        if(gauss[index]>max) {
            max = gauss[index];
        }
    }
    return normalize(gauss,max);    //return normalized Gaussian function
}

//Normalize Gaussian function
function normalize(gauss,max) {   
    //normalize
    for(var index=0; index<gauss.length; index=index+1) {
        gauss[index] = gauss[index]/max;
    }
    //post(gauss);
    return gauss;
}

//Convolve Gaussian function with Input Array
//-------------------------------------------------------------------
function convolve(u,v) {
    var m = u.length;                   //length of gaussian
    var n = input_length;               //length of input
    var w = new Array(2*n-1);           //innitialize output array
    
    N = m+n;

    //perform convolution
    for(var k=0; k<N-1; k=k+1) {
        w[k]=0;
        for(var j=Math.max(0,k-n); j<Math.min(k,m); j=j+1) {
            w[k] = u[j]*v[k-j-1] + w[k];
        }
    }
    
    return time_shift(w);
    //return w;
}

//time shift the convolved signal - FIX WRAPPING ON END OF PATTERN
function time_shift(w) {
    var shift;
    var time_shifted_w = new Array((w.length+1)/2);
    
    for(var i=0; i<(w.length+1)/2; i=i+1) {
        shift = i + (w.length+1)/4 + 1;
        time_shifted_w[i] = w[shift];
    }
    
    return time_shifted_w;
}