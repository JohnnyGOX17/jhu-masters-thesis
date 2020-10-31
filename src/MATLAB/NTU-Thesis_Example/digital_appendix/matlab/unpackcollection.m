function [time, ref, x] = unpackcollection(collection)
	% UNPACKCOLLECTION take a timeseries collection containing channels
	% 'REF', 'CH1', 'CH2' etc., and place the contents into matlab arrays
	% for the time vector, the reference signal and the M channels.
	% For input of duration L samples, the output dimensions are;
	%	time = 1 row,  L columns
	%	ref  = 1 row,  L columns
	%   x    = M rows, L columns
    M = collection.size(2)-1; % number of channels, excluding reference
    L = collection.length();   % length of time vector

    ref = collection.get('REF').Data(1,:);
    x = zeros(M,L);

    j = 1;
    for channel = collection.gettimeseriesnames
        if (strcmp(channel,'REF'))
            continue % skip it
        end
        x(j, :) = collection.get(channel).Data(1,:);
        j = j +1;
    end
    time = collection.Time;
end