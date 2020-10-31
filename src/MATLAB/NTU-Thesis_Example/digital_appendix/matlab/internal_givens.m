function [s_n, c_n, r_n, xout] = internal_givens(s, c, r, xin, sqrtlambda)
	xout = c * xin - conj(s) * sqrtlambda * r;
	r_n	= s * xin + c * sqrtlambda * r;
	s_n = s;
	c_n = c;
end