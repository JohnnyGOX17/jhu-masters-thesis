function [phi_n, theta_n, r_n] = boundary_cordic(r, xin, sqrtlambda)
	f = sqrtlambda*r;
	
	% simulate two vectoring CORDICs by finding the magnitudes of the
	% inputs, and the angle between the inputs
	
	r_n = sqrt(f^2 + abs(xin)^2);
	phi_n = atan2(imag(xin),real(xin));
	theta_n = atan2(abs(xin), f);
end