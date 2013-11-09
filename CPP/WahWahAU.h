#include "AUEffectBase.h"
#include "WahWahAUVersion.h"

#if AU_DEBUG_DISPATCHER
	#include "AUDebugDispatcher.h"
#endif


#ifndef __WahWahAU_h__
#define __WahWahAU_h__


#pragma mark ____WahWahAU Parameters

// parameters
static CFStringRef kParamName_Cutoff = CFSTR("Cutoff Frequency");
static const float kDefaultValue_Cutoff = 3000; //in Hz
static const float kMin_Cutoff = 20; //minimum value for cutoff freq in Hz
static const float kMax_Cutoff = 20000; //maximum value for cutoff freq in Hz

static CFStringRef kParamName_LFORate = CFSTR("LFO Rate");
static const float kDefaultValue_LFORate = 2.0; //in Hz
static const float kMin_LFORate = 0.5; //minimum value for LFO Hz
static const float kMax_LFORate = 20.0; //maximum value for LFO Hz

static CFStringRef kParamName_LFODepth = CFSTR("Depth"); //UI name for depth parameter
static const float kDefaultValue_LFODepth = 50.0;
static const float kMin_LFODepth = 0.0;
static const float kMax_LFODepth = 100.0;

static CFStringRef kParamName_Filter = CFSTR("Filter Type"); //UI name for depth parameter
static const int kLP_Filter = 1;
static const int kBP_Filter = 2;
static const int kBN_Filter = 3;
static const int kHP_Filter = 4;
static const int kDefaultValue_Filter = kLP_Filter;

// menu item names for the filter type parameter
static CFStringRef kMenuItem_LPFilter = CFSTR("Low-Pass Filter"); //menu item name for LPF
static CFStringRef kMenuItem_BPFilter = CFSTR("Band-Pass Filter"); //menu item name for BPF
static CFStringRef kMenuItem_BNFilter = CFSTR("Band-Notch Filter"); //menu item name for BNF
static CFStringRef kMenuItem_HPFilter = CFSTR("High-Pass Filter"); //menu item name for HPF

static CFStringRef kParamName_Waveform = CFSTR("LFO Waveform"); // UI name for waveform parameter
static const int kSineWave_Waveform = 1;
static const int kSquareWave_Waveform = 2;
static const int kTriWave_Waveform = 3;
//static const int kSawUpWave_Waveform = 4;
//static const int kSawDnWave_Waveform = 5;
static const int kDefaultValue_Waveform = kSineWave_Waveform;

static CFStringRef kMenuItem_Sine = CFSTR("Sine"); 
static CFStringRef kMenuItem_Square = CFSTR("Square"); 
static CFStringRef kMenuItem_Triangle = CFSTR("Triangle"); 
//static CFStringRef kMenuItem_SawDown = CFSTR("Saw (Down)");
//static CFStringRef kMenuItem_SawUp = CFSTR("Saw (Up)");

//parameter identifiers
enum {
	kParam_Filter = 0,
	kParam_Waveform = 1,
	kParam_Cutoff = 2,
	kParam_LFORate = 3,
	kParam_LFODepth = 4,
	kNumberOfParameters = 5 //defines total number of parameters
};


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~WahWahAUClass~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark ____WahWahAU
class WahWahAU : public AUEffectBase
{
public:
	WahWahAU(AudioUnit component);
#if AU_DEBUG_DISPATCHER
	virtual ~WahWahAU () { delete mDebugDispatcher; }
#endif
	
	virtual AUKernelBase *		NewKernel() { return new WahWahAUKernel(this); }

	virtual	ComponentResult			GetParameterValueStrings(AudioUnitScope			inScope,
															 AudioUnitParameterID		inParameterID,
															 CFArrayRef *			outStrings);
    
	virtual	ComponentResult			GetParameterInfo(AudioUnitScope			inScope,
												 AudioUnitParameterID	inParameterID,
												 AudioUnitParameterInfo	&outParameterInfo);
	
 	virtual	bool				SupportsTail () { return true	; }
	
	/*! @method Version */
	virtual ComponentResult		Version() { return kWahWahAUVersion; }
	
    
	
protected:
		class WahWahAUKernel : public AUKernelBase		// most of the real work happens here
	{
public:
		WahWahAUKernel(AUEffectBase *inAudioUnit );
		
		// *Required* overides for the process method for this effect
		// processes one channel of interleaved samples
        virtual void 		Process(	const Float32 	*inSourceP,
										Float32		 	*inDestP,
										UInt32 			inFramesToProcess,
										UInt32			inNumChannels,
										bool			&ioSilence);
		
        virtual void		Reset();
		
		virtual void		CalcFilterParams(double inFreq);
		
		private: //state variables...
			//filter coefficients
			double mB0, mB1, mB2;
			double mA1, mA2;
		
			//filter state (delayed elements)
			double mX1, mX2;
			double mY1, mY2;
		
			//for processing method optimization
			double mLastCutoff;
		
			//keep track of currently selected filter type
			int currentFilterType, currentWaveform;
		
			//Variables for the wavetable calculation
			enum {
				kWaveArraySize = 2000,
				sampleLimit = (int) 10E6
			};
			
			//initialize wavetable waveforms
			float mSine [kWaveArraySize];
			float mSquare[kWaveArraySize];
			float mTri[kWaveArraySize];
			//float mSawUp[kWaveArraySize];
			//float mSawDn[kWaveArraySize];
		
			float *waveArrayPointer;
			float mCurrentScale, mNextScale;
			Float32 mSampleFrequency;
			long mSamplesProcessed;
	};
};
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#endif