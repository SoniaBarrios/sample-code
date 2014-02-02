import java.io.File;
import java.io.IOException;
//import java.util.Arrays;

public class karplusStrong {
	
	public static void main(String[] args) throws IOException, WavFileException {
		//Initialize parameters
		double fs = 44100;				//sampling frequency
		
		double freq = 277.81;			//frequency of resulting tone
		double amp = 0.9;				//amplitude of noise burst
		double t_output = 3;			//length of output (in seconds)
		
		double fb = 0.96;				//feedback ratio of delay line
		
		//Create arrays for input/output
		NoiseBurst noise = new NoiseBurst(fs, freq, amp);		//create a burst of noise
		double [] output = new double [(int) (fs*t_output)];	//create an empty output vector (length rounded)
		
		//Run noise burst through a fed-back delay line
		output = delayWithfb(noise.samples, output, fb, noise.samples.length, fs);
		
		//Write fed-back noise to a wave file
		writeAudio("ks.wav", output, fs);
	}
	
	//delays input and low-pass filters before feeding back
	public static double [] delayWithfb(double [] input, double [] output, double fb, int sampDelay, double fs) {
		int i;									//index for array iteration
		
		//parameters for delay line
		int m = sampDelay;						//sample delay
		int ptr = 0;							//pointer for circular delay line
		double x;								//sample to be read (sample to delay)
		double y;								//sample to be written (delayed sample)
		double [] delayline = new double [m];	//circular delay line
		
		//parameters for low-pass filter - DAFX pg. 40
		double fc = 300;						//cut-off frequency
		double xLast = 0;						//x(n-1)
		double yLast = 0;						//y(n-1)
		
		//initialize delay line by filling with 0s
		delayline = fillWithZeros(delayline);
		
		//create new LowpassFilter object
		LowpassFilter lpf = new LowpassFilter(fc);
		
		//delay signal with circular delay, followed by a low-pass filter 
		for(i=0;i<output.length;i++) {
			
			//check for more input samples, otherwise assume input is zero
			if(i>=input.length) {
				x = 0;							//input is zero when there are no more input samples
			} else {							
				x = input[i];					//otherwise, delay incoming samples
			}
			
			//feedback output to input
			x = fb*(x + delayline[ptr]);
			
			//delay using a circular buffer
			y = delayline[ptr];					//write sample to output from circular buffer
			delayline[ptr] = x;					//read sample from input
			ptr = ptr + 1;						//update circular pointer
			
			//if there are no samples left to read in delay line, wrap around (circular buffer)
			if (ptr>=m) {
				ptr = ptr - m;
			}
			
			//filter sample with a 1-pole lowpass filter
			y = lpf.filter(x,xLast,yLast);
			
			//write sample to output
			output[i] = y;
			
			//save last samples for next filter calculation
			xLast = x;
			yLast = y;
		}
		
		return output;	//return output array
	}//end delayWithfb method
	
	//fill an array with values of zero
	public static double [] fillWithZeros(double [] arrayToFill) {
		int i;			//index, for array iteration
		
		//fill array with zeros at each index
		for(i=0;i<arrayToFill.length;i++) {
			arrayToFill[i] = 0;
		}
		
		//return zeroed array
		return arrayToFill;
	}//end filleWithZeros method
	
	//Write samples to a .wav file
	//Uses the WaveFile IO class written by A. Greensted
	//http://www.labbookpages.co.uk
	static void writeAudio(String outputName, double [] samples, double fs_dbl) throws IOException, WavFileException {
		//initialize variables
		int fs = (int)fs_dbl;					//samples per second = sample rate
		int numChannels = 1;					//number of channels in audio file. 1=mono, 2=stereo etc...
		int bitDepth = 24;						//number of bits used to represent sample amplitudes
		int numFrames = samples.length;			//number of frames for specified duration
		
		//initialize objects
		WavFile wavFile;

		//Create a wav file with the name specified as the first argument
		wavFile = WavFile.newWavFile(new File(outputName), numChannels, numFrames, bitDepth, fs);

		//Write the buffer
		wavFile.writeFrames(samples, numFrames);

		//Close the wavFile
		wavFile.close();
	} //end writeAudio method
}
