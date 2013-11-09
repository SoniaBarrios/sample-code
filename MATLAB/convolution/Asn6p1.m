% Elec 484 Summer 2011
% Mike Dean
% Assignment 6 - Convolution

clear all;
close all;

% 1.1.	Circular (cyclic, periodic) convolution in both time and frequency
% domain (entire file length). Result will be same length as input.

% allocate space for sequences
% note that both arays are same length
x = zeros(1,32);
h = x;
y = x;
m=1;

% fill arrays
for i=1: length(x)
    x(i)=i-1;
    h(i)=m;
    m=m*exp(-i*0.1);
end

% time reversal
hRev = fliplr(h);

% shift right one spot for conv formula
hRev = [hRev(length(hRev)) hRev(1:length(hRev)-1)];

% Print x and h input
xIn = x
hIn = h

% Do the convolution
for i = 1:length(x)
    y(i) = x * hRev.';
    hRev = [hRev(length(hRev)) hRev(1:length(hRev)-1)];
end

% compare the time and frequency domain representations
timeDomain = y./max(y)
freqDomain = real(ifft(fft(x) .* fft(h)));
freqDomain = freqDomain./max(freqDomain)

% Print x and h output
xOut = x
hOut = h

% now convolve two audio files
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

hsZ = [hs zeros(1, length(xs)-length(hs))];
freqDomainSound = real(ifft(fft(xs) .* fft(hsZ)));
ySound = freqDomainSound./(max(abs(freqDomainSound))*1.01);

wavwrite(ySound, Fs2, nbits2, 'outputPart1');

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
plot(hsZ)
title('Input Signal #2','FontWeight','bold');
xlabel('Samples');
ylabel('Amplitude');
axis([0 length(hsZ) -max(hsZ) max(hsZ)]);
subplot(3,1,3)
plot(freqDomainSound)
title('Convolution Output Signal','FontWeight','bold');
xlabel('Samples');
ylabel('Amplitude');
axis([0 length(freqDomainSound) -max(freqDomainSound) max(freqDomainSound)]);