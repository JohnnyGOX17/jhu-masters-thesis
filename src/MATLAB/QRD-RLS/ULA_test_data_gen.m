clear; close('all');
%% Deterministic Digital Beamformer
% givens/user defined values
N       = 4;        % number of elements in ULA (more elements = tighter mainlobe & more gain (SNR gain = N))
fc      = 300e6;    % carrier frequency (Hz)
fs      = 1e9;      % sampling frequency (Hz)
theta   = 30;       % wave Angle of Arrival (AoA) in degrees
SNR     = 1;        % element SNR (linear)
noiseP  = 1;        % noise power (linear)
spacing = 0.5;      % d/wavelength element spacing (0.5 = half-wavelength)

% calculated constants & vectors
c           = physconst('LightSpeed');
wavelength  = fc/c;
antPos      = (0:1:N-1)*wavelength*spacing; % antenna element positions
% create spatial response vector at each ULA element
d = exp(1i*2*pi/wavelength*antPos'*sind(theta)); % phase shift over ULA

%% Create example received signal w/additive noise & interference
thetaInf  = (rand*48)-24; % interference wave Angle of Arrival (AoA) in degrees
fInf      = rand*fc;      % interference wave frequency
lambdaInf = fInf/c;
dInf      = exp(1i*2*pi/lambdaInf*antPos'*sind(thetaInf)); % phase shift over ULA

numSamp = 1000;
t  = (1:1:numSamp)/fs;
rx = sqrt(SNR*noiseP)*exp(1i*2*pi*fc*t) .* ... % fundamental cw pulse
    d +                                    ... % phase over array
    sqrt(noiseP/2)*(randn(N,numSamp) + 1i*randn(N,numSamp)); % random noise

infRx = sqrt(SNR*noiseP)*exp(1i*2*pi*fInf*t).*dInf; % interference wave
rx    = rx + infRx; % add interference to RX waveform

%% Convert Data to Signed 16b Fixed Point
maxRxVal = max(abs(rx(:)));
scaleVal = floor((2^15)/maxRxVal) - 1; % scale value for signed 16bit (-1 to not overflow)
rxs16    = round(rx*scaleVal); % scale and round to create signed 16b values
figure
subplot(211)
plot(t,real(rxs16))
title('Fixed-Point Data')
subplot(212)
freqBin = (1:numSamp)*(fs/numSamp);
plot(freqBin, 20*log10(abs(fft(rxs16(1,:)))))
title('Fixed-Point Spectrum')
xline(fc,'g--'); xline(fInf,'r--');
title('MVDR Beamformer Spectrum')
legend('RX Spectrum', 'f_{Desired}', 'f_{Interference}')
axis tight

%% Convert Steering Vector to 16b Fixed Point
maxDval  = max(abs(d));
scaleVal = floor((2^15)/maxDval) - 1; % scale value for signed 16bit (-1 to not overflow)
Ds16     = round(d*scaleVal); % scale and round to create signed 16b values

%% Write steering vector to text file
fId = fopen('steering.txt', 'w');
for i = 1:length(Ds16)
    % each row is: I Q
    I = real(Ds16(i));
    Q = imag(Ds16(i));
    fprintf(fId, '%d %d\n', I, Q);
end
fclose(fId);

%% Write FXP data to text file
fId = fopen('input.txt', 'w');
for sample = 1:length(rxs16(:,1)):length(rxs16(1,:))
    for ch = 1:length(rxs16(:,1))
        for ch_s = sample:sample+length(rxs16(:,1))-1
            % pre-build square 2D matrix, by printing out 1 of M channels
            % and M samples at a time, then reiterating
            % each row is: I Q
            I = real(rxs16(ch, ch_s));
            Q = imag(rxs16(ch, ch_s));
            fprintf(fId, '%d %d\n', I, Q);
        end
    end
end
fclose(fId);