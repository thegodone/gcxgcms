% re-implemented on 2/25/2016
function A = show2dd(A,t0,t1,sensitivity)

global Period;
    
max_bound = max(max(A));
min_bound = min(min(A));
bound = max(abs(max_bound),abs(min_bound));
bound = max(bound,10);

A(1,1) = bound;
A(1,2) = -bound;

deadband = bound*max(0,min(5,5-sensitivity))/5;

A1 = log10(max(1,A-deadband));
A2 = -log10(-min(-1,A+deadband));
A = A1 + A2;

figure(2);
image([t0,t1], [0,Period], A);
colormap(scent);
axis tight;

mycolorbar;

drawnow;
    
h = get(2,'userdata');
h.linecolor = 'r';
h.textcolor = 'k';
set(2,'userdata',h);
