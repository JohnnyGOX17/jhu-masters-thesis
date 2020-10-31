function [phi_n, theta_n, r_n, xout] = internal_cordic(phi, theta, r, xin, sqrtlambda)
	f = sqrtlambda*r;
	
	% simulates the four CORDIC rotators by treating the CORDIC inputs
	% as a complex number, and rotating it by multiplying with exp(i*theta)
	xin = xin * exp(-1i*phi); % phi-CORDIC rotator
	
	m = complex(real(f), real(xin))*exp(-1i*theta); % theta-CORDIC rotators
	n = complex(imag(f), imag(xin))*exp(-1i*theta); % -"-
	
	r_n = complex(real(m), real(n));
	
	xout = complex(imag(m), imag(n))*exp(1i*phi); % reverse phi-CORDIC rotator
	
	phi_n = phi;
	theta_n = theta;
end