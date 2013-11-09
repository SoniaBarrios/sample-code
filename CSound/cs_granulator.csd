Unified CSound file template
Michael Dean - 2012

<CsoundSynthesizer>	; start Csound file, alert compiler to .csd format

; -----ORCHESTRA---------------------------------------------
<CsInstruments>		; Instrument definitions

; HEADER - global options for instrument performance (instr 0)
; ~~~~~~
sr = 44100		; Sampling rate
nchnls = 1		; number of output channels
0dbfs = 1		; Sets the value of 0 decibels using full scale amplitude.
ksmps = 16 		; num samples in a control period (integers)
			; alternatively, declare the kr (control rate) since ksmps = sr/kr
			
; Establish message communication ---------------------------
; initialize messages
iVoice	init 12
iRatio	init 1.0
iLength	init 1.0
kGap		init 0.01
kGSize	init 0.025
iRise		init 5
iDecay	init 30

; create channels for k-rate message communication
iIO_mode = 3
chn_k "numvoices", iIO_mode
chn_k "stretch", iIO_mode
chn_k "length", iIO_mode
chn_k "graingap", iIO_mode
chn_k "grainsize", iIO_mode
chn_k	"grainattack", iIO_mode
chn_k "graindecay", iIO_mode

; Generate an empty table.
giWaveTable ftgen 1, 0, 262144, 7, 0, 262144, 0 

instr 1
	
	; Get parameters from user
	kGap		chnget "graingap"		; inter-grain delay - gap between grains, in seconds
	kGSize	chnget "grainsize"	; grain size, in seconds
	iVoice 	chnget "numvoices"	; number of overlapping grains
	iRatio	chnget "stretch"		; ratio of speed of the pointer relative to sample rate
	;iRise		chnget "grainattack"	; attack of the grain envelope in terms of % of grain size
	;iDecay	chnget "graindecay"	; decay of the grain size in terms of % of grain size
	
	; ------------------
	; Granular synthesis
	; ------------------
	
	iAmp 		= ampdb(90)			; amplitude
	iMode		= 0				; direction of grain pointer. 0 = random
	iAmpThresh	= 0 				; amplitude threshold for using samples for grains
	ifN		= giWaveTable		; function table of sound source
	iPitchShift	= 0				; pitch shift control. 0 = pitch will be set randomly up and down an octave
	iGSkip	= 0				; intital skip of grain pointer from beginning of table, in seconds
	iGSkip_os	= 0				; grain skip pointer random offset
	iLength = ftlen(giWaveTable)/sr	; length of table to be used, starting from iSkip
	iGap_os	= 50				; % of random offset in terms of grain size
	iGSize_os	= 50				; % of random offset in terms of grain size
	iRise		= 10				; attack of the grain envelope in terms of % of grain size
	iDecay	= 10				; decay of the grain size in terms of % of grain size
	

	; Synthesize using grains
	aGranPre granule iAmp, iVoice, iRatio, iMode, iAmpThresh, ifN, iPitchShift, iGSkip, iGSkip_os, iLength, kGap, iGap_os, kGSize, iGSize_os, iRise, iDecay, 1, 1.42, 1.29, 1.32, 2
	
	; Write output to external stream
	aGran = aGranPre*0.00001
    	outch 1, aGran
endin

</CsInstruments>

; -----SCORE-------------------------------------------------
<CsScore>		; Events that instantiate instruments from the orchestra component
;f0 0 
; Why does this need to be here?
i1 0 18000
e
</CsScore>
</CsoundSynthesizer>	; end Csound file<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>22</y>
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
  <uuid>{09f2827c-3114-4f25-9045-870df06defa2}</uuid>
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
