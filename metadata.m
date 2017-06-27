%Data tranfer for Agilent 7890 and 6890 GC%
function mn = metadata(file)

mn = 7680;
    
%if (exist(file,'dir')==0)
 %   mkdir(file);
%end
%fp = fopen([file,filesep,'metadata.txt'],'w');

%Big-endian read-----------------------------------------------------%
    
fid=fopen(file,'r','b');
% fprintf(fp,'%s\n','--------File Header----------------------'); 
 
 FileType=readd(248,1,fid,'int32');
 % fprintf(fp,'FileType: %6d\n',FileType);
  
 SeqIndex=readd(252,1,fid,'int16');
% fprintf(fp,'Sequence Index: %4d\n',SeqIndex);
 
 AlsBottle=readd(254,1,fid,'int16');
% fprintf(fp,'ALS Bottle: %4d\n',AlsBottle);
 
 Replicate=readd(256,1,fid,'int16');
% fprintf(fp,'Replicate: %4d\n',Replicate);
 
 DataOffset=readd(264,1,fid,'int32');
% fprintf(fp,'Data Offset: %6d\n',DataOffset);
 
 NumRecords=readd(278,1,fid,'int32');
 %fprintf(fp,'Number of Records: %6d\n',NumRecords);
 
 StartTime=readd(282,1,fid,'float');
% fprintf(fp,'\nStart Time: %6.3f ms\n',StartTime);
 
 EndTime=readd(286,1,fid,'float');
 %fprintf(fp,'End Time: %10.5e ms\n',EndTime);
 
 MaxSig=readd(290,1,fid,'float');
% fprintf(fp,'MaxSig: %8.0f\n',MaxSig);
  
 MinSig=readd(294,1,fid,'float');
% fprintf(fp,'MinSig: %6.0f\n',MinSig);

 MaxY=readd(298,1,fid,'float');
% fprintf(fp,'MaxY: %8.0f\n',MaxY);
 
 MinY=readd(302,1,fid,'float');
 %fprintf(fp,'MinY: %6.0f\n',MinY);
 
 Mode=readd(314,1,fid,'int32');
% fprintf(fp,'Mode: %d\n',Mode);
 
 FileHeaderSize=readd(318,1,fid,'int32');
% fprintf(fp,'FileHeaderSize: %6d\n',FileHeaderSize);
 
 FileHeaderVersion=readd(322,1,fid,'int32');
% fprintf(fp,'FileHeaderVersion: %6d\n',FileHeaderVersion);
 
 if (FileType == 179)
     
 %glpFlag: glp conditions that occurred during the collection of this data%
 %For exapmple: %
 %0 - no glp warnings occurred  %
 %1 - run started while device was not ready    %
 %2 - setpoints modified during run   %
 %3 - device keyboard unlocked during run   %
 %4 - data points missing from file   %
 
 %6890 Data have some problems in these area%
 
     glpFlag=readd(3085,1,fid,'int32');
  %   fprintf(fp,'glpFlag: %6d\n',glpFlag);
 
% ScaleFactor=readd(3085,1,fid,'double');%
% printf('ScaleFactor: %8.2f\n',ScaleFactor)%
 
 
 %Data Source Int: an integer index to Data Source below %
    DataSourceInt=readd(3600,1,fid,'int8');
  %  fprintf(fp,'DataSourceInt: %6d\n',DataSourceInt);
 end 
 
 FileHeadLen=FileHeaderSize;   %File Header Size%
 
% fprintf(fp,'\n%s\n','--------Signal Header--------------------');
 
 SignalHeaderSize=readd(FileHeadLen,1,fid,'int32');
% fprintf(fp,'SignalHeaderSize: %6d\n',SignalHeaderSize);
 
 SignalHeaderVersion=readd(FileHeadLen+4,1,fid,'int32');
 %fprintf(fp,'SignalHeaderVersion: %6d\n',SignalHeaderVersion);

 if (FileType == 179)
     Detector=readd(FileHeadLen+10,1,fid,'int16');
    % fprintf(fp,'Detector: %4d\n',Detector);
 
     Method=readd(FileHeadLen+12,1,fid,'int16');
   %  fprintf(fp,'Method: %4d\n',Method);

     ZeroD=readd(FileHeadLen+14,1,fid,'float');
    % fprintf(fp,'ZeroD: %6.0f\n',ZeroD);
 
     MinD=readd(FileHeadLen+18,1,fid,'float');
   %  fprintf(fp,'MinD: %6.0f\n',MinD);

     MaxD=readd(FileHeadLen+22,1,fid,'float');
    % fprintf(fp,'MaxD: %8.0f\n',MaxD);
 end
 
 Version=readd(FileHeadLen+38,1,fid,'int32');
 %fprintf(fp,'Version: %4d\n',Version);
 
 %Intercept default 0.0%
 Intercept=readd(FileHeadLen+628,1,fid,'double');
