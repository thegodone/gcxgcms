% Generate a finite element mapping onto the chromatogram. By default, the 
% elements will correspond to a grid of log vapor pressure contours and log
% aqueous solubility contours. However other properties could also be mapped.

function [NvarsP, NvarsC, P, C, cellsubind, cellsubind_wt] = make_finiteelements(winP,winC,logPl,logCw,Z,acquisition_rate,modulation_period,acquisition_delay,plot_flag,program_flag,Bleed_cutoff,bdP,bdC)
% INPUTS:
% - winP: bin size for vapor pressure
% - winC: bin size for solubility
% - logPl: vapor pressure estimates for each pixel in the chromatogram
% - logCw: solubility estimates for each pixel in the chromatogram
% - Z: chromatogram
% 
% OUTPUTS:
% - cellsubind: indices of elements in Z that belong to each cell.
% - cellsubind_w: weight for each pixel in the cell.
% - P: vapor pressure value for each cell.
% - C: solubility value for each cell.
% - NvarsP: number of vapor pressure cells
% - NvarsC: number of solubility cells

% Assign triangle elements, then convert to trapezoid elements
[cellindexP, cellindexC, P, C] = assigncells_tri(winP, winC, logPl, logCw,bdP,bdC);
[cellindexP,cellindexC] = tri2trap(cellindexP,cellindexC);

NvarsP = max(max(floor(cellindexP)));
NvarsC = max(max(floor(cellindexC)));

% Any time you change the dimensions of the chromatomgram, the values of
% the matrices logP or logC, or the winP or winC variables, you must create
% new cellsubind and cellsubind_wt tables. 
cellsubind_flag = 1; %input('Generate new cellsubind and cellsubind_wt tables? (0 for no, 1 for yes)\n? ');
if (cellsubind_flag == 1)
%  disp('Generating cellindex table and cellindex weight table...');
 disp(datestr(now));
 cellsubind = cell(NvarsP,NvarsC);     % create cell array, b/c each cell element vector is a different size
 cellsubind_wt = cell(NvarsP,NvarsC);  % create cell array, b/c each cell element vector is a different size
 for j = 1:NvarsP
  for k = 1:NvarsC
   cellsubind{j,k} = intersect(find(floor(cellindexP)==j | ceil(cellindexP)==j),find(floor(cellindexC)==k | ceil(cellindexC)==k));
   cellsubind_wt{j,k} = (1-abs(cellindexP(cellsubind{j,k})-j)).*(1-abs(cellindexC(cellsubind{j,k})-k));
  end
 end
 
 for k = 1:size(cellsubind,1)
    for m = 1:size(cellsubind,2)
        cellsubind{k,m} = cellsubind{k,m}(cellsubind{k,m}<=size(Z,1)*size(Z,2));
        cellsubind_wt{k,m} = cellsubind_wt{k,m}(cellsubind{k,m}<=size(Z,1)*size(Z,2));
    end
 end
 
 disp('Saving tables cellsubind.mat and cellsubind_wt.mat.');
 save(['../users/output/cellsubind',program_flag],'cellsubind' );
 save(['../users/output/cellsubind_wt',program_flag],'cellsubind_wt');
 disp('Done with that.');
end
if (cellsubind_flag == 0)
 disp('Loading tables cellsubind.mat and cellsubind_wt.mat.');
 load cellsubind;
 load cellsubind_wt;
 disp('Done with that.');
end
disp(datestr(now));

% Optionally, plot an overlay of the finite element table onto the chromatogram.

% plotfiniteelements_flag = input('View overlay of finite elements onto the chromatogram? (0 for no, 1 for yes)\n? ');
if plot_flag>=1 % plotfiniteelements_flag == 1
    
    plotfiniteelements(Z, cellsubind, cellsubind_wt, cellindexP, cellindexC,acquisition_rate,modulation_period,acquisition_delay,Bleed_cutoff);

end


