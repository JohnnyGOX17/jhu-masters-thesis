clear; close('all');
%% Deterministic Digital Beamformer
% givens/user defined values
N       = 4;        % number of elements in ULA (more elements = tighter mainlobe & more gain (SNR gain = M))
fc      = 300e6;    % carrier frequency (Hz)
fs      = 1e9;      % sampling frequency (Hz)
theta   = 0;        % wave Angle of Arrival (AoA) in degrees
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
thetaInf      = 30;     % interference wave Angle of Arrival (AoA) in degrees
fInf          = 0.9*fc; % interference wave frequency
lambdaInf     = fInf/c;
wavelengthInf = fInf/c;

dInf = exp(1i*2*pi/lambdaInf*antPos'*sind(thetaInf)); % phase shift over ULA

M = N*100; % M received samples, where M ≥ N channels to form MxN sample matrix
t  = (1:1:M)/fs;
rx = sqrt(SNR*noiseP)*exp(1i*2*pi*fc*t) .* ... % fundamental cw pulse
    d +                                    ... % phase over array
    sqrt(noiseP/2)*(randn(N,M) + 1i*randn(N,M)); % random noise
infNoise = sqrt(noiseP/2)*(randn(N,M) + 1i*randn(N,M)).*dInf;
infRx    = sqrt(SNR*noiseP)*exp(1i*2*pi*fInf*t).*dInf; % interference wave
% add interference to RX waveform (only for section of time)
rx       = rx + infRx + infNoise;

nonDBF = zeros(1,M);
for i = 1:N % perform non-DBF (weighted sum average) across array to show effect
    nonDBF = nonDBF + (rx(i,:)/N);
end

% apply quiescent beamformer using weights matching intended incident AoA
[~,uIdx] = min(abs(u-sind(theta))); % find array position of sine space
qDBF = wq(:,uIdx)'*rx; 

figure
freqBin = (1:1:M)*(fs/M);
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
% the desired response or steering vector, repeated to create size (m,1)
b = d; % matched filter response of ULA phase shift
%  the complex received sample matrix, size (m,n) where m ≥ n
A = rx.'; % nonconjugate transpose of signal matrix to get correct dimensions
[ymv, wmv] = MVDR_beamform(A, b);
figure
plot(freqBin, 20*log10(abs(fft(ymv))))
xline(fc,'g--'); xline(fInf,'r--');
title('MVDR Beamformer Spectrum')
legend('RX Spectrum', 'f_{c}', 'f_{Inf}')
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');

sin_mvdr = wmv'*wq;
figure
plot(u*spacing, 20*log10(abs(sin_mvdr)));
xline(sind(theta)*spacing/wavelength,'g--');
xline(sind(thetaInf)*spacing/wavelengthInf,'r--');
xlabel('Normalized angle, $\frac{d}{\lambda}\sin(\theta)$','Interpreter','latex')
ylabel('Amplitude (dB)')
title('MVDR Response Sine Space $\frac{d}{\lambda}=0.5$','Interpreter','latex')
legend('MVDR', '\theta_{c}', '\theta_{Inf}')

%% QR MATLAB
Acovar = A.'*conj(A);
%Acovar = A'*A;
% the desired response or steering vector, repeated to create size (m,1)
%b = repmat(d,M/N,1); % matched filter response of ULA phase shift
[Q,R] = qr(Acovar); % perform QR decomp of input sample matrix
c_qr = Q'*b;
% perform back substituion to solve Rx = Q'b, where x = weights
w_qr = backSubstitution(R, c_qr, N);
%[~,R] = qr(A,0); % perform Q-less QR decomp of input sample matrix
%w_qr  = R\R'\b;
% form output beam from complex weights
y_qr = A*conj(w_qr);
figure
plot(freqBin, 20*log10(abs(fft(y_qr))))
xline(fc,'g--'); xline(fInf,'r--');
title('QRD Beamformer Spectrum')
legend('RX Spectrum', 'f_{c}', 'f_{Inf}')
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');

sin_qr = w_qr'*wq;
figure
plot(u*spacing, 20*log10(abs(sin_qr)));
xline(sind(theta)*spacing/wavelength,'g--');
xline(sind(thetaInf)*spacing/wavelengthInf,'r--');
xlabel('Normalized angle, $\frac{d}{\lambda}\sin(\theta)$','Interpreter','latex')
ylabel('Amplitude (dB)')
title('QR Decomposition Response Sine Space $\frac{d}{\lambda}=0.5$','Interpreter','latex')
legend('QRD', '\theta_{c}', '\theta_{Inf}')


%% Modified Gram Schmidt
% Q = zeros(N,N);
% R = zeros(N,N);
% for i = 1:N
%     Q(:,i) = A(:,i);
%     
%     for j = 1:i-1
%         R(j,i) = Q(:,j)'*Q(:,i);
%         Q(:,i) = Q(:,i) - (R(j,i)*Q(:,j));
%     end
%     
%     R(i,i) = norm(Q(:,i));
%     Q(:,i) = Q(:,i)/R(i,i);
% end
% c_qr = Q'*b;
% w_qr = zeros(N,1);
% for i = N:-1:1 % perform back substitution to find weights
%     for j = i+1:N
%         w_qr(i) = R(i,j)*w_qr(j) + w_qr(i);
%     end
%     w_qr(i) = (c_qr(i)-w_qr(i))/R(i,i);
% end


%% IQRD
lambda  = 0.995;    % forgetting factor
sigma   = 1e-6;     % initial QR upper array value (inv cells use 1/sigma)
[w_iqrd, e_iqrd] = IQRD_systolic_array(Acovar, b, lambda, sigma);
iqrdDBF = A*conj(w_iqrd(:,1)); 
figure
plot(freqBin, 20*log10(abs(fft(iqrdDBF))))