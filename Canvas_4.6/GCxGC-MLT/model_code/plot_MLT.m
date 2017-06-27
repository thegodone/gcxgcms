function [nb_empt]=plot_MLT(Z_0,Z_weath,NvarsP,NvarsC,cellsubind,cellsubind_wt,P,C,titleMLT,NoiseCutoff)

    FtSz = 18; %'default'; % fontsize
    masstable_0 = zeros(NvarsP,NvarsC);
    masstable_weath = zeros(NvarsP,NvarsC);
    nb_pix_in_cell = zeros(NvarsP,NvarsC);
        for j = 1:NvarsP
          for k = 1:NvarsC
               masstable_0(j,k) = sum(Z_0(cellsubind{j,k}).*cellsubind_wt{j,k});
               if masstable_0(j,k) < 0
                masstable_0(j,k) = 0;
               end
               masstable_weath(j,k) = sum(Z_weath(cellsubind{j,k}).*cellsubind_wt{j,k});
               temporary_var = cellsubind_wt{j,k};
               nb_pix_in_cell(j,k) = numel(temporary_var(temporary_var>=0.5)); % nb of pixels in the cell
%                nb_pix_in_cell(j,k) = numel(cellsubind{j,k}); % nb of pixels in the cell
               if masstable_weath(j,k) < 0
                masstable_weath(j,k) = 0;
               end
          end
        end

        LMF = log10(masstable_weath./masstable_0);
         nb_empt=0;
%          Note: nb_empt is number of cells outside of the chromatogram.
%          This does NOT include small cells on the chromatogram containing
%          only pixels with value = 0.
         for k=1:numel(cellsubind)
            nb_empt=nb_empt+isempty(cell2mat(cellsubind(k)));
         end

  %%%%% DELETE CELLS CONTAINING ONLY A VERY SMALL QUANTITY OF MASS %%%%%%%
% %              LMM = log10(masstable_0./sum(sum(masstable_0)));
% %              LMF(LMM<log10((1e-4)*numel(LMF)/160))=10;
% % % The criterion is: We compute the signal intensity per pixel (we divide
% % % all the mass in the cell by the number of pixels in that cell. Then, if
% % % this is smaller than 2% of the mean value over the chromatogram, we shade
% % % it in black.
% %         LMM = log10(masstable_0./nb_pix_in_cell);
% %         LMF(LMM < log10( (2e-2)*sum(sum(masstable_0))/sum(sum(nb_pix_in_cell)) ) ) = 10;
%          LMM = masstable_0./nb_pix_in_cell;
%          LMF(LMM < 10*NoiseCutoff ) = 10;
%              LMM = log10(masstable_0./sum(sum(masstable_0)));
%              LMF(LMM<log10((2e-4)*numel(LMF)/160))=10;
             LMM = log10(masstable_0./sum(sum(masstable_0)));
             LMF(LMM<log10(NoiseCutoff))=10;
  %%%%% DELETE CELLS CONTAINING ONLY A VERY SMALL QUANTITY OF MASS %%%%%%%

         % data manipulation to get a "clean" result
         LMF(LMF~=LMF)=10;   % remove the divide-by-zeros
         LMF(LMF==Inf)=10;   % assume no relevant (new) sources in sample i

        % assume "lower limit" of certainty is mass fraction of 5 percent
         LMF(LMF==-Inf)=log10(0.05) ;
         LMF(LMF < log10(0.05))=log10(0.05); 
         
        % For plotting purposes, we will plot the cells with more than 100%
        % mass gain in the same color as cells with 100% mass gain:
        LMF(and(LMF > log10(2),LMF~=10))=log10(2); 

        % Just some manipulation to make sure to plot all the cells:
        LMF_=zeros(size(LMF,1)+1,size(LMF,2)+1);
        LMF_(1:size(LMF,1),1:size(LMF,2))=LMF;
        P_=zeros(1,length(P)+1);
        P_(1:length(P))=P;
        P_(length(P)+1)=2*P_(length(P))-P_(length(P)-1);
        C_=zeros(1,length(C)+1);
        C_(1:length(C))=C;
        C_(length(C)+1)=2*C_(length(C))-C_(length(C)-1);

%          colormap('default');
         colormap('jet'); % default is not the same on older and more recent matlab versions
         cm = colormap;
         cm(64,:) = 0;
%          close

         colormap(cm); pcolor(P_,C_,LMF_');
         set(gca,'XDir','reverse');
         caxis([-1 0.05]); %colorbar; 
         
         c=colorbar;
         xlabel('\bflog vapor pressure [Pa]','fontsize',FtSz);
         ylabel('\bflog aqueous solubility [mol/m^{3}]','fontsize',FtSz);
         set(gca,'Fontsize',FtSz);
        caxis([log10(0.5/10),log10(2)+(abs(log10(0.5/10))+log10(2))/62]);
        title(titleMLT,'fontsize',22,'fontweight','bold');

% %         Label also '-10%' and '-30%':
%         set(c,'Ytick',log10([0.5/10,sort((1:9)/10,'ascend'),1,1.5,2]),...
%              'YTickLabel',{'>-95%';'-90%';'-80%';'-70%';'-60%';'-50%';'-40%';'-30%';...
%              '-20%';'-10%';'0%';'+50%';'>+100%'},'fontsize',FtSz);
% %         Do not label -10%' and '-30%', to have a less crowded colorbar
% %         labelling:
        set(c,'Ytick',log10([0.5/10,sort((1:9)/10,'ascend'),1,1.5,2]),...
             'YTickLabel',{'>-95%';'-90%';'-80%';'-70%';'-60%';'-50%';'-40%';' ';...
             '-20%';' ';'0%';'+50%';'>+100%'},'fontsize',FtSz);
         
         set(gcf,'units','normalized','outerposition',[0 0 1 1]);

end


