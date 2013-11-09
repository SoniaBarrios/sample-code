% Elec 484 Summer 2011
% Mike Dean
% Assignment 6 - Convolution

clear all;
close all;

% 1.2	Acyclic (aperiodic) convolution in both time and frequency domain 
%       using zero padding (entire file length) (result will be twice the 
%       original file length)

% allocate space for sequences
x = zeros(1,32); % allocate space for x
h = x(1:8); % allocate space for h
hDecay=1; % set initial value for impulse response, with exp. decay

% Fill arrays
% x is a linear slope function
% h is a exponentially decaying impulse response
for i=1: length(x)
    x(i)=i-1;
end
for i=1: length(h)
    h(i)=hDecay;
    hDecay=hDecay*exp(-i*0.1); % cause the impulse reponse to be exp. 
                                   % rate of decay
end

% Print x and h input
xIn = x
hIn = h

% Time Domain (Acyclic convolution)
%------------------------------------------------------------------------%
timeDomain = conv(x,h); %Matlab's conv() function is acyclic convolution
timeDomain = timeDomain./max(timeDomain)

% Freq. domain (Fast Fourier Transform)
%------------------------------------------------------------------------%
% From DAFX - Follow steps on page 264, Ch. 8
% "Zero-pad the signal segment x(n) and the impulse response h(n) up to
% length 2N. Then take the 2N-point FFT of these two signals"
nfft = 2^nextpow2(length(x)+length(h)-1); % create zero padding as a power of two
Xpadded = fft([x, zeros(1, nfft-length(x))]); % FFT of zero-padded x
Hpadded = fft([h, zeros(1, nfft-length(h))]); % FFT of zero-padded h

% Perform multiplication Y(k)=X(k)H(k) for k=0...2N-1
Y = Hpadded .* Xpadded; % multiply each value at k in each sequence together

% Take the 2N-point IFFT of Y(k), which yields y(n) with n=0...2N-1
freqDomain = real(ifft(Y));
freqDomain = freqDomain./max(freqDomain)

% Print x and h output
xOut = x
hOut = h


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

nfft = 2^nextpow2(length(xs)+length(hs)-1); % create zero padding as a power of two
XSoundPad = fft([xs, zeros(1, nfft-length(xs))]); % FFT of zero-padded x
HSoundPad = fft([hs, zeros(1, nfft-length(hs))]); % FFT of zero-padded h
YSound = (HSoundPad .* XSoundPad); % multiply each value at k in each sequence together
ySound = real(ifft(YSound));
ySound = ySound./(max(abs(ySound))*1.01);

wavwrite(ySound, Fs2, nbits2, 'outputPart2');

% Plot Output and Results
%------------------------------------------------------------------------%
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
axis([0 length(timeDomain) 0 max(timeDomain)]);

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
