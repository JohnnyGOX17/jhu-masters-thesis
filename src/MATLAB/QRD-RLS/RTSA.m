clear; close('all');
%% Real-Time Spectrum Analysis (RTSA) Params
fs       = 48e3;    % sampling frequency (Hz)
tot_time = 20;      % total time (seconds)
fft_len  = 8192;    % FFT length to use in STFT calcs (keep to pow2 sizes)
overlap  = 16;      % Number of overlapped FFTs for RTSA (keep to pow2 sizes)
t        = linspace(0, tot_time - 1/fs, fs * tot_time);

%% Create input signal w/mix of tones & chirps (Hz)
freqs  = [300, 1200, 3000, 7000];
chirps = [100, 300; ...
          200, 10000];
sig    = zeros(size(t));

% create short, HF pulse
fPulse     = 777;
numSampPer = round(fs/fPulse); % number of samples for 1x period in fs
numCycles  = 8; % num cycles of HF pulse to generate
numHFsamp  = numCycles*numSampPer;
% pulse sample start near boundary of FFT window
pulseStart = (5*fft_len)-round(numHFsamp/2);
pulseEnd   = pulseStart + numHFsamp;
sig(pulseStart:pulseEnd) = 5*sin(2*pi*t(pulseStart:pulseEnd)*fPulse);

if ~isempty(freqs) % create tones
    for i = 1:length(freqs)
        sig = sig + sin(2*pi*t*freqs(i));
    end
end

if ~isempty(chirps) % create chirps
    for i = 1:size(chirps, 1)
        sig = sig + chirp(t, chirps(i,1), t(end), chirps(i,2));
    end
end


%% Plot standard Short-Time Fourier Transform (STFT, no-overlap)
figure
num_full_ffts = floor(length(sig) / fft_len); % # of back-to-back FFTs to do
basicSig = sig(1:num_full_ffts * fft_len);
S   = reshape(basicSig, fft_len, num_full_ffts);
S   = fftshift(fft(S), 1);
%stft_time = 0:tot_time/num_full_ffts:tot_time;
imagesc(20*log10(abs(S)));
title('STFT, No Overlap')
xlabel('FFT Iteration'); ylabel('FFT Bin');


%% RTSA Process (Overlapped STFTs)
num_stfts = overlap*floor(length(sig) / fft_len); % # of total STFTs to do
rtsaOut   = zeros(fft_len, num_stfts);
stftStep  = fft_len/overlap; % number of samples to slide in each STFT step
for i = 1:num_stfts-overlap+1
    lowIdx  = ((i-1)*stftStep)+1;
    highIdx = lowIdx + fft_len - 1;
    rtsaOut(:,i) = fftshift(fft(sig(lowIdx:highIdx)));
end
figure
imagesc(20*log10(abs(rtsaOut)));
title(['STFT, ',num2str(overlap),'x Overlap'])
xlabel('FFT Iteration'); ylabel('FFT Bin');