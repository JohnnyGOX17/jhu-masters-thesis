clear; close('all');
%% Environment Variables for QRD/IQRD Simulink sims
% givens/user defined values
N       = 8;        % number of elements in ULA (more elements = tighter
                    % mainlobe & more gain (SNR gain = N))
fc      = 30e6;     % carrier frequency (Hz)
finf    = 200e6;    % interference frequency (Hz)
fs      = 1e9;      % sampling frequency (Hz)
thetaD  = 33;       % desired wave Angle of Arrival (AoA) in degrees
thetaI  = 75;       % interference wave Angle of Arrival (AoA) in degrees
SNR     = 10;       % element SNR (linear)
noiseP  = 1;        % noise power (linear)
spacing = 0.5;      % d/wavelength element spacing (0.5 = half-wavelength)
lambda  = 0.995;    % forgetting factor
sigma   = 1e-6;     % initial QR upper array value (inv cells use 1/sigma)


% calculated constants & vectors
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

% % create spatial response vector at each ULA element
% antPos      = (0:1:N-1)*wavelength*spacing; % antenna element positions
% phShftD = antPos'*sind(thetaD);             % phase shift over ULA for desired wave
% phShftI = antPos'*sind(thetaI);             % phase shift over ULA for interference wave
% d       = exp(1i*2*pi/wavelength*phShftD);  % phase shift phasor
% sv      = exp(-1i*2*pi/wavelength*phShftD); % create steering vector