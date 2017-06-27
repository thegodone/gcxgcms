% A calibrated R is expected to have at least 6 columns (or 2-point calibration),
%   column 1: RT in 1st dimension
%   column 2: RT in 2nd dimension (-1 for 1D data)
%   column 3: areas for 1st concentrations
%   column 4: 1st concentrations
%   column 5: areas for 2nd concentrations
%   column 6: 2nd concentrations
% and can have at most one internal standard. It supports 3 calibration methods:
%   (1) external standards 
%   (2) internal standards (one per cluster, same conc. for columns 4,6,8,...)
%   (3) standard additions (columns 4 must be all zeros excluding IS row for non-spiked sample) 

function quantify(ch,L,R,exclude,Cluster0,nlist,file)

num = size(R)(2);
if (num==0 || min(exclude)==1)          
    system(['del "',file,'"']);
    return;                   
end                           

fp = fopen(file,'w');
for j = 1 : size(R)(2)    % loop through all clusters
    if (exclude(j))           
        continue;             
    end                       
    
    fprintf(fp,'Cluster %d\n',j);
    fprintf(fp,'Cmpd#,RT1,RT2,RT-raw,Area,Quantity,R2,Name\n'); 
    nR = size(R{j})(1);

    if (abs(R{j}(1,1)-R{j}(nR,1))<1e-5 && abs(R{j}(1,2)-R{j}(nR,2))<1e-5)
        fprintf(fp,'%d,%8.4f,%8.4f,%8.4f,%8.4f\n',0,0,0,0,sum(Cluster0{j}(:,4)));
    else
        mR = size(R{j})(2);
        if (mR>=6)        % sufficient calibration, report quantities
            printf('calibration found for cluster #%d\n',j);
            m = floor((mR-2)/2);     % m calibration points
            i0 = 0;
            for i = 1 : nR,
                if (R{j}(i,4)==R{j}(i,6)) % check if internal standard exists
                    i0 = i;
                    break;
                end
            end

            Q = zeros(nR,1);
            r2 = zeros(nR,1);
            
            if (i0==0)        % external standards (ES)
                for i = 1 : nR,
                    [k,b,cod] = regression(R{j}(i,1+2*(1:m)),R{j}(i,2+2*(1:m)));
                    if (Cluster0{j}(i,4)==0)
                        Q(i) = 0;
                    elseif (R{j}(i,4)==0)  % samples spiked with ES
                        Q(i) = -b;
                    else                   % ES calibrations
                        Q(i) = k*Cluster0{j}(i,4)+b;
                    end
                    r2(i) = cod;
                end
            else              % internal standard (IS)
                for i = 1 : nR,
                    if (i==i0)
                        Q(i) = R{j}(i,4);
                        r2(i) = 1;
                    else
                        RR = R{j}(i,1+2*(1:m))./R{j}(i0,1+2*(1:m));
                        [k,b,cod] = regression(RR,R{j}(i,2+2*(1:m)));
                        if (Cluster0{j}(i,4)==0)
                            Q(i) = 0;
                        elseif (R{j}(i,4)==0)  % fortified samples spiked with IS  
                            Q(i) = -b;
                        else                   % IS spiked
                            Q(i) = k*Cluster0{j}(i,4)/Cluster0{j}(i0,4)+b;
                        end
                        r2(i) = cod;
                    end
                end
            end
            
            % Following 2 for-loops were modified on 11/30/2015
            for i = 1 : nR,
                if (Cluster0{j}(i,1)==0 && Cluster0{j}(i,2)==0)                  
                    fprintf(fp,'%d,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f\n',0,R{j}(i,1),R{j}(i,2),0,0,0,0);
                else
                    record = [L(Cluster0{j}(i,3),6),Cluster0{j}(i,1),Cluster0{j}(i,2),ch(L(Cluster0{j}(i,3),2),1),Cluster0{j}(i,4),Q(i),r2(i)];
                    fprintf(fp,'%d,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f,%8.4f,"%s"\n',record,nlist{L(Cluster0{j}(i,3),6)});
                end
            end
        else              % calibration unavailable, report areas 
            for i = 1 : nR,
                if (Cluster0{j}(i,1)==0 && Cluster0{j}(i,2)==0)                  
                    fprintf(fp,'%d,%8.4f,%8.4f,%8.4f,%8.4f\n',0,R{j}(i,1),R{j}(i,2),0,0);
                else
                    record = [L(Cluster0{j}(i,3),6),Cluster0{j}(i,1),Cluster0{j}(i,2),ch(L(Cluster0{j}(i,3),2),1),Cluster0{j}(i,4)];
                    fprintf(fp,'%d,%8.4f,%8.4f,%8.4f,%8.4f,%s,%s,"%s"\n',record,'','',nlist{L(Cluster0{j}(i,3),6)});
                end
            end
        end
    end
    fprintf(fp,'\n');
end
fclose(fp);

printf('quant-result saved to %s\n',file(strfind(file,filesep)(end)+1:end)); % modified on 2/25/2016


