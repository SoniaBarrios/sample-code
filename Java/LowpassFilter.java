//One-pole Low-pass filter - as seen on pg. 40 of DAFX
//Implemented by Michael Dean
//------------------------------------------------------

/*
Transfer Function H(z) is given in DAFX:

	H(z) = 0.5*(1+[(z^-1+c)/(1+c*z^-1)])
	...where c = (tan(pi*fc/fs)-1)/(tan(pi*fc/fs)+1)

Since H(z) = Y(z)/X(z),

=> y(n) = 0.5*(c+1)*x(n) + 0.5*(c+1)*x(n-1) - c*y(n-1)

*/

public class LowpassFilter {
	
	//fields for lowpass filter
	private double c;
	
	//-CLASS CONSTRUCTORS--------------------------------------
	public LowpassFilter(double cutoffFreq) {
		double samplingFreq = 44100;				//default sampling frequency
		c = calculateC(cutoffFreq, samplingFreq);	//set c constant for filter calculations
	}
	
	public LowpassFilter(double cutoffFreq, double samplingFreq) {
		c = calculateC(cutoffFreq, samplingFreq);	//set c constant for filter calculations
	}
	
	//-METHODS-------------------------------------------------
	//calcuate the c constant, as defined in DAFX
	private double calculateC(double fc, double fs) {
		
		//calculate c constant for low-pass filter
		return (Math.tan(Math.PI*fc/fs)-1)/(Math.tan(Math.PI*fc/fs)+1);	
	}
	
	//filter sample - this method called when wanting to use the object
	public double filter (double input, double xLast, double yLast) {
		return 0.5*(c+1)*input + 0.5*(c+1)*xLast - c*yLast;
	}
}
