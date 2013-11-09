% Elec 484 Summer 2011
% Mike Dean
% Assignment 6 - Convolution

clear all;
close all;

% 1.5.	Are there any other ways the convolution could be done ? 
% State them and do them.


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

winSize = 2048;
hopSize = winSize/2;
hanningz=0.5*(1-cos(2*pi*(0:winSize-1)/(winSize)));
hanningzSynth=0.5*(1-cos(2*pi*(0:winSize*2-2)/(winSize*2-1)));
numWindows = (length(xs)/winSize)*2 - 3;
Nfft=2^nextpow2(length(xs)+length(hs)-1);

xs = [xs zeros(1,Nfft-length(xs))];
hs = [hs zeros(1,length(xs)-length(hs))];

% Acyclic Convolution with Windowing - Combining the phases (shown for comparison)
%------------------------------------------------------------------------%
% Allocate space for windowing array
y = zeros(1,Nfft);

hop = 1;
for n=1: numWindows
    disp = (n-1)*hopSize +1;
    xSeg = xs(disp:disp+winSize-1);
    xSeg = xSeg .* hanningz; % window x into segments
    hSeg = hs(disp:disp+winSize-1);
    hSeg = hSeg .* hanningz; % window h into segments
    
    % "Zero-pad the signal segment x(n) and the impulse response h(n) up to
    % length 2N. Then take the 2N-point FFT of these two signals"
    % create zero padding as a power of two
    nfft = 2^nextpow2(length(xSeg)+length(hSeg));
    Xpadded = fft([xSeg, zeros(1, nfft-length(xSeg)-1)]); % FFT of zero-padded x
    Hpadded = fft([hSeg, zeros(1, nfft-length(hSeg)-1)]); % FFT of zero-padded h

    % Perform multiplication Y(k)=X(k)H(k) for k=0...2N-1
    YSeg = Hpadded .* Xpadded; % multiply each value at k in each sequence together

    % Take the 2N-point IFFT of Y(k), which yields y(n) with n=0...2N-1
    segment = real(ifft(YSeg)) .* hanningzSynth;
    
    % Once the segment is computed we need to do an overlap and add
    y(hop:hop+winSize*2-2) = y(hop:hop+winSize*2-2)...
        + segment;
    
    hop = 1 + n*hopSize;
end
% Normalize
ySound = y./(max(abs(y))*1.001);

% Scenario 1 - using the phase of the xs signal
% Acyclic Convolution with Windowing
%------------------------------------------------------------------------%
% Allocate space for windowing arrays
y = zeros(1,Nfft);

hop = 1;
for n=1: numWindows
    disp = (n-1)*hopSize+1;
    xSeg = xs(disp:disp+winSize-1);
    xSeg = xSeg .* hanningz; % window x into segments
    hSeg = hs(disp:disp+winSize-1);
    hSeg = hSeg .* hanningz; % window h into segments
    
    % "Zero-pad the signal segment x(n) and the impulse response h(n) up to
    % length 2N. Then take the 2N-point FFT of these two signals"
    % create zero padding as a power of two
    nfft = 2^nextpow2(length(xSeg)+length(hSeg));
    Xpadded = fft([xSeg, zeros(1, nfft-length(xSeg)-1)]); 
    Hpadded = fft([hSeg, zeros(1, nfft-length(hSeg)-1)]); % FFT of zero-padded h
    
    XPhase = angle(Xpadded);

    % Perform multiplication Y(k)=X(k)H(k) for k=0...2N-1
    ft = abs(Hpadded .* Xpadded) .* exp(i*XPhase);
    
    % Take the 2N-point IFFT of Y(k), which yields y(n) with n=0...2N-1
    segment = real(ifft(ft)) .* hanningzSynth;
    
    % Once the segment is computed we need to do an overlap and add
    y(hop:hop+winSize*2-2) = y(hop:hop+winSize*2-2)...
        + segment;
    
    hop = 1 + n*hopSize;
end

% Normalize
ySound1 = y./(max(abs(y))*1.001);

wavwrite(ySound1, Fs2, nbits2, 'outputPart5_PhaseX_BlockWindowing');

% Scenario 2 - using the phase of the hs signal
% Acyclic Convolution with Windowing
%------------------------------------------------------------------------%
% Allocate space for windowing arrays
y = zeros(1,Nfft);

