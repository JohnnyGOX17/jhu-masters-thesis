%% Performs the systolic array dataflow of QR Decomposition and Weight Extraction
% Inputs:
%   x, 2D MxN array where N samples >> M filter coeffs
%   d, 1D steering vector 1xN array of M steering vectors
%   lambda, forgetting factor (usually slightly <1 for stability)
%   sigma,  initial QR cell values (usually very close to 0)
% Returns:
%   w, 2D complex weight MxN vector (M filter weights, per N iterations)
%   e, 1D posteriori error value output (1xN, value for each iteration)
function [w, e] = IQRD_systolic_array(x, d, lambda, sigma)
    N = length(x(1,:)); % number of samples
    M = length(x(:,1)); % filter order
    % initialize QR upper array with sigma, lower inverse QR with 1/sigma
    arrayMem = [(ones(M+1, M+2)*sigma) (ones(M+1, M+1)/sigma)];
    % used to hold output of above row for use in row below
    rowOut   = zeros(1,(M*2)+2); % zeros important for feeding right/inv QR cells
    
    e = zeros(1,N);
    w = zeros(M,N);

    for i = 1:N % iterate over sample space, for each sample column
        for row = 1:M+1 % process each row of systolic array up->down
            c_tmp = 0; s_tmp = 0; % used to hold output from left->right
            a_tmp = 0; % used for weight extraction cell left->right
            for col = row:(row+M+2) % process each column of systolic array left->right
                if row == 1 % use x & d inputs, else use past row outputs
                    rowOut(1:M) = x(:,i); % use input samples
                    rowOut(M+1) = d(i);   % use input steering vector
                    rowOut(M+2) = 1;
                end

                if row == M + 1 % last row, use weight extraction cells
                    if col == row
                        e(i)  = rowOut(col) * rowOut(col+1); % calculate error
                        a_tmp = rowOut(col); % init a->weight extract
                    elseif col == row + M + 2 % do nothing for very last column
                    elseif col >= row + 2 % use weight extraction
                        if i == 1 % no previous weights computed yet
                            [a_tmp, w(col-row-1,i)] = ...
                                weight_extract_cell(a_tmp, rowOut(col), 0);
                        else
                            [a_tmp, w(col-row-1,i)] = ...
                                weight_extract_cell(a_tmp, rowOut(col),...
                                w(col-row-1,i-1));
                        end
                    end
                else
                    if col == row % first column in row, use boundary cell for givens generation
                        [c_tmp, s_tmp, ~, arrayMem(row,col)] = ...
                            boundary_cell(rowOut(col), 0, arrayMem(row,col), sqrt(lambda));
                    elseif col <= M + 2 % use regular internal cell for givens rotation
                        [c_tmp, s_tmp, rowOut(col), arrayMem(row,col)] = ...
                            internal_cell(c_tmp, s_tmp, rowOut(col), arrayMem(row,col), sqrt(lambda));
                    else % use inverse internal cell for givens rotation
                        [c_tmp, s_tmp, rowOut(col), arrayMem(row,col)] = ...
                            internal_cell(c_tmp, s_tmp, rowOut(col), arrayMem(row,col), 1/sqrt(lambda));
                    end
                end
            end
        end
    end
end