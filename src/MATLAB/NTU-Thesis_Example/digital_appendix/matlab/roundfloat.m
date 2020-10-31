function xprime=roundfloat(x,p)
%ROUNDFLOAT Round floating-point numbers, with convergent rounding for fraction = 0.5
%
%   Examples:
%     roundfloat([-15:15],3) %floating-point rounding

%   Algorithm:
%      It makes use of the built-in convergent rounding of IEEE double
%      precision number representation. The first addition shifts the
%      mantissa to the right, the co-processor executes rounding, and then
%      the quantized number is restored by subtracting the same quantity.
%      Little tweaking was introduced to handle also denormalized numbers
%      properly.

%	Copyright (c) I. Kollar, 2006, all rights reserved
%	Last modified: 1-Oct-2006

%error(nargchk(2,2,nargin))
if p==53, xprime=x; return, end
if p>52, error('p is larger than 52'), end
if p<2, error('p is smaller than 2'), end
if rem(p,1)~=0, error('p is not integer'), end

%persistent xi xr f e dxp xprimei
if any(imag(x(:))), xi=imag(x); x=real(x); else xi=[]; end
%
[f,e]=log2(x); dxp=sign(x).*pow2(max(e,-1021)+52-p); xprime=(x+dxp)-dxp;
%
if ~isempty(xi)
  [f,e]=log2(xi); dxp=sign(xi).*pow2(max(e,-1021)+52-p); xprimei=(xi+dxp)-dxp;
  xprime=xprime+j*xprimei;
end
%
%End of roundfloat