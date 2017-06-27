function yi = my_interp1(x,y,xi,varargin)
Meth=varargin{1};
Meth2=varargin{2};
yi = zeros(size(xi));
is_finite = isfinite(xi);
% yi(is_finite) = interp1(x,y,xi(is_finite),'linear','extrap');
yi(is_finite) = interp1(x,y,xi(is_finite),Meth,Meth2);
yi(isnan(xi)) = NaN;
yi(isinf(xi)) = Inf;
end