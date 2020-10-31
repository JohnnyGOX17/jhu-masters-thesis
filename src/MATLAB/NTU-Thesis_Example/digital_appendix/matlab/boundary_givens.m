function [s_n, c_n, r_n] = boundary_givens(r, xin, sqrtlambda)
	f = sqrtlambda*r;
	g = xin;
	if (g == 0)
		c_n = 1;
		s_n = 0;
		r_n = f;
	elseif (f == 0)
		c_n = 0;
		s_n = sign(conj(g));
		r_n = abs(g);
	else
		c_n = abs(f) / sqrt(abs(f)^2 + abs(g)^2);
		s_n = sign(f)*conj(g) / sqrt(abs(f)^2 + abs(g)^2);
		r_n = sign(f)*sqrt(abs(f)^2 + abs(g)^2);
	end
end