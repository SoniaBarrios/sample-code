Unified CSound file template
Michael Dean - 2012

Notes
- Function table is 1024 samples in length. Need to change ftgen and f table if different size is desired
-

<CsoundSynthesizer>	; start Csound file, alert compiler to .csd format

; -----ORCHESTRA---------------------------------------------
<CsInstruments>					; Instrument definitions

#define MAX_AMPLITUDE # 30000 #

; HEADER - global options for instrument performance (instr 0)
sr = 44100						; Sampling rate
nchnls = 1						; number of output channels
ksmps = 16 						; num samples in a control period (integers)
							; alternatively, declare the kr (control rate) since ksmps = sr/kr

; Generate a global wavetable.
; Syntax: gir ftgen ifn, itime, isize, igen, iarga [, iargb ] [...]
; automatically assign function table number and ignore time
; GEN 10 used to create single harmonic sine tone
giSine ftgen 0, 0, 1024, 10, 1

; Establish MIDI assignments --------------------------------
massign 0, 0 ; Disable default MIDI assignments.
massign 1, 1 ; Assign MIDI channel 1 to instr 1.
iMIDI_channel 	= 1				; MIDI channel of incoming instrument
iCtrl_No		= 1				; Csound's controller number for this instrumnent
iValue		= 0				; Use the following formula to set ivalue 
							; 	according with midic7 and ctrl7 min and max range:
    							;	ivalue = (initial_value - min) / (max - min)
initc7 iMIDI_channel, iCtrl_No, iValue	; Initializes the controller used to create a 7-bit MIDI value

; Establish message communication ---------------------------
; initialize messages
kCar 		init 1.0					
kMod 		init 1.0
kMod_idx 	init 1.0

; create message channels
chn_k "carrier", 3
chn_k "modfactor", 3
chn_k "modindex", 3
chn_k "attack", 3
chn_k "decay", 3
chn_k "sustain", 3
chn_k "release", 3

; OPCODES - Instrument definitions --------------------------
; MIDI activated
instr 1
	; Get arguments for envelope
	iAttack	chnget "attack"
	iDecay	chnget "decay"
	iSustain	chnget "sustain"
	iRelease	chnget "release"

	; Get arguments for frequency modulation
	iFreq 	cpsmidi				; Get frequency associated with current MIDI value
	iAmp 		veloc 0, $MAX_AMPLITUDE	; Get the velocity from the MIDI event and scale for 32 bit
	kCar		chnget "carrier"			; Get the carrier signal factor message
	kMod		chnget "modfactor"		; Get the modulation factor message
	kMod_idx	chnget "modindex"			; Get the modulation index
	
	; Generate frequency modulated signal
	aFMSynth	foscili iAmp, iFreq, kCar, kMod, kMod_idx, giSine
	
	; Generate envelope
	aEnv expsegr 0.001, iAttack/1000, 1, iDecay/1000, iSustain, iRelease/1000, 0.001
	
	aout = aFMSynth * iAmp * aEnv * 0.0007	; limit amplitude for use in Max
	
	; Write audio data to external stream.
    	outch 1, aout
endin

</CsInstruments>

; -----SCORE-------------------------------------------------
<CsScore>		; Events that instantiate instruments from the orchestra component

i1 0 10000
e
</CsScore>
</CsoundSynthesizer>	; end Csound file<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>72</x>
 <y>179</y>
 <width>400</width>
 <height>200</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>231</r>
  <g>46</g>
  <b>255</b>
 </bgcolor>
 <bsbObject version="2" type="BSBVSlider">
  <objectName>slider1</objectName>
  <x>5</x>
  <y>5</y>
  <width>20</width>
  <height>100</height>
  <uuid>{63d7b6c1-9e8f-45bb-ab75-d2bca7cd73c1}</uuid>
  <visible>true</visible>
  <midichan>0</midichan>
  <midicc>-3</midicc>
  <minimum>0.00000000</minimum>
  <maximum>1.00000000</maximum>
  <value>0.00000000</value>
  <mode>lin</mode>
  <mouseControl act="jump">continuous</mouseControl>
  <resolution>-1.00000000</resolution>
  <randomizable group="0">false</randomizable>
 </bsbObject>
</bsbPanel>
<bsbPresets>
</bsbPresets>
<MacOptions>
Version: 3
Render: Real
Ask: Yes
Functions: ioObject
Listing: Window
WindowBounds: 72 179 400 200
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>

<MacGUI>
ioView nobackground {59367, 11822, 65535}
ioSlider {5, 5} {20, 100} 0.000000 1.000000 0.000000 slider1
</MacGUI>
