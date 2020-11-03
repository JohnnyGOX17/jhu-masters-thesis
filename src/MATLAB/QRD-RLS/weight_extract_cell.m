function [a_out, w_out] = weight_extract_cell(a_in, b_in, w_in)
    a_out = a_in;
    w_out = w_in - (a_in*b_in);
end