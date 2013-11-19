% 3. (4 marks) Use the code from part 1 to implement a phase vocoder 
% (DAFX figure 8.5). The time frequency processing is a no-op. Verify that 
% the output after the overlap-add is the same as the input.

% Michael Dean
% V00483333
% Elec 484 - Peter Driessen - 2011

clear all;
close all;

% Initialize neccessary variables
% ------------------------------------------------------------
audioWindowLength = 1024; % in samples
windowSize = audioWindowLength;
hopSize = windowSize/2;
hanningz=0.5*(1-cos(2*pi*(0:windowSize-1)/(windowSize)));

% Read in audio
% ------------------------------------------------------------
[xs] = wavread('flute.wav');
xs = xs';

unpaddedLength = length(xs); % used to compare output with input later

% Calculate next power of two, so when we calulate the number of windows,
% it will be equal to an integer value
nfft = 2^nextpow2(length(xs));

% Ensure the two signals are lengths of powers of two
xs = [xs zeros(1,nfft-length(xs))]; % zero padding

% Window the functions
% ------------------------------------------------------------
numWindows = (length(xs)/hopSize)-1; % since hopsize is half winsize
xsWin = zeros(numWindows, windowSize); % allocate space
y_NotIntWin = zeros(numWindows, windowSize); % allocate space

% Make windows
for idx=1:numWindows
    % Each get each element for each window
    for jdx=1:windowSize
        if(idx==1)
            hopIdx=0;
        end
        xsWin(idx,jdx) = xs(hopIdx+jdx)*hanningz(jdx);
    end
    hopIdx=hopIdx+hopSize;
end

% Take the FFT of each window
% Seperate the real and imaginary components
% ------------------------------------------------------------
xsPhase = zeros(numWindows,windowSize);
xsMag = zeros(numWindows,windowSize);
xsIFFT = zeros(numWindows, windowSize);

for idx=1:numWindows
    % Take the FFT and seperate magnitude and phase
    xsFFTSegment = fft(xsWin(idx,1:windowSize));
    xsPhase(idx,1:windowSize) = angle(xsFFTSegment);
    xsMag(idx,1:windowSize) = abs(xsFFTSegment);
    
    % Frequency domain manipulation is a 'no-op' for in this case...
    
    % Synthesize the signal after frequency domain manipulation
    xsIFFT(idx,1:windowSize) = real(ifft(xsMag(idx,1:windowSize)...
        .*exp(j.*xsPhase(idx,1:windowSize))));
end

xsOut = zeros(1,length(xs));

% Overlap and add
% ------------------------------------------------------------
ySeg = zeros(1,length(xs));
for idx=1:numWindows
    disp = (idx-1)*hopSize;
    numEndZeros = length(xs)-windowSize-disp;
    ySeg = [zeros(1,disp) xsIFFT(idx,1:windowSize) zeros(1,numEndZeros)];
    xsOut = xsOut + ySeg;
end


% normalize input and resynthesized signals for comparison
% ------------------------------------------------------------
xsIn = xs;

xsIn = xsIn./max(abs(xsIn));
xsOut = xsOut./max(abs(xsOut));

xsIn = xsIn(1:unpaddedLength);
xsOut = xsOut(1:unpaddedLength);

% compare the original input signal with the resynthesized output signal
% there should be a small difference in values - due to windowing
% this is most evident if you zoom in on the initial values and compare
% each signal
sum(xsIn-xsOut)

% Plot the original and resynthesized signal
% ------------------------------------------------------------
figure(1)
subplot(2,1,1);
plot(1:unpaddedLength,xsIn)
title('Original Input Signal','FontWeight','bold');
xlabel('Samples');
ylabel('Amplitude');
subplot(2,1,2)
plot(1:unpaddedLength,xsOut)
title('Resynthesized Windowed Signal','FontWeight','bold');
xlabel('Samples');
ylabel('Amplitude');