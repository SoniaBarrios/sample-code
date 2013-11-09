Unified CSound file template
Michael Dean - 2012

Things to add:
    - ADSR
    - Different wave forms
    - LFO

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

iIO_mode = 3
chn_k "modmode", iIO_mode
chn_k "modamp", iIO_mode
chn_k "modfreq", iIO_mode

instr 1
	aInput inch 1						; Read audio from channel 1 of external audio stream.
	
	kModMode  	chnget "modmode"				; Get mode for processing. 0 = Bipolar, 1 = Unipolar
	kModAmp	chnget "modamp"				; Get amplitude for modulation signal
	kModAmp	= ampdb(kModAmp)				; convert from db
	kModFreq	chnget "modfreq"				; Get frequency for modulation signal
	
	; Create interpolated oscillator to modulate amplitude (biploar)
	aAmpMod		oscili kModAmp, kModFreq, 1		; put oscillator output in block aOsc
	
	; Amplitude modulation
	; 0 = Bipolar (Ring Modulation)
	; 1 = Unipolar (Amplitude Modulation)
	
	if (kModMode==0) then
		aOutput = aInput*aAmpMod
	else
		aOutput = aInput*(aAmpMod+kModAmp)
	endif
	outch 1, aOutput*0.000015
     	
endin

</CsInstruments>

; -----SCORE-------------------------------------------------
<CsScore>		; Events that instantiate instruments from the orchestra component
f1 0 1024 10 1                                          ; Sine with a small amount of data

; Why does this need to be here?
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
  <uuid>{a10a87db-eae0-4969-af0c-0deb132db24d}</uuid>
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
