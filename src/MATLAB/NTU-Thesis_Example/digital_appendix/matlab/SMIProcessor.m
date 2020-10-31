classdef SMIProcessor < Processor
	methods (Static)
		function [output_ts, weight_ts] = Process(input, estimate_K, delta)
			% PROCESS Apply sample matrix inversion. Input should be a time
			% series collection with the reference channel named 'REF',
			% and any extra channels named 'CH1', 'CH2' etc.
			% Returns filtered output and weight vector at every sample.
			[time, d, x] = unpackcollection(input);

			NM = input.size(2)-1;
			L = input.length();   % length of time vector

			SampleCor=zeros(NM,NM,L);
			SampleAutoCor=zeros(NM,L);
			Cor=zeros(NM,NM,L);
			AutoCor=zeros(NM,L);

			outdata = zeros(1,L);
			weights = zeros(NM,L);

			for l=1:L % correlation matrices for each time step
				SampleAutoCor(:,l) = x(:,l)*conj(d(l));
				SampleCor(:,:,l) = x(:,l)*x(:,l)';
			end

			% Time-average the correlation matrices. At start of sequence,
			% use any previous samples available, up to K+1 samples
			span_min = -(estimate_K-1);	% Desired left/right offsets for
			span_max = 0;				% averaging window
			for l = 1:L
				limited_min = max(l+span_min, 1); % find window indexes
				limited_max = min(l+span_max, L);
				avg_span = limited_min:limited_max;
				AutoCor(:,l) = mean( SampleAutoCor(:, avg_span) ,2);
				Cor(:,:,l) = mean( SampleCor(:,:, avg_span) ,3) + (1/delta)*eye(NM);
			end

			% Apply SMI filter
			for l = 1:L
				weights(:,l) = inv(Cor(:,:,l))*AutoCor(:,l); % R_xx^-1 * r_xd
				outdata(l) = d(l) - weights(:,l)'*x(:,l); % e = d - w^H * x
			end

			output_ts = CustomSeries(outdata, time);
			weight_ts = CustomSeries(weights, time);
		end
	end
end

