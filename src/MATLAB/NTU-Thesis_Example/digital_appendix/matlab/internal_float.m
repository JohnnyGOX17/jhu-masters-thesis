function [s_n, c_n, r_n, xout] = internal_float(s, c, r, xin, sqrtlambda)
	q = @(v) roundfloat(v,22); % quantizer
	
	% s and c already quantized
	xin = q(xin);
	sqrtlambda = q(sqrtlambda);
	r = q(r);
	
	xout	= c * xin - conj(s) * sqrtlambda * r;
	r_n	= s * xin + c * sqrtlambda * r;
	
	s_n = s;
	c_n = c;
	xout = q(xout);
	r_n = q(r_n);
end