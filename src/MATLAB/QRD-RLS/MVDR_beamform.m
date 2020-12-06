%% X = 2D input sample array(samples x element), sv = steering vector,
%  Y = output beam, w = MVDR weights
function [Y, w] = MVDR_beamform(X, sv)
    % form covariance matrix of input samples
    Ecx = X.'*conj(X);

    % compute weight vector using steering vector
    % NOTE: the MATLAB '\' operator is a 2-3x more efficient inv() operation
    %       for solving systems of linear equations than inv(Ecx)*sv
    wp = Ecx\sv;

    % normalize response
    w = wp/(sv'*wp);

    % form output beam
    Y = X*conj(w);
end