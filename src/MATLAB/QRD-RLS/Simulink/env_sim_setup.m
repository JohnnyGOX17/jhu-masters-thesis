clear; close('all');
%% Environment Variables for QRD/IQRD Simulink sims
% givens/user defined values
N       = 3;        % number of elements in ULA (more elements = tighter
                    % mainlobe & more gain (SNR gain = N))
fc      = 30e6;     % carrier frequency (Hz)
fs      = 1e9;      % sampling frequency (Hz)
theta   = 30;       % wave Angle of Arrival (AoA) in degrees
SNR     = 10;       % element SNR (linear)
noiseP  = 1;        % noise power (linear)
spacing = 0.5;      % d/wavelength element spacing (0.5 = half-wavelength)
lambda  = 0.995;    % forgetting factor
sigma   = 1e-6;     % initial QR upper array value

% calculated constants & vectors
c           = physconst('LightSpeed');
wavelength  = fc/c;
antPos      = (0:1:N-1)*wavelength*spacing; % antenna element positions

% create spatial response vector at each ULA element
phShft = antPos'*sind(theta);             % phase shift over ULA
d      = exp(1i*2*pi/wavelength*phShft);  % phase shift phasor
sv     = exp(-1i*2*pi/wavelength*phShft); % create steering vector
sv     = sv - 0.0001*1i; % just used to not have 1 + 0i as real
s      = sqrt(SNR*noiseP)*d;

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

%% Create example received signal
numSamp = 1000;
t  = (1:1:numSamp)/fs;
rx = sqrt(SNR*noiseP)*exp(1i*2*pi*fc*t) .* ... % fundamental cw pulse
    d +                                    ... % phase over array
    sqrt(noiseP/2)*(randn(N,numSamp) + 1i*randn(N,numSamp)); % random noise

nonDBF = zeros(1,numSamp);
for i = 1:N % perform non-DBF (weighted sum average) across array to show effect
    nonDBF = nonDBF + (rx(i,:)/N);
end

% apply quiescent beamformer using weights matching intended incident AoA
[~,uIdx] = min(abs(u-sind(theta))); % find array position of sine space
qDBF = wq(:,uIdx)'*rx; 