% fprintf(fp,'Intercept: %6.2f\n',Intercept);
 
 %Slope default 1.0%
 Slope=readd(FileHeadLen+636,1,fid,'double');
% fprintf(fp,'Slope: %6.2f\n',Slope);

 
 SigHeadLen=SignalHeaderSize;     %Signal Header Size%
 HeadLen=FileHeadLen+SigHeadLen;
 
%Little-endian read%
    
fid=fopen(file,'r','l');
 
 %File Number1: 179 for Agilent 7890A, 181 for 6890 GC%
 FileNumLen=readd(0,1,fid,'char');
 FileNum1=reads(1,FileNumLen,fid);        
 %fprintf(fp,'FileNum1: %s\n',FileNum1);

 %File Number2: 179 for Agilent 7890A, 181 for 6890 GC%
 FileNumUStrLen=readd(326,1,fid,'char');
 FileNum2=reads(327,FileNumUStrLen*2,fid);
% fprintf(fp,'FileNum2: %s\n',FileNum2);

 %File: GC Data File or LC Data File%
 FileUStrLen=readd(347,1,fid,'char');
 FileU=reads(348,FileUStrLen*2,fid);
 %fprintf(fp,'FileU: %s\n',FileU);

 SampleNameUStrLen=readd(858,1,fid,'char');
 SampleName=reads(859,SampleNameUStrLen*2,fid);
% fprintf(fp,'Sample Name: %s\n',SampleName);
 
 BarcodeUStrLen=readd(1369,1,fid,'char');
 Barcode=reads(1370,BarcodeUStrLen*2,fid);
 %fprintf(fp,'Barcode: %s\n',Barcode);
 
 OperatorUStrLen=readd(1880,1,fid,'char');
 Operator=reads(1881,OperatorUStrLen*2,fid);
 %fprintf(fp,'Operator: %s\n',Operator);
 
 DateTimeUStrLen=readd(2391,1,fid,'char');
 DateTime=reads(2392,DateTimeUStrLen*2,fid);
 %fprintf(fp,'Date&Time: %s\n',DateTime);

 InstModelUStrLen=readd(2492,1,fid,'char');
 InstModel=reads(2493,InstModelUStrLen*2,fid);
 %fprintf(fp,'Instrument Model: %s\n',InstModel);
 
 InletUStrLen=readd(2533,1,fid,'char');
 Inlet=reads(2534,InletUStrLen*2,fid);
 %fprintf(fp,'Inlet Position: %s\n',Inlet);
 
 MethodFileUStrLen=readd(2574,1,fid,'char');
 MethodFile=reads(2575,MethodFileUStrLen*2,fid);
% fprintf(fp,'Method File: %s\n',MethodFile);
  
 if (FileType == 179)
     DataSourceUStrLen=readd(3089,1,fid,'char');
     DataSource=reads(3090,DataSourceUStrLen*2,fid);
     %fprintf(fp,'Data Source: %s\n',DataSource);
     if (strcmpi(DataSource,'MSD ChemStation')==1)
         mn = 1;
     end
 
     FirmwareRevUStrLen=readd(3601,1,fid,'char');
     FirmwareRev=reads(3602,FirmwareRevUStrLen*2,fid);
    % fprintf(fp,'Firmware Revision: %s\n',FirmwareRev);
 
     SoftwareRevUStrLen=readd(3802,1,fid,'char');
     SoftwareRev=reads(3803,SoftwareRevUStrLen*2,fid);
   %  fprintf(fp,'Software Revision: %s\n',SoftwareRev);
 end
 
 %Sample Rate, 4-byte integer, the first 2 byte indicates the demoninator and the last 2 indicates the nominator%
 BP=readd(FileHeadLen+26,4,fid,'uchar');
 SampleRate=(BP(3)*256+BP(4))/(BP(1)*256+BP(2));
% fprintf(fp,'\nSampleRate: %6.2f Hz\n',SampleRate);

 %PeakWidth unused%
 %PeakWidth=readd(FileHeadLen+30,1,fid,'char');
 
 UnitsUStrLen=readd(FileHeadLen+76,1,fid,'char');
 Units=reads(FileHeadLen+77,UnitsUStrLen*2,fid);
 %fprintf(fp,'Units: %s\n',Units);
 
 SigDescUStrLen=readd(FileHeadLen+117,1,fid,'char');
 SigDesc=reads(FileHeadLen+118,SigDescUStrLen*2,fid);
 %fprintf(fp,'Signal Description: %s\n',SigDesc);
   
fclose(fid);
%fclose(fp);
mn

function s=reads(offset,length,fid)
     fseek(fid,offset,'bof');
     d=fread(fid,length,'char');
     s=num2str(char(d(find(d))'));
     
function d=readd(offset,length,fid,p)
     fseek(fid,offset,'bof');
     d=fread(fid,length,p);
     