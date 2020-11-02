clear; close('all');
%% Deterministic Digital Beamformer
% givens/user defined values
N       = 3;        % number of elements in ULA (more elements = tighter mainlobe & more gain (SNR gain = N))
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
s = sqrt(SNR*noiseP)*d;


%% compute hypothesis of steering vectors from -1<>+1 (sine space) for quiescent response
% sine space is same as sin(-90:90deg)
numHyp = 400; % number of hypothesis to compute
u = linspace(-1,1,numHyp);
v = exp(1i*2*pi/wavelength*antPos'*u);
% create matched filter (beam weights) for quiescent case (no interference)
wq = v;
% unit normalize filter weights
mag = sum(wq .* conj(wq));
wq  = wq./mag;
% compute array response to incoming signal across ULA
yq = wq'*s;

% plot quiescent response in sine space
figure
plot(u*spacing, 20*log10(abs(yq)));
xlabel('Normalized angle, $\frac{d}{\lambda}\sin(\theta)$','Interpreter','latex')
ylabel('Normalized Amplitude (dB)')
grid on; ylim([-60 0]);
title('Quiescent ULA Response $\frac{d}{\lambda}=0.5$','Interpreter','latex')


%% additive noise response to quiescent beamformer
Nperiod = 1000;
xn = sqrt(noiseP/2)*(randn(N,Nperiod) + 1i*randn(N,Nperiod));
x  = repmat(s,1,Nperiod) + xn;
% apply quiescent beamformer
yn = wq'*x;

figure
plot(u*spacing, 20*log10(abs(yn(:,1))), u*spacing, 20*log10(mean(abs(yn.^2),2)));
xlabel('Normalized angle, $\frac{d}{\lambda}\sin(\theta)$','Interpreter','latex')
ylabel('Normalized Amplitude (dB)')
grid on; ylim([-60 10]);
title('Quiescent ULA Response with Noise $\frac{d}{\lambda}=0.5$','Interpreter','latex')
legend('Single Period','Average over Periods','Location','southwest')


%% Create example received signal w/additive noise & interference
thetaInf  = (rand*48)-24; % interference wave Angle of Arrival (AoA) in degrees
fInf      = rand*fc;      % interference wave frequency
lambdaInf = fc/c;
dInf      = exp(1i*2*pi/lambdaInf*antPos'*sind(thetaInf)); % phase shift over ULA

numSamp = 1000;
t  = (1:1:numSamp)/fs;
rx = sqrt(SNR*noiseP)*exp(1i*2*pi*fc*t) .* ... % fundamental cw pulse
    d +                                    ... % phase over array
    sqrt(noiseP/2)*(randn(N,numSamp) + 1i*randn(N,numSamp)); % random noise

infRx = sqrt(SNR*noiseP)*exp(1i*2*pi*fInf*t).*dInf; % interference wave
rx    = rx + infRx; % add interference to RX waveform

nonDBF = zeros(1,numSamp);
for i = 1:N % perform non-DBF (weighted sum average) across array to show effect
    nonDBF = nonDBF + (rx(i,:)/N);
end

% apply quiescent beamformer using weights matching intended incident AoA
[~,uIdx] = min(abs(u-sind(theta))); % find array position of sine space
qDBF = wq(:,uIdx)'*rx; 

figure
freqBin = (1:1:numSamp)*(fs/numSamp);
subplot(211)
plot(freqBin, 20*log10(abs(fft(nonDBF))))
title('Weighted-Sum Average Spectrum')
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
axis tight
subplot(212)
plot(freqBin, 20*log10(abs(fft(qDBF))))
xline(fc,'g--'); xline(fInf,'r--');
title('Quiescent Beamformer Spectrum')
legend('RX Spectrum', 'f_{c}', 'f_{Inf}')
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
axis tight


%% MVDR weight calculation
sv  = exp(-1i*2*pi/wavelength*antPos'*sind(theta)); % create steering vector
ymv = MVDR_beamform(conj(rx'), conj(sv));
figure
plot(freqBin, 20*log10(abs(fft(ymv))))
xline(fc,'g--'); xline(fInf,'r--');
title('MVDR Beamformer Spectrum')
legend('RX Spectrum', 'f_{c}', 'f_{Inf}')
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
