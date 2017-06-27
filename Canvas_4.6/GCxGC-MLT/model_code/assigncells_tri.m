function [cellmapP, cellmapC, midptsP, midptsC] = assigncells_tri(winP, winC, logP, logC,bdP,bdC)

N1 = size(logC,2);  % N dim 1
N2 = size(logC,1);  % N dim 2

% bdP = [-4.40 3.17];  % suggested range for N8 to N24
% % bdP = [-4.40 2.17];  % suggested range for N10 to N24
% % bdP = [-4.40 1.63];  % suggested range for N11 to N24
% % bdC = [-3.3 -0.3];
% bdC = [-3.3 0.7];
% % bdC = [-5.3 0.7];

% init num of unconstrained vars
NcellsP = ceil((bdP(2)-bdP(1))/winP);
NcellsC = ceil((bdC(2)-bdC(1))/winC);

midptsP = bdP(1) + 0.5*winP + winP*(0:(NcellsP-1)) - 0.5*(NcellsP*winP-diff(bdP));
midptsC = bdC(1) + 0.5*winC + winC*(0:(NcellsC-1)) - 0.5*(NcellsC*winC-diff(bdC));


% cellmapP = interp1(midptsP',(1:NcellsP)',logP,'linear','extrap');
% Due to new implementation of interp1 function since Matlab 2012a:
cellmapP = my_interp1(midptsP',(1:NcellsP)',logP,'linear','extrap');

% cellmapC = interp1(midptsC',(1:NcellsC)',logC,'linear','extrap');
%Due to new impl. of interp1 in R2012a:
cellmapC = my_interp1(midptsC',(1:NcellsC)',logC,'linear','extrap');

% special extra conditions to deal with edge effects ....

cellmapP(cellmapP > NcellsP) = NcellsP;      % normal
cellmapP(cellmapP < 1) = 1;  
cellmapC(cellmapC < 1) = 1;  
cellmapC(cellmapC > NcellsC) = NcellsC;  


