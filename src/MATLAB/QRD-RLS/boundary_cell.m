%% Boundary Cell to QRD systolic array using Givens generations
%  x_out should be wrapped back to x_in to form internal cell memory
function [c_out, s_out, sqrtgamma_out, x_out] = boundary_cell(u_in, sqrtgamma_in, x_in, sqrtlambda)
    if u_in == 0
        c_out         = 1;
        s_out         = 0;
        sqrtgamma_out = sqrtgamma_in;
        x_out         = sqrtlambda*x_in;
    else
        x_prime       = sqrt((sqrtlambda*x_in)^2 + abs(u_in)^2);
        c_out         = sqrtlambda*x_in/x_prime;
        s_out         = u_in/x_prime;
        x_out         = x_prime;
        sqrtgamma_out = c_out*sqrtgamma_in;
    end
end