% Elec 484 Summer 2011
% Mike Dean
% Assignment 6 - Convolution

clear all;
close all;

% 1.4.	Circular (cyclic, periodic) convolution on windowed overlapping 
% segments, raised cosine windows, cyclic shift, and overlap-add (DAFX 
% figure 8.5 where the time-frequency processing is a multiplication with 
% the time/frequency coefficients of a second signal, keep the phases of 
% only one of the signals). See also figure 8.28. Use windows 8 samples 
% long for numbers, 2048 samples long for audio file

% 1.4 try phase 1 try phase 2 try phase1+2
% time varying h has to be windowed to mult

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
hanningz=0.5*(1-cos(2*pi*(0:winSize-1)/(winSize)));
numWindows = (length(x)/winSize)*2 - 1;

% Allocate space for windowing arrays
y = zeros(1,length(x));
h = [h zeros(1,length(x)-length(h))];

% Time Domain (Cyclic convolution)
%------------------------------------------------------------------------%
hop = 1;
for i=1: numWindows
    disp = (i-1)*hopSize +1;
    segment = zeros(1,winSize);
    ySeg = segment;
    xSeg = x(disp:disp+winSize-1);
    xSeg = xSeg .* hanningz; % window x into segments
    hSeg = h(disp:disp+winSize-1);
    hSeg = hSeg .* hanningz; % window h into segments
    
    % take each x window and convolve with windowed h
    % time reversal
    hRev = fliplr(hSeg);

    % shift right one spot for conv formula
    hRev = [hRev(length(hRev)) hRev(1:length(hRev)-1)];
    
    for p=1:winSize
        % for each index of the segments, we need to multiply index by index
        for j=1:winSize
            segment(j) = hRev(j) * xSeg(j);
        end
        % then, the sum of these terms determines one of ySeg(1,2,3...n)
        ySeg(p) = sum(segment);
        hRev = [hRev(length(hRev)) hRev(1:length(hRev)-1)];
    end
    
    % Once the segment is computed we need to do an overlap and add
    y(hop:hop+winSize-1) = y(hop:hop+winSize-1)...
        + ySeg(1:winSize);
    
    hop = 1 + i*hopSize;
end
timeDomain = y./max(y);

% Freq. Domain (Cyclic convolution)
%------------------------------------------------------------------------%
hop = 1;
for i=1: numWindows
    disp = (i-1)*hopSize +1;
    xSeg = x(disp:disp+winSize-1);
    xSeg = xSeg .* hanningz; % window x into segments
    hSeg = h(disp:disp+winSize-1);
    hSeg = hSeg .* hanningz; % window h into segments
    
    xSegFFT = fft(xSeg);
    hSegFFT = fft(hSeg);
    segment = real(ifft(xSegFFT .* hSegFFT));
    
    % Once the segment is computed we need to do an overlap and add
    y(hop:hop+winSize-1) = y(hop:hop+winSize-1)...
        + segment;
    
    hop = 1 + i*hopSize;
end
freqDomain = y./max(y);

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
hanningz=0.5*(1-cos(2*pi*(0:winSize-1)/(winSize)));
numWindows = (length(xs)/winSize)*2 - 1;

% Allocate space for windowing arrays
y = zeros(1,length(xs));
hs = [hs zeros(1,length(xs)-length(hs))];

hop = 1;
for i=1: numWindows
    disp = (i-1)*hopSize +1;
    xSeg = xs(disp:disp+winSize-1);
    xSeg = xSeg .* hanningz; % window x into segments
    hSeg = hs(disp:disp+winSize-1);
    hSeg = hSeg .* hanningz; % window h into segments
    
    xSegFFT = fft(xSeg);
    hSegFFT = fft(hSeg);
    segment = real(ifft(xSegFFT .* hSegFFT));
    
    % Once the segment is computed we need to do an overlap and add
    y(hop:hop+winSize-1) = y(hop:hop+winSize-1)...
        + segment .* hanningz;
    
    hop = 1 + i*hopSize;
end

% Normalize
ySound = y./(max(abs(y))*1.001);

wavwrite(ySound, Fs2, nbits2, 'outputPart4');

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
