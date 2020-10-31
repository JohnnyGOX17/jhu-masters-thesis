classdef RLSProcessor
	methods (Static)
		function [output_ts, weight_ts] = Process(input, lambda, delta)
			% PROCESS Apply conventional RLS filter. Input should be a time
			% series collection with the reference channel named 'REF',
			% and any extra channels named 'CH1', 'CH2' etc.
			% Returns filtered output and weight vector at every sample.
			[time, d_full, x_full] = unpackcollection(input);

			MN = input.size(2)-1; % input width, excluding reference
			L = input.length();   % length of time vector

			outdata = zeros(1,L); weights = zeros(MN,L);
			w = zeros(MN, 1);

			% Algorithm-specific initialization
			lambda1 = lambda^-1;
			P = (delta^-1)*eye(MN);
			for j = 1:L
				d = d_full(j); x = x_full(:,j);
				e = d - w'*x; % a priori error, x filtered with previous filer

				K = (P*x)/(lambda + x'*P*x);

				% Uses: P (previous iteration), x (input), lambda (constant)
				Pnew = lambda1*(P - K*x'*P);

				% Uses w og P (previous iteration), x (input), lambda (constant),
				% d (input, part of e).
				wnew = w + K*conj(e);
				P = Pnew;
				w = wnew;
				weights(:,j) = w;
				outdata(j) = d - w'*x;
			end

			output_ts = CustomSeries(outdata, time);
			weight_ts = CustomSeries(weights, time);
		end
	end
end