hop = 1;
for n=1: numWindows
    disp = (n-1)*hopSize +1;
    xSeg = xs(disp:disp+winSize-1);
    xSeg = xSeg .* hanningz; % window x into segments
    hSeg = hs(disp:disp+winSize-1);
    hSeg = hSeg .* hanningz; % window h into segments
    
    % "Zero-pad the signal segment x(n) and the impulse response h(n) up to
    % length 2N. Then take the 2N-point FFT of these two signals"
    % create zero padding as a power of two
    nfft = 2^nextpow2(length(xSeg)+length(hSeg));
    Xpadded = fft([xSeg, zeros(1, nfft-length(xSeg)-1)]); % FFT of zero-padded x
    Hpadded = fft([hSeg, zeros(1, nfft-length(hSeg)-1)]); % FFT of zero-padded h
    
    HPhase = angle(Hpadded);

    % Perform multiplication Y(k)=X(k)H(k) for k=0...2N-1
    ft = abs(Hpadded .* Xpadded) .* exp(i*HPhase);
    
    % Take the 2N-point IFFT of Y(k), which yields y(n) with n=0...2N-1
    segment = real(ifft(ft)) .* hanningzSynth;
    
    % Once the segment is computed we need to do an overlap and add
    y(hop:hop+winSize*2-2) = y(hop:hop+winSize*2-2)...
        + segment;
    
    hop = 1 + n*hopSize;
end

% Normalize
ySound2 = y./(max(abs(y))*1.001);

wavwrite(ySound2, Fs2, nbits2, 'outputPart5_PhaseH_BlockWindowing');

% Scenario 3 - using the phase from the xs signal
% Acyclic Convolution without Windowing
% shifted for continuity
%------------------------------------------------------------------------%
nfft = 2^nextpow2(length(xs)+length(hs)-1); % create zero padding as a power of two
Xpadded = fft(xs); % FFT of zero-padded x
Hpadded = fft(hs); % FFT of zero-padded h
YSound = (Hpadded .* Xpadded); % multiply each value at k in each sequence together
YSound = abs(YSound) .* exp(i*angle(Xpadded));
ySound3 = fftshift(real(ifft(YSound)));
ySound3 = ySound3./(max(abs(ySound3))*1.01);

wavwrite(ySound3, Fs2, nbits2, 'outputPart5_PhaseX_NoWindowing');

% Scenario 4 - using the phase from the hs signal
% Acyclic Convolution without Windowing
% shifted for continuity
%------------------------------------------------------------------------%
nfft = 2^nextpow2(length(xs)+length(hs)-1); % create zero padding as a power of two
Xpadded = fft([xs, zeros(1, nfft-length(xs))]); % FFT of zero-padded x
Hpadded = fft([hs, zeros(1, nfft-length(hs))]); % FFT of zero-padded h
YSound = (Hpadded .* Xpadded); % multiply each value at k in each sequence together
YSound = abs(YSound) .* exp(i*angle(Hpadded));
ySound4 = fftshift(real(ifft(YSound)));
ySound4 = ySound4./(max(abs(ySound4))*1.01);

wavwrite(ySound4, Fs2, nbits2, 'outputPart5_PhaseH_NoWindowing');

% plot audio output
scrsz = get(0,'ScreenSize');
figure('Position',[scrsz(1) scrsz(4) scrsz(3)/2 scrsz(4)])
subplot(5,1,1)
plot(ySound)
title('Using Combined Phases - Block Processed and Windowed','FontWeight','bold');
xlabel('Samples');
ylabel('Amplitude');
axis([0 length(ySound) -max(ySound) max(ySound)]);
subplot(5,1,2)
plot(ySound1)
title('Using Phase from X - Block Processed and Windowed','FontWeight','bold');
xlabel('Samples');
ylabel('Amplitude');
axis([0 length(ySound1) -max(ySound1) max(ySound1)]);
subplot(5,1,3)
plot(ySound2)
title('Using Phase from Y - Block Processed and Windowed','FontWeight','bold');
xlabel('Samples');
ylabel('Amplitude');
axis([0 length(ySound2) -max(ySound2) max(ySound2)]);
subplot(5,1,4)
plot(ySound3)
title('Using Phase from X - no Blocks or Windowing - Shifted','FontWeight','bold');
xlabel('Samples');
ylabel('Amplitude');
axis([0 length(ySound3) -max(ySound3) max(ySound3)]);
subplot(5,1,5)
plot(ySound4)
title('Using Phase from Y - no Blocks or Windowing - Shifted','FontWeight','bold');
xlabel('Samples');
ylabel('Amplitude');
axis([0 length(ySound4) -max(ySound4) max(ySound4)]);
