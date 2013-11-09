Unified CSound file template
Michael Dean - 2012

<CsoundSynthesizer>	; start Csound file, alert compiler to .csd format

; -----ORCHESTRA---------------------------------------------
<CsInstruments>		; Instrument definitions

; HEADER - global options for instrument performance (instr 0)
; ~~~~~~
sr = 44100		; Sampling rate
nchnls = 2		; number of output channels
0dbfs = 1		; Sets the value of 0 decibels using full scale amplitude.
ksmps = 8 		; num samples in a control period (integers)
			; alternatively, declare the kr (control rate) since ksmps = sr/kr
			
			
; Establish message communication ---------------------------
kLFO1_freq		init 		0.01				; Default oscillation rate for control LFO 1
kLFO2_freq		init 		2.0				; Default oscillation rate for control LFO 2
kLFO3_amount	init 		1.0				; Amount of panning to apply using LFO 3
iLFO3_wave		init		1				; waveform to select for LFO3

; Create channels for input messages
iIO_mode = 1
chn_k "lfo1_freq", iIO_mode
chn_k "lfo2_freq", iIO_mode
chn_k "lfo3_amount", iIO_mode
chn_k "lfo3_wave", iIO_mode

instr 1
	;pvsanal has no influence when there is no transformation of original sound
	aInput 		inch 1				; Read audio from channel 1 of external audio stream.
	kLFO1_freq		chnget "lfo1_freq"		; Get frequency for control LFO 1
	kLFO2_freq		chnget "lfo2_freq"		; Get frequency for control LFO 2
	kLFO3_amount	chnget "lfo3_amount"		; Get amount for control LFO 2
	iLFO3_wave		chnget "lfo3_wave"		; waveform to select for LFO3
	
	; Control oscillator 1 - Sine wave LFO
	kLFO1	lfo	0.5, kLFO1_freq, 1			; Oscillate at specified frequency between -0.5 and 0.5
	kLFO1 = kLFO1 + 0.5 					; Oscillate between 0 and 1
	
	; Control oscillator 2 - Sine wave LFO
	kLFO2	lfo	0.5, kLFO2_freq, 1			; Oscillate at specified frequency between -0.5 and 0.5
	kLFO2 = kLFO2 + 0.5					; Oscillate between 0 and 1
	
	; Panning control oscillator - user defined waveform LFO controlled by LFOs 1 & 2
	kLFO3	lfo	0.5*kLFO1, 1*kLFO2, iLFO3_wave	; Change the amplitude of LFO using LFO1 [-0.5,0.5] & frequency using LFO2
	kLFO3 = kLFO3 + 0.5					; Oscillate between 0 and 1
	kLFO3 = kLFO3*kLFO3_amount
	
	; Pan input according to kLFO3
	aL,aR	pan2	aInput, kLFO3   				; sent across image
	
	; output signal to external stream
     	outch 1, aL, 2, aR
     	
endin

</CsInstruments>

; -----SCORE-------------------------------------------------
<CsScore>		; Events that instantiate instruments from the orchestra component

; Why does this need to be here?
i1 0 86400
e
</CsScore>
</CsoundSynthesizer>	; end Csound file<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>196</width>
 <height>319</height>
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
  <uuid>{b3272701-49ae-4a1d-8a8d-2017990958a7}</uuid>
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
WindowBounds: 1435 61 96 26
CurrentView: io
IOViewEdit: On
Options:
</MacOptions>

<MacGUI>
ioView nobackground {59367, 11822, 65535}
ioSlider {5, 5} {20, 100} 0.000000 1.000000 0.000000 slider1
</MacGUI>
