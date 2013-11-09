/*=============================================================================
	WahWahAU.cpp
	
=============================================================================*/
#include "WahWahAU.h"
#include <math.h>


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

COMPONENT_ENTRY(WahWahAU)


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//	WahWahAU::WahWahAU
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WahWahAU::WahWahAU(AudioUnit component)
	: AUEffectBase(component)
{
	CreateElements();
	Globals()->UseIndexedParameters(kNumberOfParameters);
	
	//set default values for each parameter
	SetParameter(kParam_Cutoff, kDefaultValue_Cutoff);
	SetParameter(kParam_LFORate, kDefaultValue_LFORate);
	SetParameter(kParam_LFODepth, kDefaultValue_LFODepth);
	SetParameter(kParam_Filter, kDefaultValue_Filter);
        
#if AU_DEBUG_DISPATCHER
	mDebugDispatcher = new AUDebugDispatcher (this);
#endif
	
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//	WahWahAU::GetParameterInfo
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ComponentResult			WahWahAU::GetParameterInfo(AudioUnitScope		inScope,
                                                        AudioUnitParameterID	inParameterID,
                                                        AudioUnitParameterInfo	&outParameterInfo )
{
	ComponentResult result = noErr;

	outParameterInfo.flags = 	kAudioUnitParameterFlag_IsWritable
						|		kAudioUnitParameterFlag_IsReadable;
    
    if (inScope == kAudioUnitScope_Global) {
        switch(inParameterID)
        {
            case kParam_Cutoff:
                AUBase::FillInParameterName (outParameterInfo, kParamName_Cutoff, false);
                outParameterInfo.unit = kAudioUnitParameterUnit_Hertz;
                outParameterInfo.minValue = kMin_Cutoff;
                outParameterInfo.maxValue = 20000;
                outParameterInfo.defaultValue = kDefaultValue_Cutoff;
				outParameterInfo.flags += kAudioUnitParameterFlag_IsHighResolution;
				outParameterInfo.flags += kAudioUnitParameterFlag_DisplayLogarithmic;
                break;

            case kParam_LFORate:
                AUBase::FillInParameterName (outParameterInfo, kParamName_LFORate, false);
                outParameterInfo.unit = kAudioUnitParameterUnit_Hertz;
                outParameterInfo.minValue = kMin_LFORate;
                outParameterInfo.maxValue = kMax_LFORate;
                outParameterInfo.defaultValue = kDefaultValue_LFORate;
				outParameterInfo.flags += kAudioUnitParameterFlag_DisplayLogarithmic;
                break;

            case kParam_LFODepth:
                AUBase::FillInParameterName (outParameterInfo, kParamName_LFODepth, false);
                outParameterInfo.unit = kAudioUnitParameterUnit_Percent;
                outParameterInfo.minValue = kMin_LFODepth;
                outParameterInfo.maxValue = kMax_LFODepth;
                outParameterInfo.defaultValue = kDefaultValue_LFODepth;
                break;
				
			case kParam_Filter:
				AUBase::FillInParameterName (outParameterInfo, kParamName_Filter, false);
				outParameterInfo.unit = kAudioUnitParameterUnit_Indexed; //sets measurement to popup menu
				outParameterInfo.minValue = kLP_Filter; // sets min value for filter
				outParameterInfo.maxValue = kHP_Filter; //sets max value for filter
				outParameterInfo.defaultValue = kDefaultValue_Filter; //default filter
				break;
			
			case kParam_Waveform:
				AUBase::FillInParameterName (outParameterInfo, kParamName_Waveform, false);
				outParameterInfo.unit = kAudioUnitParameterUnit_Indexed; //sets measurement to popup menu
				outParameterInfo.minValue = kSineWave_Waveform; // sets min value for waveform
				outParameterInfo.maxValue = kTriWave_Waveform; //sets max value for waveform
				outParameterInfo.defaultValue = kDefaultValue_Waveform; //default waveform
				break;
				
            default:
                result = kAudioUnitErr_InvalidParameter;
                break;
            }
	} else {
        result = kAudioUnitErr_InvalidParameter;
    }
    


	return result;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//	TremoloUnit::GetParameterValueStrings
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
ComponentResult WahWahAU::GetParameterValueStrings (
													   AudioUnitScope inScope,
													   AudioUnitParameterID inParameterID,
													   CFArrayRef * outStrings
) {
	//This method only applies to filter parameter, which is in the global scope
	if ((inScope == kAudioUnitScope_Global) && (inParameterID == kParam_Filter)) {
		//return without error when called by AUBase::DispatchGetPropertyInfo, which provides
		//null for outStrings
		if (outStrings == NULL) return noErr;
		
		//array with pop-up menu names
		CFStringRef strings [] = {
			kMenuItem_LPFilter,
			kMenuItem_BPFilter,
			kMenuItem_BNFilter,
			kMenuItem_HPFilter
		};
		
		// creates an immutable array containing menu item names for filter
		// places the array in the outStrings output parameter
		*outStrings = CFArrayCreate (
									 NULL,
									 (const void **) strings,
									 //calculates the number of menu items in an array
									 (sizeof (strings) / sizeof (strings [0])),
									 NULL
									 );
		return noErr;
	}
	
	//This method only applies to filter parameter, which is in the global scope
	if ((inScope == kAudioUnitScope_Global) && (inParameterID == kParam_Waveform)) {
		//return without error when called by AUBase::DispatchGetPropertyInfo, which provides
		//null for outStrings
		if (outStrings == NULL) return noErr;
		
		//array with pop-up menu names
		CFStringRef strings [] = {
			kMenuItem_Sine,
			kMenuItem_Square,
			kMenuItem_Triangle,
			//kMenuItem_SawDown,
			//kMenuItem_SawUp
		};
		
		// creates an immutable array containing menu item names for filter
		// places the array in the outStrings output parameter
		*outStrings = CFArrayCreate (
									 NULL,
									 (const void **) strings,
									 //calculates the number of menu items in an array
									 (sizeof (strings) / sizeof (strings [0])),
									 NULL
									 );
		return noErr;
	}
    return kAudioUnitErr_InvalidProperty;
}

#pragma mark ____WahWahAUEffectKernel
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//WahWahAU constructor method
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
WahWahAU::WahWahAUKernel::WahWahAUKernel (AUEffectBase *inAudioUnit) :
	AUKernelBase(inAudioUnit)
{
	mSampleFrequency = GetSampleRate();
	int totalHarmonics = 30;
	
	//populate wavetable using a sine function
	for(int i=0; i<kWaveArraySize;i++) {
		double radians = i*2.0*pi/kWaveArraySize;
		//store one cycle of a sine wave
		//no values are negative and range is -1<1
		mSine[i] = (sin(radians));
		
		//calculate up to the 29th harmonic
		//pseudo-square wave
		for(int harm=1;harm<totalHarmonics;harm++) {
			if (harm%2 != 0) {
				mSquare[i] = mSquare[i]+sin(harm*radians)/harm;
			}
			
			//mSawDn[i]=mSawDn[i]-sin(harm*radians/2)/harm;
			//mSawUp[i]=mSawUp[i]+sin(harm*radians/2)/harm;
		}
		//printf("mSawDn: %f\n",mSawDn[i]);
		
		//triangle wave calculated in segments
		if (i<(kWaveArraySize/4)) {
			mTri[i] = 0 + (double) i*4/kWaveArraySize;
		} else if (i>=(kWaveArraySize/4) && i<(3*kWaveArraySize/4)) {
			mTri[i] = 1 - (double) (i-(kWaveArraySize/4))*4/kWaveArraySize;
		} else {
			mTri[i] = -1 + (double) (i-3*kWaveArraySize/4)*4/kWaveArraySize;
		}
	}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//	WahWahAU::WahWahAUKernel::Reset()
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void		WahWahAU::WahWahAUKernel::Reset()
{
	//set delay elements to 0 for initialization
	mX1 = 0.0;
	mX2 = 0.0;
	mY1 = 0.0;
	mY2 = 0.0;
	
	// forces filter coefficient calculation
	mLastCutoff = -1.0;
	
	mCurrentScale = 0;
	mSamplesProcessed = 0;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//	WahWahAU::WahWahKernel::CalcFilterParams()
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void WahWahAU::WahWahAUKernel::CalcFilterParams(double inFreq)
{
	//for HP/LP
	double k = tan(pi*inFreq/mSampleFrequency);
	
	//for BP/BN
	double fb = 800; //bandwidth in Hz determines Q-Factor
	//determines q-factor
	double c = (tan(pi*fb/mSampleFrequency)-1)/(tan(2*pi*fb/mSampleFrequency)+1);
	//cutoff freq parameter
	double d = -cos(2*pi*inFreq/mSampleFrequency);
	
	switch (currentFilterType) {
		case kLP_Filter:
			mB0=(k*k/(1+sqrt(2)*k+k*k));
			mB1=2*mB0;
			mB2=mB0;
			mA1=2*(k*k-1)/(1+sqrt(2)*k+k*k);
			mA2=(1-sqrt(2)*k+k*k)/(1+sqrt(2)*k+k*k);
			break;
		case kBP_Filter:
			mB0=(1+c)/2;
			mB1=0;
			mB2=-mB0;
			mA1=d*(1-c);
			mA2=-c;			
			break;
		case kBN_Filter:
			mB0=(1-c)/2;
			mB1=d*(1-c);
			mB2=mB0;
			mA1=mB1;
			mA2=-c;
			break;	
		case kHP_Filter:
			mB0=(1/(1+sqrt(2)*k+k*k));
			mB1=(-2*mB0);
			mB2=mB0;
			mA1=(2*(k*k-1))/(1+sqrt(2)*k+k*k);
			mA2=(1-sqrt(2)*k+k*k)/(1+sqrt(2)*k+k*k);
			break;
		default:
			mB0=0;
			mB1=0;
			mB2=0;
			mA1=0;
			mA2=0;
			break;
	}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//	WahWahAU::WahWahAUKernel::Process
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void		WahWahAU::WahWahAUKernel::Process(	const Float32 	*inSourceP,
                                                    Float32		 	*inDestP,
                                                    UInt32 			inFramesToProcess,
                                                    UInt32			inNumChannels, // for version 2 AudioUnits inNumChannels is always 1
                                                    bool			&ioSilence )
{
	Float32		depth,
				lfoRate,
				cutoffFreq,
				samplesPerLFOCycle,
				lfoAmplitude, 
				range, 
				offset,
				varyingOffset,
				newCutoff;
	if (!ioSilence) {
		//get parameters from UI
		depth = GetParameter(kParam_LFODepth);
		lfoRate = GetParameter(kParam_LFORate);
		cutoffFreq = GetParameter(kParam_Cutoff);
		currentFilterType = (int) GetParameter(kParam_Filter);
		currentWaveform = (int) GetParameter(kParam_Waveform);
	
		depth = depth/100.0;
		range = 20000-20;
		offset = (range/2)*depth;

		//assigns a pointer value to the start of the audio sample input buffer
		const Float32 *sourceP = inSourceP;
		//assigns a pointer to the start of the audio sample output buffer
		Float32	*destP = inDestP;
	
		switch (currentWaveform) {
			case kSineWave_Waveform:
				waveArrayPointer=&mSine[0];
				break;
			case kSquareWave_Waveform:
				waveArrayPointer=&mSquare[0];
				break;
			case kTriWave_Waveform:
				waveArrayPointer=&mTri[0];
				break;
			/*case kSawDnWave_Waveform:
				waveArrayPointer=&mSine[0];
				break;
			case kSawUpWave_Waveform:
				waveArrayPointer=&mSine[0];
				break;*/
			default:
				waveArrayPointer=&mSine[0];
				break;
		}
	
		samplesPerLFOCycle = mSampleFrequency/lfoRate;
		mNextScale = kWaveArraySize/samplesPerLFOCycle;
	
		int n = inFramesToProcess;
		while(n--) {
			/*MATH FOR LOWPASS FILTER IN TIME DOMAIN---------------------
			 H(z) = (B0 + B1z^-1 + B2z^-2) / (1 + A1z^-1 + A2z^-2)
			 
			 => y[n] + A1y[n-1] + A2u[n-2] = B0x[n] + B1x[n-1] + B2x[n-2]
			 => y[n] = B0x[n] + B1x[n-1] + B2x[n-2] - A1y[n-1] - A2y[n-2]
			 */
			
			float inputSample = *sourceP++;
			
			int index = static_cast<long> (mSamplesProcessed*mCurrentScale)%kWaveArraySize;
			
			//Only allow scaling factor to change at the beginning of the next buffer to avoid
			//glitches or pops in audio processing
			if((mNextScale != mCurrentScale) && (index==0)) {
				mCurrentScale = mNextScale;
				mSamplesProcessed = 0;
			}
			
			//Resets the number of samples processed counter in a way
			//that ensures a new buffer is being processed
			if ((mSamplesProcessed >= sampleLimit) && (index == 0))
				mSamplesProcessed = 0;
			
			//calculate the amplitude value of the LFO from the wavetable array
			lfoAmplitude = waveArrayPointer[index];
			varyingOffset = lfoAmplitude*offset;
			newCutoff = cutoffFreq+varyingOffset;
			//printf("cutoff:%f\n",newCutoff);
			
			if(newCutoff<20)
				newCutoff=20;
			if(newCutoff>20000)
				newCutoff=20000;
			
			// only calculate the filter coefficients if the parameters have changed from last time
			if(newCutoff != mLastCutoff)
			{
				CalcFilterParams(newCutoff);
				mLastCutoff = newCutoff;	
			}
			
			float outputSample = mB0*inputSample + mB1*mX1 + mB2*mX2 - mA1*mY1 - mA2*mY2;

			//avoid audio overloads
			if (outputSample>1) {
				outputSample = 1.0;
			} else if (outputSample < -1) {
				outputSample = -1.0;
			}
			
			mX2 = mX1;
			mX1 = inputSample;
			mY2 = mY1;
			mY1 = outputSample;
			
			*destP++ = outputSample;
			mSamplesProcessed = mSamplesProcessed + 1; //increment counter
		}
	}
}

