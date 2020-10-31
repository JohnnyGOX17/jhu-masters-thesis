classdef STAPProcessor < Processor
	methods(Static)
		function [collection] = Process(input, N)
			% PROCESS Expand a collection of M channels into MN channels
			% where additional channels represent temporal taps.
			% Input should be a time series collection with the reference
			% channel named 'REF', and any extra channels named 'CH1',
			% 'CH2' etc. The parameter N selects the number of taps.
			
			M = input.size(2)-1; % number of channels, excluding reference
			L = input.length();   % length of time vector

			[time, ref, x_in] = unpackcollection(input);

			x_out = zeros(M*N,L);

			for j = N:L		% for each timestep, create a snapshot of all
				for n=1:N	% signals in the STAP filter, including current
					% input and N-1 preceding inputs
					x_out((1:M)+(n-1)*M, j) = x_in( 1:M, j-(n-1) );
				end
			end

			collection = tscollection();
			ref_ts = CustomSeries(ref(N:end), time(N:end)); 
			collection = collection.addts(ref_ts, 'REF');

			for j = 1:M*N
				chan_ts = CustomSeries(x_out(j,N:end), input.Time(N:end));
				collection =collection.addts(chan_ts, sprintf('CH%i',j));
			end
		end
	end
end

