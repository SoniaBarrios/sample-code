/* DJ MIDI controller prototype
Built and programmed by M. Dean, G. Crisfield
University of Victoria, SENG 411
2011*/

//-------------Libraries------------------------------------
#include <MIDI.h>

//-------------Initialize Variables-------------------------
//circuit must be wired up in this order
int numKnobs = 8;
int numSliders = 3;
int numButtons = 2;

int firstButtonPin = 2; //set the pin for the first button

//total number of inputs
int numInputs = numKnobs+numSliders+numButtons;

//cannot create array using a variable - must hardcode
//second dimension of 2D array stores CC value, then the last
//change in value
int inputs[13][2]; //creates a 2D array to store input values
int buttonStates[2][1];
int midiChannel = 1; //sets outgoing MIDI channel

//initialize first CC value to be assigned to pins
int ccVal = 30;

//-------------SetUp----------------------------------------
void setup() {
  MIDI.begin(); //initialize MIDI messages for library
  Serial.begin(31250); //set baud rate for MIDI serial data
  //Serial.begin(9600); //for testing
  
  //setup digital pins for buttons
  for(int i=0;i>numButtons;i++) {
    //set digital pins to be input
    pinMode(i+firstButtonPin, INPUT);
    buttonStates[i][0] = 1; //initialize buttons as pressed
  }
  
  //assign each input a MIDI control change value and
  //an initial value.
  for (int i=0; i<numInputs; i++) {
    ccVal = ccVal+i;
    
    //fill array with ccVal and initial value
    for (int j=0; j<2; j++) {
      if (j==0) {
        inputs[i][j] = ccVal; //assign control change value
      } else {
        inputs[i][j] = 0; //initial value
      } //end if statements
    } //end inner for loops
  } // end outer for loop
} // end setup

//-------------Main Program---------------------------------
void loop() {
  //check each input for a change in data
    //first check the rotary potentiometers
    for (int i=0; i<numKnobs; i++) {
      //check each input and compare to last value
      checkPots(i);
    }
    
    //then check linear pots
    for (int i=numKnobs; i<numKnobs+numSliders; i++) {
      //check each input and compare to last value
      checkPots(i);
    }
    
    //finally check to see if button changes state
    for (int i=numInputs-numButtons; i<numInputs; i++) {
      //check each input and compare to last value
      checkButtons(i);
    }
    
    delay(10);
} //continuously repeat checking data values

//-------------Functions------------------------------------
void checkPots (int pin) {
   //if data changes, output new value and store new one
   int readValue = analogRead(pin);
   readValue = readValue/8; //assuming 10K ohm pots
   
   if (readValue != inputs[pin][1]) {
     //method args are midi CC value, input, and midi channel
     MIDI.sendControlChange(inputs[pin][0],readValue,midiChannel);
     //update inputs array
     inputs[pin][1] = readValue;
   } //otherwise, do not output anything
}

//virtualPin does NOT correspond to actual pin in this case
//since buttons are digital input we need to make an adjustment
//so that we read the right input
void checkButtons (int virtualPin) {
  
  int buttonIndex = virtualPin - numKnobs - numSliders;
  int currentButtonState = buttonStates[buttonIndex][0]; //get buttonState
  int actualPin = buttonIndex + firstButtonPin; //calculate the actual pin where buttons are located
  
  int currentState = digitalRead(actualPin);
  
  int lastState = inputs[virtualPin][1];
  
  //if button is pressed in, change the state
  //otherwise, do nothing
  if (lastState == 0 && currentState == 1) {
    if (currentButtonState == 0) {
      buttonStates[buttonIndex][0] = 1;
    } else {
      buttonStates[buttonIndex][0] = 0;
    }
    
    //output the state change
    MIDI.sendControlChange(inputs[virtualPin][0], buttonStates[buttonIndex][0]*127,midiChannel);
  }
  
  inputs[virtualPin][1] = currentState;
}
