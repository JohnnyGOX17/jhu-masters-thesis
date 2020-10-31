function [s_n, c_n, r_n] = boundary_float(r, xin, sqrtlambda)
	q = @(v) roundfloat(v,22); % quantizer
	
	xin = q(xin);
	sqrtlambda = q(sqrtlambda);
	r = q(r);
	
	f = q(sqrtlambda*r);
	if (xin == 0)
		c_n = 1;
		s_n = 0;
		r_n = f;
	else
		r_n = sqrt(q( q(f^2) + q( q(real(xin)^2) + q(imag(xin)^2) ) ));
		s_n = q(conj(xin) / r_n);
		c_n = q(f / r_n);
	end
	r_n = q(r_n);
end