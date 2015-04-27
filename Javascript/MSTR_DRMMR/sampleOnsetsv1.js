/*
sampleOnsets - Mike Dean
Used for the MSTR DRMMER++ System.

Description:
    Receives bang messages from the Ableton transport clock. If an onset has been detected by 'Bonk', the object notates an onset. If no onset has been detected, the clock notates no onset. Onsets output by sampleOnsets.js are grouped into an array by a "zl group" object.
*/

inlets = 2;
outlets = 1;
this.autowatch = 1;

var val = 0;

//Main
function bang() {
    //set flag for onset
    if(inlet==0) {
        //set flag
        val = 1;
    } else if (inlet==1) {
        //clock triggers output
        outlet(0,val);
        val = 0;
    }
}