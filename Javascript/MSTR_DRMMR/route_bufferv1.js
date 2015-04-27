/*
route_buffer - Mike Dean
Used for the MSTR DRMMER++ System.

Description:
*/

inlets = 2;
outlets = 2;
this.autowatch = 1;

var is_recording = 0;
var buffer;

function msg_int(rec_state) {
    if(inlet==0) {
        is_recording = rec_state;
        //post(is_recording);
    }
}

function list() {
    if(inlet==1) {
        buffer = arrayfromargs(arguments);
        outlet(is_recording,buffer);
    }
}