clear; close('all');
%% Deterministic Digital Beamformer
% givens/user defined values
fs          = 100e6; % baseband sampling frequency (Hz)
fb          = 10e6;  % baseband received pulse frequency (Hz)
N           = 8;     % number of array elements/sensors
pulseLength = 1e-6;  % seconds
pulseStart  = 1e-6;  % delay in sample time till pulse is received (s)
pulseSNR    = 3;     % received pulse SNR (dB)
theta       = 40;    % angle of arrival (AoA) relative to boresight (deg)
spacing     = 0.5;   % d/wavelength ULA spacing

% calculated constants & vectors
c  = physconst('LightSpeed');
t  = 0:1/fs:1e-5; % sampling timebase (s)
A  = 10^(pulseSNR/10); % assumes average RMS noise of around 1
tStart = pulseStart*fs; % index in time vector to "start" RX pulse
tEnd   = tStart + (pulseLength*fs);

figure
hold on
% create sample vector for each array element
rxArr = zeros(N,length(t));
for i = 1:N
    rxArr(i,:) = randn(1,length(t)); % gaussian thermal noise on ADC
    rxArr(i,tStart:tEnd) = rxArr(i,tStart:tEnd) + ...
        A*exp(1i*2*pi*fb*t(tStart:tEnd)) * ... % baseband pulse
        exp(1i*2*pi*(N-1)*spacing*sind(theta)); % wavefront phase-shift
    plot(t,abs(rxArr(i,:)),'DisplayName',['Element ',num2str(i)])
end
hold off
xlabel('Time (s)'); ylabel('|RX|');
legend show

beamformOut = zeros(1,length(t));
for i = 1:length(t)
    for j = 1:N
        beamformOut(i) = beamformOut(i) + rxArr(j,i);
    end
end
figure
plot(t, abs(beamformOut))
figure
plot(20*log10(abs(fft(beamformOut))))