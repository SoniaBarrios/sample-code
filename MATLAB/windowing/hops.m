% 1. (4 marks) Obtain the time frequency diagram of two cosine waves at 
% f1 and f2 and make a plot of how the phase of each cosine wave changes at 
% each hop. Choose the hop size to be half the window size. Choose f1 to 
% have a integer number of samples per cycle, and f2 to have a non-integer 
% number of samples per cycle. The plot should show phase of each cosine 
% wave versus hop index for at least 8 hops. The Matlab diary code may 
% be useful

% Michael Dean
% V00483333
% Elec 484 - Peter Driessen - 2011

clear all;
close all;

% Initialize neccessary variables
% ------------------------------------------------------------
T_Int = 64; % samples
T_NotInt = 0.779*T_Int; % non-int length period
% get frequencies for each signal
f_Int = 1/T_Int; % this is 'f1'
f_NotInt = 1/T_NotInt; % this is 'f2'

% each window is the length of an integer period cosine
winSize = T_Int; % each window is the length of one period
hopSize = winSize/2; % hopSize is half window size\
numWindows = 9; % need 9 so we can get 8 hops due to overlapping

% hanningz window function
hanningz=0.5*(1-cos(2*pi*(0:winSize-1)/(winSize)));

% length of signal is 9 hops
n=1:numWindows*hopSize;

% Create example cosine functions
% ------------------------------------------------------------
y_Int = cos(2*pi*f_Int*n); % Cosine with int number of samples
y_NotInt = cos(2*pi*f_NotInt*n); % cosine with non-int no. samples

% Window the functions with hanningz
% Take FFT
% Use Mag spectrum to find appropriate phase value in each window
% Store each phase value in an array, index by hop number
% ------------------------------------------------------------
y_IntWin = zeros(numWindows-1, winSize); % allocate space
y_IntPhases = zeros(1, numWindows-1); % phases for 8 hops

y_NotIntWin = zeros(numWindows-1, winSize); % allocate space
y_NotIntPhases = zeros(1, numWindows-1); % phases for 8 hops

for idx=1:numWindows-1 % since last window will be out of bounds
    hop = (idx-1)*hopSize+1;
    % store windowed portions of functions
    y_IntWin(idx,:)=y_Int(hop:hop+winSize-1)*hanningz(:);
    y_NotIntWin(idx,:)=y_NotInt(hop:hop+winSize-1)*hanningz(:);
    
    % Use FFT to find phase for each window
    y_IntFFTSegment = fft(y_IntWin(idx,:));
    [value,maxInt] = max(abs(y_IntFFTSegment(:)));
    y_IntPhases(idx) = angle(y_IntFFTSegment(maxInt));
    
    y_NotIntFFTSegment = fft(y_NotIntWin(idx,:));
    [value,maxInt] = max(abs(y_NotIntFFTSegment(:)));
    y_NotIntPhases(idx) = angle(y_NotIntFFTSegment(maxInt));
end

% Plot results
figure(1)
% Plot results for integer length cosine wave
subplot(2,2,1);
plot(n,y_Int);
title('Cosine Wave - Int No. Samples, Hop=32 samples', 'FontWeight',...
    'Bold');
xlabel('No. Samples (64 per window)');
ylabel('Amplitude');
axis([1 hopSize*numWindows-1 -1 1]);
subplot(2,2,3);
stem(1:numWindows-1,y_IntPhases);
title('Phases of Windows for 8 Hops (Int Cos)', 'FontWeight',...
    'Bold');
xlabel('Hop Window');
ylabel('Phase Value');
axis([1 numWindows-1 -pi pi]);


% Plot results for non-integer length cosine wave
subplot(2,2,2);
plot(n,y_NotInt);
title('Cosine Wave - Non-Int No. Samples, Hop=32 samples', 'FontWeight',...
    'Bold');
xlabel('No. Samples (64 per window)');
ylabel('Amplitude');
axis([1 hopSize*numWindows-1 -1 1]);
subplot(2,2,4);
stem(1:numWindows-1,y_NotIntPhases);
title('Phases of Windows for 8 Hops (NotInt Cos)', 'FontWeight',...
    'Bold');
xlabel('Hop Window');
ylabel('Phase Value');
axis([1 numWindows-1 -pi pi]);
