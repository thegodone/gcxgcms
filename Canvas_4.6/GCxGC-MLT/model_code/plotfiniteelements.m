% plot overlay of finite elements onto a chromatogram.
function plotfiniteelements(Z, cellsubind, cellsubind_wt, cellindexP, cellindexC,acquisition_rate,modulation_period,acquisition_delay,Bleed_cutoff)

NvarsP = size(cellsubind,1);
NvarsC = size(cellsubind,2);

% checkerplot of finite element weighting assignments
Zass = zeros(size(Z,1),size(Z,2));
for j = 1:2:NvarsP            
 for k = 1:2:NvarsC
  Zass(cellsubind{j,k})=cellsubind_wt{j,k};
 end
end

% 'pixels' give less clean figures. Use 'time' a priori.
units = 'time'; % or 'pixels'

if strcmpi(units,'pixels')
    fig1 = figure; contour(cellindexP,[(1:(NvarsP+1))-0.5]);
    hold on; contour(cellindexC,[(1:(NvarsC+1))-0.5]); %disp(size(Zass))
    pcolor(Zass); shading flat; caxis([0 1]); colorbar;
end


if strcmpi(units,'time')
    % How many pixels we have in the first dimension:
    nb_measX = size(Z,2); % [pixel], number of 1st dimension measurements
    % 2-D matrices of 1st (X) and 2nd (Y) dimension elution times:
    X = acquisition_delay/60+ones(modulation_period*acquisition_rate,1)*(0:(nb_measX-1))*modulation_period/60; % min, first dimension elution times for all pixels
    Y = ((0:(modulation_period*acquisition_rate-1))'/acquisition_rate)*ones(1,nb_measX); % s, second dimension elution times for all pixels
    X2 = X;
    X2(Y<=Bleed_cutoff) = NaN;
    Y2 = Y;
    Y2(Y<=Bleed_cutoff) = NaN;
    fig1 = figure; contour(X2,Y2,cellindexP,[(1:(NvarsP+1))-0.5]);
    hold on; contour(X2,Y2,cellindexC,[(1:(NvarsC+1))-0.5]); %disp(size(Zass))
    Zass(Y<=Bleed_cutoff) = NaN;
    pcolor(X,Y,Zass); shading flat; caxis([0 1]); colorbar;
end
colormap('jet'); 
set(gca,'tickdir','out')
hold off;
title('Checkerplot heat map of finite element weighting','fontsize',18);
set(gca,'fontsize',18)
set(colorbar,'fontsize',18)
set(gcf,'units','normalized','outerposition',[0 0 1 1])

Z(Z<0)=0;
fig2 = figure; 
if strcmpi(units,'pixels')
    plotChromato(Z,'fontsize',18); hold off;
elseif strcmpi(units,'time')
    plotChromato(X,Y,Z,'fontsize',18); hold off;
    FtSz = 18; % fontsize for x and y labels.
    xlabel('\bfFirst dimension retention time [min]','fontsize',FtSz)
    ylabel('\bfSecond dimension retention time [s]','fontsize',FtSz)
end
c_axis = caxis;
caxis([-1.001* (c_axis(2) - 0)/64,(c_axis(2) - 0)*63/64])

hold on
% Plot now the contours, with negative values:
fact = 2 * (-1.001* (c_axis(2) - 0)/64);
if strcmpi(units,'pixels')
    contour(cellindexP+fact,((1:(NvarsP+1))-0.5)+fact,'linewidth',1); hold on;
    contour(cellindexC+fact,((1:(NvarsC+1))-0.5)+fact,'linewidth',1);
elseif strcmpi(units,'time')
    contour(X2,Y2,cellindexP+fact,((1:(NvarsP+1))-0.5)+fact,'linewidth',1); hold on;
    contour(X2,Y2,cellindexC+fact,((1:(NvarsC+1))-0.5)+fact,'linewidth',1);
end
hold off

colormap('jet');
cm2 = colormap;
cm2(1,:) = ([1 0 1]);
colormap(cm2);
hold off;
title('Finite element boundaries overlaid onto the chromatogram','fontsize',18);
set(gca,'fontsize',18)
colorbar
set(colorbar,'fontsize',18)
set(gca,'tickdir','out')
box off
set(gcf,'units','normalized','outerposition',[0 0 1 1])

figure(fig2);
a_xis = axis;
figure(fig1);
axis(a_xis);
if strcmpi(units,'time')
    xlabel('\bfFirst dimension retention time [min]','fontsize',FtSz)
    ylabel('\bfSecond dimension retention time [s]','fontsize',FtSz)
end
figure(fig2);

% check for mass balance of cell weighting algorithm
celltot = 0;
for j = 1:NvarsP
 for k = 1:NvarsC
  celltot = celltot + sum(Z(cellsubind{j,k}).*cellsubind_wt{j,k});
 end
end

% amount of total chromatogram mass found in cells
totalcellbalance = celltot/sum(sum(Z))    


