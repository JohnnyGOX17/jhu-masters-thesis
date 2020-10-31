%% Internal Cell to QRD systolic array using Givens rotations
%  x_out should be wrapped back to x_in to form internal cell memory
function [c_out, s_out, u_out, x_out] = internal_cell(c_in, s_in, u_in, x_in, sqrtlambda)
    u_out = (c_in * u_in) - (s_in * sqrtlambda * x_in);
    x_out = (s_in * u_in) + (c_in * sqrtlambda * x_in);
    c_out = c_in;
    s_out = s_in;
end