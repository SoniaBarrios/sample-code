//Burst of noise used for the Karplus-Strong Algorithm
//Author: Michael Dean

public class NoiseBurst {
	
	//fields for NoiseBurst
	public double [] samples;							//samples representing noise
	
	//-CLASS CONSTRUCTORS--------------------------------------
	public NoiseBurst(double frequency) {
		double fs = 44100;								//default sampling frequency
		double amp = 0.95;								//default amplitude
		
		createBurst(fs,frequency,amp);					//fill samples field with default parameters
	}
	
	public NoiseBurst(double fs, double frequency, double amplitude) {
		createBurst(fs,frequency,amplitude);			//fill samples field with provided parameters
	}
	
	//-METHODS-------------------------------------------------
	//fill the samples array with random numbers between -amp,amp (ie. noise)
	private void createBurst(double fs, double freq, double amp) {
		int i;											//index for iterating and filling the array
		
		double period = 1/freq;							//duration of noise burst (in seconds)
		int length = (int)(Math.round(fs*period));		//round length to nearest whole
		samples = new double [length];					//create container for burst of noise
		
		//fill samples field with noise 
		for(i=0;i<samples.length;i++) {
			samples[i] = ((Math.random())*2 - 1)*amp;	//generate random number scaled between [-amp,amp]
		}
	}
}