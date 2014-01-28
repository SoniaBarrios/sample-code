import java.io.File;
import java.io.IOException;
import java.util.Arrays;

public class karplusStrong {
	
	public static void main(String[] args) throws IOException, WavFileException {
		//testClass test = new testClass();
		double fs = 44100;				//sampling frequency
		double freq = 200;				//frequency of note output
		double amp = 0.9;				//amplitude of input
		double fb = 0.98;				//feedback for delay line
		
		NoiseBurst noise = new NoiseBurst(fs, freq, amp);	//create input
		double [] output = new double [(int)fs*3];				//create output vector
		double [] input = noise.samples;
		
		System.out.println(Arrays.toString(input));		//check array content
		
		output = delayInput(input,output,fb,noise.sampDelay, fs);
		writeAudio("ks.wav", output, fs);
	}
	
	public static double [] delayInput(double [] input, double [] output, double fb, int sampDelay, double fs) {
		int i;									//index for array iteration
		
		//parameters for delay line
		int m = sampDelay;						//sample delay
		int ptr = 0;							//pointer for circular delay line
		double x;								//sample to be read (sample to delay)
		double y;								//sample to be written (delayed sample)
		double [] delayline = new double [m];	//circular delay line
		
		//parameters for lowpass filter
		double fc = 400;		//cut-off frequency
		double c = (Math.tan(Math.PI*fc/fs)-1)/(Math.tan(Math.PI*fc/fs)+1);
		double xLast = 0;
		double yLast = 0;
		
		//fill delayline with 0s - COULD MAKE A CIRCULAR BUFFER CLASS
		delayline = fillWithZeros(delayline);
		
		//delay signal with circular delay, lowpass filter 
		for(i=0;i<output.length;i++) {
			//check for continued input samples, else read input as zero
			if(i>=input.length) {
				x = 0;							//use zero when there is no more input samples
			} else {							
				x = input[i];					//else delay input for as long as there are samples
			}
			
			//ADD INPUT TO DELAY LINE
			x = fb*(x + delayline[ptr]);
			
			//DELAY SAMPLE WITH CIRCULAR BUFFER
			y = delayline[ptr];					//write sample to output from circular buffer
			delayline[ptr] = x;					//read sample from input
			ptr = ptr + 1;						//update circular pointer
			
			//if there are no samples left to read in delay line, wrap around (circular buffer)
			if (ptr>=m) {
				ptr = ptr - m;
			}
			
			//LOWPASS FILTER -  1-pole
			//-------------------------------------------------------
			// H(z) = 0.5*(1+[(z^-1+c)/(1+c*z^-1)])
			// ...where c = (tan(pi*fc/fs)-1)/(tan(pi*fc/fs)+1)
			// => y(n) = 0.5*(c+1)*x(n) + 0.5*(c+1)*x(n-1) - c*y(n-1)
			y = 0.5*(c+1)*x + 0.5*(c+1)*xLast - c*yLast;
			
			output[i] = y;
			xLast = x;
			yLast = y;
		}
		
		return output;	//return output array
	}
	
	public static double [] fillWithZeros(double [] arrayToFill) {
		int i;			//index, for array iteration
		
		//fill array with zeros at each index
		for(i=0;i<arrayToFill.length;i++) {
			arrayToFill[i] = 0;
		}
		
		return arrayToFill;
	}
	
	static void writeAudio(String outputName, double [] samples, double fs_dbl) throws IOException, WavFileException {
		//initialize variables
		int fs = (int)fs_dbl;							// Samples per second = sample rate
		int numChannels = 1;					// number of channels in audio file. 1=mono, 2=stereo etc...
		int bitDepth = 24;						// number of bits used to represent sample amplitudes
		int numFrames = samples.length;			// number of frames for specified duration
		
		//initialize objects
		WavFile wavFile;

		// Create a wav file with the name specified as the first argument
		wavFile = WavFile.newWavFile(new File(outputName), numChannels, numFrames, bitDepth, fs);

		// Write the buffer
		wavFile.writeFrames(samples, numFrames);

		// Close the wavFile
		wavFile.close();
	} //end writeAudio method
}
