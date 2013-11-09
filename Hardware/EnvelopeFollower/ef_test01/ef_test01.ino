#include <MIDI.h>

int midi_ch = 1;  //midi channel for output
int pot_cc = 45;
int last = 0;

#define LED 13   		// LED pin on Arduino board

// the setup routine runs once when you press reset:
void setup() {
  // initialize serial communication at 9600 bits per second:
  //Serial.begin(9600);
  Serial.begin(31250);   //baud rate for MIDI
  MIDI.begin(midi_ch);  //set midi channel
}

// the loop routine runs over and over again forever:
void loop() {
  int sensorValue = analogRead(A0);  //read value on pin 0
  if (last!=sensorValue) {
    //sendCC(sensorValue);
    sendCC(sensorValue*127.0/1023.0);
  }
  
  delay(35);                        // delay in between reads for stability
  last = sensorValue;
}

void sendCC(int ccvalue) {
  MIDI.sendControlChange(pot_cc,ccvalue,midi_ch);
  digitalWrite(LED,LOW);
  //Serial.println(ccvalue);
}

