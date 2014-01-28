public class NoiseBurst {
	
	public double [] samples;
	public int sampDelay;
	
	//constructor for NoiseBurst with bit depth of 16
	public NoiseBurst(double fs, double freq, double amp) {
		int i;												//index for iterating and filling the array
		double period = 1/freq;								//duration of noise burst (in seconds)
		sampDelay = (int)(Math.round(fs*period));		//round the fractional sample to nearest whole
		samples = new double [sampDelay];						//create container for burst of noise
		
		//fill array with noise
		for(i=0;i<samples.length;i++) {
			samples[i] = ((Math.random())*2 - 1)*amp;			//generate random number scaled between [-amp,amp]
		}
	}

}