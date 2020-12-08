%clear; close('all');
%% Environment Variables for QRD/IQRD Simulink sims
% givens/user defined values
N       = 8;        % number of elements in ULA (more elements = tighter
                    % mainlobe & more gain (SNR gain = N))
fc      = 30e6;     % carrier frequency (Hz)
finf    = 200e6;    % interference frequency (Hz)
fs      = 1e9;      % sampling frequency (Hz)
thetaD  = 0;        % desired wave Angle of Arrival (AoA) in degrees
thetaI  = 55;       % interference wave Angle of Arrival (AoA) in degrees
SNR     = 1;        % element SNR (linear)
noiseP  = 1;        % noise power (linear)
spacing = 0.5;      % d/wavelength element spacing (0.5 = half-wavelength)
lambda  = 0.995;    % forgetting factor
sigma   = 1e-6;     % initial QR upper array value (inv cells use 1/sigma)


%% calculated constants & vectors
c           = physconst('LightSpeed');
wavelength  = fc/c;               % fundamental/desired wavelength
wavelengthI = finf/c;             % interference signal wavelength
d           = wavelength*spacing; % antenna element spacing (m, match wavelength units)

eAngD   = (2*pi*d/wavelength)*sind(thetaD); % electrical angle of desired signal
phShftD = (0:1:N-1)*eAngD;            % phase shift @ each element (radians)
sv      = exp(-1i*phShftD);           % build ideal steering vector (cmplx phase shift phasor)
sv      = sv - 0.0001*1i; % just used to not have 1 + 0i interpreted as real in Simulink

eAngI   = (2*pi*d/wavelengthI)*sind(thetaI); % electrical angle of interference signal
phShftI = (0:1:N-1)*eAngI;            % interference phase shift @ each element (radians)


%% compute hypothesis of steering vectors from -1<>+1 (sine space)
% sine space is same as sin(-90:90deg)
numHyp = 400; % number of hypothesis to compute
u = linspace(-1,1,numHyp);
antPos = (0:1:N-1)*wavelength*spacing; % antenna element positions
wq = exp(1i*2*pi/wavelength*antPos'*u);
% unit normalize quiescent filter weights
mag = sum(wq .* conj(wq));
wq  = wq./mag;


%% Plot weight outputs from Simulink in Sine space
w_out = zeros(N,1);
for i = 1:N % create weight vector from Simulink outputs
    % use last element as proper weight to plot
    w_out(i) = out.w_out(length(out.w_out),i);
end

sin_iqrd = w_out'*wq;
figure
plot(u*spacing, 20*log10(abs(sin_iqrd)));
xline(sind(thetaD)*spacing,'g--');
xline(sind(thetaI)*spacing,'r--');
xlabel('Normalized angle, $\frac{d}{\lambda}\sin(\theta)$','Interpreter','latex')
ylabel('Amplitude (dB)')
title('IQRD Response Sine Space $\frac{d}{\lambda}=0.5$','Interpreter','latex')
legend('IQRD', '\theta_{c}', '\theta_{Inf}')