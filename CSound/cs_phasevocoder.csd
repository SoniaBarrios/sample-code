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
ksmps = 8 		; num samples in a control period (integers)
			; alternatively, declare the kr (control rate) since ksmps = sr/kr
			
; Establish message communication ---------------------------
kTranspose		init 1.0		; Transposition factor for resynthesis
iWinSize		init 1024		; A new window size will only update when the score is run again because it is at the i-rate
iOverlapFactor	init 4

iIO_mode = 3
chn_k "transposition", iIO_mode
chn_k "windowsize", iIO_mode
chn_k "overlapfactor", iIO_mode

instr 1
	;pvsanal has no influence when there is no transformation of original sound
	aInput 		inch 1									; Read audio from channel 1 of external audio stream.
	kTranspose		chnget "transposition"							; Transposition is a factor of a scale. ie. 0.5 is down a fifth
	iWinSize		chnget "windowsize"
	iOverlapFactor	chnget "overlapfactor"
	
	iFFTSize  = iWinSize
	iOverlap  = iFFTSize / iOverlapFactor
	iWindowShape = 1											; 0 = Hamming, 1 = von-Hann 

	; fft-analysis of the audio-signal
	fftin     		pvsanal aInput, iFFTSize, iOverlap, iWinSize, iWindowShape	
	fftblur   		pvscale fftin, kTranspose						; transpose the signal by scaling factor
	aOut      		pvsynth fftblur								; resynthesis
	
	; output signal to external stream
     	outch 1, aOut*0.9
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
  <uuid>{d348267e-7f1d-4bc9-8b5a-cc33ce5e25f9}</uuid>
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
