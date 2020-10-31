clear; close all;
%% Simulates the systolic array dataflow for the QR Decomposition
N = 3;
M = 100;
sqrtlambda = 0.99;

X       = ones(N, M) + 1i*ones(N,M);
D       = zeros(1, M) + 1i*zeros(1,M);
rowOut  = zeros(1, N); % internal array row outputs
cellMem = zeros(N+1,N+1); % boundary/internal cell memories for systolic array

sqrtgamma_tmp = 0; % boundary cell output per row
% for k for each input sample
for i = 1:N+1 % cycles each row, follow data flow within row
    c_tmp = 0; s_tmp = 0;
    for j = N+2-i:-1:1
        if i == 1 % first row, use x() input sample array
            if j == N+2-i % boundary cell
                [c_tmp, s_tmp, sqrtgamma_tmp, cellMem(i,j)] = ...
                    boundary_cell(X(j-1,1), 1, cellMem(i,j), sqrtlambda);
            elseif j == 1 % use d() vector
                [c_tmp, s_tmp, rowOut(j), cellMem(i,j)] = ...
                    internal_cell(c_tmp, s_tmp, D(1), cellMem(i,j), sqrtlambda);
            else
                [c_tmp, s_tmp, rowOut(j), cellMem(i,j)] = ...
                    internal_cell(c_tmp, s_tmp, X(j-1,1), cellMem(i,j), sqrtlambda);
            end
        else % use rowOut() previous internal outputs
            if j == N+2-i % boundary cell
                [c_tmp, s_tmp, sqrtgamma_tmp, cellMem(i,j)] = ...
                    boundary_cell(rowOut(j), sqrtgamma_tmp, cellMem(i,j), sqrtlambda);
            else
                [c_tmp, s_tmp, rowOut(j), cellMem(i,j)] = ...
                    internal_cell(c_tmp, s_tmp, rowOut(j), cellMem(i,j), sqrtlambda);
            end 
        end
    end
end