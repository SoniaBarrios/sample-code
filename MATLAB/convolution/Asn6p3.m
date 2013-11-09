% Elec 484 Summer 2011
% Mike Dean
% Assignment 6 - Convolution

clear all;
close all;

% 1.3.	Acyclic (aperiodic) convolution in both time and frequency domain 
% using zero padding using rectangular windows (DAFX figure 8.20) and 
% overlap-add. Use window size of 8 samples for numbers and 2048 samples
% for audio file.

% allocate space for sequences
% note that both arays are same length
x = zeros(1,32);
h = x;
m=1;

% fill arrays
for i=1: length(x)
    x(i)=i-1;
    h(i)=m;
    m=m*exp(-i*0.1);
end

intWindowSize = 8;
soundWindowSize = 2048;

winSize = intWindowSize;
hopSize = winSize/2;
numWindows = (length(x)/winSize)*2 - 1;

y = zeros(1,length(x)+length(h)-1);

% Time Domain (Acyclic convolution)
%------------------------------------------------------------------------%
hop = 1;
for i=1: numWindows
    disp = (i-1)*hopSize +1;
    xSeg = x(disp:disp+winSize-1);
    hSeg = h(disp:disp+winSize-1);
    
    % zero padding occurs in MATLAB conv function since it is acyclic conv.
    segment = conv(xSeg, hSeg);
    
    % Once the segment is computed we need to do an overlap and add
    y(hop:hop+winSize*2-2) = y(hop:hop+winSize*2-2)...
        + segment;
    
    hop = 1 + i*hopSize;
end

timeDomain = y./abs(max(y));
y = zeros(1,length(x)+length(h)-1);

% Freq Domain (Acyclic convolution)
%------------------------------------------------------------------------%
hop = 1;
for i=1: numWindows
    disp = (i-1)*hopSize +1;
    xSeg = x(disp:disp+winSize-1);
    hSeg = h(disp:disp+winSize-1);
    
    % "Zero-pad the signal segment x(n) and the impulse response h(n) up to
    % length 2N. Then take the 2N-point FFT of these two signals"
    % create zero padding as a power of two
    nfft = 2^nextpow2(length(xSeg)+length(hSeg));
    Xpadded = fft([xSeg, zeros(1, nfft-length(xSeg)-1)]) ;% FFT of zero-padded x
    Hpadded = fft([hSeg, zeros(1, nfft-length(hSeg)-1)]); % FFT of zero-padded h

    % Perform multiplication Y(k)=X(k)H(k) for k=0...2N-1
    YSeg = Hpadded .* Xpadded; % multiply each value at k in each sequence together

    % Take the 2N-point IFFT of Y(k), which yields y(n) with n=0...2N-1
    segment = real(ifft(YSeg));
    
    % Once the segment is computed we need to do an overlap and add
    y(hop:hop+winSize*2-2) = y(hop:hop+winSize*2-2)...
        + segment;
    
    hop = 1 + i*hopSize;
end

freqDomain = y./abs(max(y));


% Convolve Audio Files
%------------------------------------------------------------------------%
[hs, Fs1, nbits1] = wavread('flute.wav');
[xs, Fs2, nbits2] = wavread('drums.wav');

xs = xs';
hs = hs';

% check sizing of vectors
if (length(hs)>length(xs))
    tmp=xs;
    xs=hs;
    hs=tmp;
end

winSize = soundWindowSize;
hopSize = winSize/2;

% Allocate space for windowing arrays
nfft=2^nextpow2(length(xs)+length(hs)-1);
y = zeros(1,nfft);
xs = [xs zeros(1,nfft-length(xs))];
hs = [hs zeros(1,length(xs)-length(hs))];
numWindows = (length(xs)/winSize)*2 - 3;

hop = 1;
for i=1: numWindows
    disp = (i-1)*hopSize +1;
    xSeg = xs(disp:disp+winSize-1);
    hSeg = hs(disp:disp+winSize-1);
    
    % "Zero-pad the signal segment x(n) and the impulse response h(n) up to
    % length 2N. Then take the 2N-point FFT of these two signals"
    % create zero padding as a power of two
    nfft = 2^nextpow2(length(xSeg)+length(hSeg));
    Xpadded = fft([xSeg, zeros(1, nfft-length(xSeg)-1)]); % FFT of zero-padded x
    Hpadded = fft([hSeg, zeros(1, nfft-length(hSeg)-1)]); % FFT of zero-padded h

    % Perform multiplication Y(k)=X(k)H(k) for k=0...2N-1
    YSeg = Hpadded .* Xpadded; % multiply each value at k in each sequence together

    % Take the 2N-point IFFT of Y(k), which yields y(n) with n=0...2N-1
    segment = real(ifft(YSeg));
    
    % Once the segment is computed we need to do an overlap and add
    y(hop:hop+winSize*2-2) = y(hop:hop+winSize*2-2)...
        + segment;
    
    hop = 1 + i*hopSize;
end

% Normalize
ySound = y./(max(abs(y))*1.001);
wavwrite(ySound, Fs2, nbits2, 'outputPart3');

% plot numerical output
figure(1)
subplot(2,2,1);
stem(x);
title('32-int Input','FontWeight','bold');
xlabel('Samples');
ylabel('Amplitude');
axis([0 length(x) 0 max(x)]);
subplot(2,2,2);
stem(h);
title('32-int Impulse Response','FontWeight','bold');
xlabel('Samples');
ylabel('Amplitude');
axis([0 length(h) 0 1]);
subplot(2,2,3);
stem(timeDomain);
title('Time Domain Convolution','FontWeight','bold');
xlabel('Samples');
ylabel('Amplitude');
axis([0 length(timeDomain) 0 max(timeDomain)]);
subplot(2,2,4);
stem(freqDomain);
title('Freq. Domain Convolution','FontWeight','bold');
xlabel('Samples');
ylabel('Amplitude');
axis([0 length(freqDomain) 0 max(freqDomain)]);

% plot audio output
figure(2)
subplot(3,1,1)
plot(xs)
title('Input Signal #1','FontWeight','bold');
xlabel('Samples');
ylabel('Amplitude');
axis([0 length(xs) -max(xs) max(xs)]);
subplot(3,1,2)
plot(hs)
title('Input Signal #2','FontWeight','bold');
xlabel('Samples');
ylabel('Amplitude');
axis([0 length(hs) -max(hs) max(hs)]);
subplot(3,1,3)
plot(ySound)
title('Convolution Output Signal','FontWeight','bold');
xlabel('Samples');
ylabel('Amplitude');
axis([0 length(ySound) -max(ySound) max(ySound)]);
