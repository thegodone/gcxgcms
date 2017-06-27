% Complete workflow for STW alignment
%
% User-Defined Input:
%
%   - reference chromatogram
%       This chromatogram will be used as the reference in the calculation 
%       of any and all warping functions. The user is advised that all
%       other chromatograms will be automatically modified so that they
%       have the same number of "scans" and length in retention time as the
%       reference chromatogram. 
%   - "warp" chromatogram(s)
%       This/these chromatogram(s) will be used to calculate the warping
%       function. This warping function will then be applied to the "warp"
%       chromatogram from which it was calculated, as well as any "apply"
%       chromatograms.
%   - "apply" chromatograms
%       In the case that the user wishes to use a calibration chromatogram
%       to compute the warping function and then align multiple other
%       chromatograms using the same warping function, he or she should
%       specify exactly one "warp" chromatogram and at least one "apply"
%       chromatogram. The warping function calculated from the "warp"
%       chromatogram is then applied to the "warp" chromatogram and all
%       "apply" chromatograms.
%   - alignment window
%       If one or more of the chromatograms is shorter than the others in
%       such a way that multiple peaks are missing from one end, the user
%       is advised to enter an alignment window, in terms of retention
%       time, for which the alignment will be calculated. The chromatograms
%       output by this alignment will not be longer than the alignment
%       window. If the user enters a value greater than the maximum
%       retention time, the maximum retention time is used as the end of
%       the alignment window.
%   - traces
%       This vector contains a list of all mass traces to be used
%       iteratively, in the order they are written in the traces vector, to
%       calculate the warping function. The default is an empty vector, in
%       which case only the TIC is used to calculate the warping function.
%       Specifying specific mass traces can be useful in cases in which the
%       TIC-based alignment is not satisfactory and MS data is available.
%       This method is not recommended except in cases for which the TIC
%       alignment is not sufficient.
%   - condensing factor
%       This variable holds the factor by which the number of scans of the
%       reference signal is to be reduced via a condensing of the data
%       points. (All other signals are interpolated to match the number of
%       scans in the reference signal.) The default value is 0, which
%       corresponds to no scan rate reduction. As an example, a condense
%       value of 2 would reduce the number of scans by half.
%       Use of a condensing factor is recommended for very large
%       chromatograms with a high scan rate, especially if pairwise
%       alignment of more than two chromatograms is desired, as the running
%       time of the alignment increases significantly as a function of
%       signal length and number of signals to align. For chromatograms
%       containing more than 15000 scans, it may be desirable to reduce the
%       number of scans to around 10000 for a faster alignment. 
%
% Output:
%
%   - aligned chromatograms
%       A .mat file for each of the chromatograms changed in the alignment
%       (all chromatograms except for the reference). This new file,
%       located in the same directory as the original .mat file used for
%       the alignment, is recognizable by the "-w" at the end of the file
%       name. 
%
%
% Christina de Bruyn Kops, 2015


close all; clear all; clc;
warnid = 'MATLAB:rankDeficientMatrix';
warning('off',warnid)


% user interface to select files using uipickfiles

referencefile = uipickfiles('filterspec','*.mat','prompt',...
      'Select reference chromatogram','numfiles',1,'output','cell');
celldisp(referencefile,'reference file ')

% 1 or more signal(s) from which to calculate the warping function:
warpfiles = uipickfiles('filterspec','*.mat','prompt',...
     'Select chromatogram(s) for warping/calculating the warping function',...
     'output','cell');
celldisp(warpfiles,'"warp" file(s) ')
 
% 0 or more signals on which to apply the warping function
applyfiles = uipickfiles('filterspec','*.mat','prompt',...
    'Select 0 or more chromatograms to apply the warping function to',...
    'output','cell');
if size(applyfiles,2) ~= 0
    celldisp(applyfiles,'"apply" files ')
end


% ------------------------------------------------------------------------%
                        % USER-DEFINED VALUES %
% ------------------------------------------------------------------------%

% Chromatogram .mat files must contain the TIC in a column vector called
% 'TIC' and the RT-axis in minutes in a column vector called 'axis_min'. In
% order to use mass traces, the .mat file must contain the m/z axis in a
% column vector called 'axis_mz'.
% Chromatograms are chosen via user interface.

% Alignment window in RT, if any ([0 0] to align whole signal, endpoint of
% 0 to refer to end of signal):
awindow = [0 0];  % default is [0 0]

% Mass traces to consider, if any. If left empty, the TIC will be
% used. Enter m/z values as a row vector:
traces = [];   % default is empty matrix []

% For signals that are too long (too many scans) for a fast alignment,
% the signals can be condensed by the following factor. Set to 0 for no
% change to the number of data points. 
condense = 0;  % default is 0

% For signals in which the corresponding peaks are too far apart for a
% decent alignment, a linear shift based on the maximum peak in each signal
% can be used for pre-alignment before applying the STW algorithm. To use a
% linear shift, enter the window in RT for which the maximum peak in the
% window is the same corresponding peak in all chromatograms.
linear_shift_max_peak_window = [0 0]; % default is [0 0]


% ------------------------------------------------------------------------%
% Check for input errors: exactly 1 reference file is required, and
% either a) one or more "warp" files with 0 "apply" files or b) exactly 1
% "warp" file with one or more "apply" files.

if size(referencefile,1) == 0
    disp('Error - one reference signal and at least one warping signal are necessary')
end
if size(warpfiles,1) == 0 
    disp('Error - one reference signal and at least one warping signal are necessary')
end  
    
if any(cellfun(@any,applyfiles)) == 1 && size(warpfiles,2) > 1
    disp('Error - only one signal is needed to calcualte the warping function')
end

% The variable 'axis_mz' is required for the use of mass traces for the
% alignment.
if any(traces) == 1
   refvars =  whos('-file',referencefile{1});
   if ismember('axis_mz', {refvars.name}) == 0
        disp('Error - You requested a mass trace from a reference file without an "axis_mz" variable')
        
   end
   tobreak = 0;
   for i = 1:size(warpfiles,2)
        warpvars = whos('-file', warpfiles{i});
        if ismember('axis_mz', {warpvars.name}) == 0
            disp('Error - You requested a mass trace from a file without an "axis_mz" variable')
            tobreak = 1;
            break
       end
   end
   if tobreak == 1
       
   end
   if size(traces,1) > size(traces,2)
       traces = transpose(traces);
   end
end



% ------------------------------------------------------------------------%
% load data

% get reference signal
load(referencefile{1,1})
reference_raw = TIC;
reference_raw_orig = TIC;

% get specific traces for warping function, if specified
if any(traces) == 1
    
    ref_trace = zeros(size(A,1),size(traces,2));
    for i = 1:length(traces)
       if isempty(find(axis_mz==traces(i))) == 0
            ref_trace(:,i) = A(:,find(axis_mz==traces(i)));
       else
           ref_trace(:,i) = [];
           disp('Error - one of the chosen traces is not available in the reference signal')
       end
    end

end

% get reference time axis info
reference_axis = axis_min;
reference_starttime = axis_min(1);
reference_endtime = axis_min(end); 
reference_totaltime = round((reference_endtime - reference_starttime)...
                            *100000);

% condense signals if too long                                                
if condense ~= 0
    reference_raw = reference_raw(1:condense:end,:);
    reference_axis = reference_axis(1:condense:end,:);

    if any(traces) == 1  
        ref_trace = ref_trace(1:condense:end,:);
    end
end


% load data from warpfiles and applyfiles
% fix any discrepencies in signal length
[warp_raw, warp_trace] = fixsigdiscrep( warpfiles, ...
                                        reference_starttime, ...
                                        reference_endtime, ...
                                        reference_axis, ...
                                        reference_raw, traces );
[apply_raw, apply_trace] = fixsigdiscrep( applyfiles, ...
                                          reference_starttime, ...
                                          reference_endtime, ...
                                          reference_axis, ...
                                          reference_raw, traces );

% check for errors loading mass traces
if any(traces) == 1
    if size(ref_trace,2) ~= size(traces,2)
        disp('Error - one of the traces is not available for the reference')
        
    end
    badfile = 0;
    for i = 1:size(warp_raw,2)
        if size(ref_trace,2) ~= size(warp_trace{1},2)
            disp(['Error - one or more of the traces is not available for warp signal ',num2str(i)])
            badfile = 1;
        end
    end
    if badfile == 1
        
    end
end


% ------------------------------------------------------------------------%
% remove baseline - baseline estimation with asymmetric least squares

reference_bline = piecewiseasysm(reference_raw);
reference = reference_raw - reference_bline;   % baseline subtracted

warp_baseline = piecewiseasysm(warp_raw);
warp = warp_raw - warp_baseline;   % baseline subtracted

% remove baseline from individual traces, if specified
if any(traces) == 1
    ref_trace_bline = piecewiseasysm(ref_trace);
    ref_trace = ref_trace - ref_trace_bline;
    for i = 1:size(warpfiles,2)
       w_bline = piecewiseasysm(warp_trace{i});
       warp_trace{i} = warp_trace{i} - w_bline;
    end
end

% check if apply_raw is a zero vector (no signals were loaded)
if any(apply_raw) == 1
    apply_bline = asysm(apply_raw, 1e7, 0.001, 2); 
    apply = apply_raw - apply_bline; 
else
    apply = apply_raw; 
end


% ------------------------ Alignment window ------------------------------%

% save original signals and their scan-axis
reference_orig = reference;
reference_axis_orig = reference_axis;
warp_orig = warp;
apply_orig = apply;
m_raw = size(reference_raw, 1);
t_raw = (1:m_raw)' - 0.5;

reference_before = [];
reference_after = [];
warp_before = [];
warp_after = [];
apply_before = [];
apply_after = [];
axis_before = [];
axis_after = [];
ref_trace_before = [];
ref_trace_after = [];

% zero means no start/end of the window was specified
if awindow(1) ~= 0 || awindow(2) ~= 0
    % crop the signals to the alignment window
    if awindow(1) ~= 0
        [c ind] = min(abs(reference_axis - awindow(1)));
        reference_before = reference(1:ind-1);
        reference = reference(ind:end);
        warp_before = warp(1:ind-1,:);
        warp = warp(ind:end,:);
        reference_axis = reference_axis(ind:end);
        axis_before = reference_axis_orig(1:ind-1);
        if any(apply_raw) == 1
            apply_before = apply(1:ind-1,:);
            apply = apply(ind:end,:);
        end
        if any(traces) == 1
           ref_trace_before = ref_trace(1:ind-1);
           ref_trace = ref_trace(ind:end,:);
           warp_trace = cellfun(@(x) x(ind:end,:), warp_trace,...
                                'UniformOutput', false);
        end
    end
    if awindow(2) ~= 0
        [c ind] = min(abs(reference_axis - awindow(2)));
        reference_after = reference(ind+1:end);
        reference = reference(1:ind);
        warp_after = warp(ind+1:end,:);
        warp = warp(1:ind,:);
        reference_axis = reference_axis(1:ind);
        axis_after = reference_axis_orig(ind+length(axis_before)+1:end);
        if any(apply_raw) == 1
            apply_after = apply(ind+1:end,:);
            apply = apply(1:ind,:);
        end
        if any(traces) == 1
            ref_trace_after = ref_trace(ind+1:end);
            ref_trace = ref_trace(1:ind,:);
            warp_trace = cellfun(@(x) x(1:ind,:), warp_trace, ...
                                 'UniformOutput', false);
        end
    end
end

% ------------------------- Normalize signals ----------------------------%

%divide each signal by its average value
reference_n = nrm(reference);
warp_n = nrm(warp);

if any(traces) == 1
    ref_trace = nrm(ref_trace);
    warp_trace = nrm(warp_trace);
    size(warp_trace{1})
end

% ------------------------- Align largest peaks --------------------------%

if linear_shift_max_peak_window(2) ~= 0 
    
    [c indstart] = min(abs(reference_axis - linear_shift_max_peak_window(1)));
    [c indend] = min(abs(reference_axis - linear_shift_max_peak_window(2)));
    ref_max_win = reference_n(indstart:indend);
    warp_max_win = warp_n(indstart:indend);
    
    [largest_ref_peak, ind_largest_ref_peak] = max(ref_max_win,[],1);
    [largest_warp_peaks, ind_largest_warp_peaks] = max(warp_max_win,[],1);

    for ind = 1:size(warp,2)
        diff = ind_largest_ref_peak - ind_largest_warp_peaks(1,ind);

        if diff ~= 0
            if diff > 0
                warp_n(:,ind) = vertcat(zeros(diff,1),warp_n(1:end-diff,ind));
                warp(:,ind) = vertcat(zeros(diff,1),warp(1:end-diff,ind));
            else
                warp_n(:,ind) = vertcat(warp_n(-diff+1:end,ind),zeros(-diff,1));
                warp(:,ind) = vertcat(warp(-diff+1:end,ind),zeros(-diff,1));
            end
        end

    end

end


% ---------------------- Smoothing and Alignment -------------------------%

% Perform alignment with five different smoothing coefficients. Assume
% reference requires a similar amount of smoothing as the "warp" signals.
smoothexp = 3:7;
rvec = zeros(size(warp,2),size(smoothexp,2));
allsignalss = cell(1,size(smoothexp,2));
cutsignals = cell(1,size(smoothexp,2));
isels = cell(1,size(smoothexp,2));
for i = 1:size(smoothexp,2)
    
    % ------------------ Heavy smoothing to broaden peaks ----------------%

    lambda = 10^smoothexp(i); % smoothing coefficient

    % smooth the signals
    if any(traces) == 1
        ref_trace_s = difsm(ref_trace,lambda, 2);
        warp_trace_s = cell(size(warp_trace));   
        for j = 1:size(warp_trace,2)
            warp_trace_s{1,j} = difsm(warp_trace{1,j}, lambda, 2);
        end
    end
    warp_s = difsm(warp_n, lambda, 2);  
    reference_s = difsm(reference_n, lambda, 2);
    

    % -------------------- Built-in parameters for STW -------------------%

    ndx = 12; % number of knots in B-splines
    numit = 100; % number of iterations for STW  

    % --------------------------- Alignment ------------------------------%
    
    m = size(reference, 1);
    t = (1:m)' - 0.5;
    
    if any(traces) == 1
       [ warpedsignals, isel, ...
         alignedtraces, iselt ] = traceSTW( ref_trace_s, warp_trace_s, ...
                                            warp_trace,warp, apply, ...
                                            ndx, numit, t );
       
       if awindow(1) ~= 0 || awindow(2) ~= 0
            cutsignals{i} = horzcat(reference,warpedsignals);

            for j = 1:size(warpedsignals,2) 
                if size(warp_before,1) ~= 0
                    warpedsignals{1,j} = vertcat(warp_before(:,j),...
                                                 warpedsignals{j});
                end
                if size(warp_after,1) ~= 0
                    warpedsignals{1,j} = vertcat(warpedsignals{j},...
                                                 warp_after(:,j));
                end
            end
        end
        % unsmoothed, full signals:
        allsignalss{i} = horzcat(reference_orig,warpedsignals); %cell array
        refwarpsignals = allsignalss{i}(:,1:size(warp,2)+1); 
        
    else

        if any(apply) == 0
            % pairwise alignment between reference and all "warp" signals
            [warpedsignals, isel] = pairwiseSTW(reference_s,warp_s,...
                                                warp, ndx, numit,t); 

            if awindow(1) ~= 0 || awindow(2) ~= 0
                cutsignals{i} = horzcat(reference,warpedsignals);

                for j = 1:size(warpedsignals,2) 
                    if size(warp_before,1) ~= 0
                        warpedsignals{1,j} = vertcat(warp_before(:,j),...
                                                     warpedsignals{j});
                    end
                    if size(warp_after,1) ~= 0
                        warpedsignals{1,j} = vertcat(warpedsignals{j},...
                                                     warp_after(:,j));
                    end
                end
            end
            % unsmoothed, full signals:
            allsignalss{i} = horzcat(reference_orig,warpedsignals); %cell array
            refwarpsignals = allsignalss{i};

        elseif size(warp,2) == 1
            % calculate warping function based on "warp" signals, then
            % apply to the "apply" signals
            [warp_w, apply_w, isel] = applySTW(reference_s, warp_s, ...
                warp, apply, ndx, numit,t);

            warpedsignals = horzcat(warp_w,apply_w);
            before = horzcat(warp_before, apply_before);
            after = horzcat(warp_after, apply_after);

            if awindow(1) ~= 0 || awindow(2) ~= 0
                cutsignals{i} = horzcat(reference,warpedsignals);

                for j = 1:size(warpedsignals,2) 
                    if size(warp_before,1) ~= 0
                        warpedsignals{1,j} = vertcat(before(:,j),...
                                                     warpedsignals{j});
                    end
                    if size(warp_after,1) ~= 0
                        warpedsignals{1,j} = vertcat(warpedsignals{j},...
                                                     after(:,j));
                    end
                end
            end
            allsignalss{i} = horzcat(reference_orig, warpedsignals);
            refwarpsignals = allsignalss{i}(:,1:1+size(warp_w,2));
        end
    end

    isels{i} = isel;

    ref = cell(1,size(isel,2));
    for j = 1:size(isel,2)
        ref{1,j} = vertcat(reference_before, reference(isel{j}),...
                           reference_after);    
    end
    
    % Calculate correlation coefficient for each alignment with each
    % smoothing coefficient
    allbutref = horzcat(warp_orig,apply_orig);
    rvec(:,i) = calculateCorrelationCoefficients(refwarpsignals,ref,...
                                                 reference_orig,...
                                                 allbutref,apply_orig,0);

end

% ------------------------ Save best alignment ---------------------------%

% Find which alignment resulted in the best correlation coefficient.
% For each row in rvec (correlation coefficients for each signal and each
% smoothing coefficient), find best alignment (max value in that row of
% rvec). Save the corresponding warped signal and time axis selection for
% that particular chromatogram.
% If an alignment window was chosen, the correlation coefficients are
% calculated only for the alignment within that window.

allsignals = cell(1,size(allsignalss{1},2)); 
allsignals{1,1} = reference_orig;
cutsigs = cell(1,size(cutsignals{1},2)); 
cutsigs{1,1} = reference;
isel = cell(1,size(isels{1},2)); 
for i = 1:size(rvec,1)
    [maxval,bestidx] = max(rvec(i,:)); 
    allsignals{1,i+1} = allsignalss{1,bestidx}{1,i+1};
    isel{1,i} = isels{1,bestidx}{1,i};
        
    if size(cutsignals{1}) ~= 0
        cutsigs{1,i+1} = cutsignals{1,bestidx}{1,i+1};
    end
    
    warp_s(:,i) = difsm(warp_n(:,i), 10^smoothexp(bestidx), 2);
end

% for "apply" signals, use bestidx from warp signal
if size(rvec,1) == 1 & any(apply) == 1
   for i = 2:(size(allsignalss{1},2)-1)
       allsignals{1,i+1} = allsignalss{1,bestidx}{1,i+1};
       isel{1,i} = isels{1,bestidx}{1,i};
       
       if size(cutsignals{1}) ~= 0
        cutsigs{1,i+1} = cutsignals{1,bestidx}{1,i+1};
       end
   end
end

% ---------------------------- Plotting ----------------------------------%

colors = jet(size(reference,2) + size(warp,2) + size(apply,2));
fs = 9;


% Plot unaligned signals
figure
subplot(2, 1, 1)
hold on
set(gca, 'FontSize', fs,'ColorOrder', colors(1:end,:))
plot(reference_axis_orig,horzcat(reference_orig,warp_orig,apply_orig))
legendText = cell(1,(size(warp_orig,2)+size(apply_orig,2))+1);
legendText{1} = 'reference';
for i = 1:(size(warp_orig,2)+size(apply_orig,2))
    % legend
    if any(apply) == 1
        if i == 1
            legendText{i+1} = strcat('warp ',num2str(i));
        else
            legendText{i+1} = strcat('apply ',num2str(i-1));
        end
    else
        legendText{i+1} = strcat('warp ',num2str(i));
    end

end
legend(legendText{:},'Location','EastOutside');
hold off
title('Unaligned, unsmoothed, unnormalized data')
xlabel('Retention Time (min)')
ylabel('Signal')
subplot(2,1,2)
hold on
set(gca, 'FontSize', fs,'ColorOrder', colors(2:end,:))
plot(reference_axis_orig, bsxfun(@minus,...
                                 reference_orig/mean(reference_orig),...
                                 bsxfun(@rdivide,horzcat(warp_orig,...
                                                         apply_orig),...
                                                 mean(horzcat(warp_orig,...
                                                         apply_orig),1))));
legend(legendText{2:end},'Location','EastOutside');
hold off
title('Differences between normalized, unaligned signals')
xlabel('Retention Time (min)')
ylabel('Normalized Signal')


% Plot smoothed (and normalized) unaligned signals 
% in alignment window only
figure
subplot(2, 1, 1)
hold on
set(gca, 'FontSize', fs,'ColorOrder', colors(1:end,:))
reference_s = difsm(reference_n,10^smoothexp(bestidx), 2);
plot(reference_axis,horzcat(reference_s,warp_s))
legend(legendText{1:1+size(warp_s,2)},'Location','EastOutside');
hold off
title('Smoothed and normalized data, unaligned')
xlabel('Retention Time (min)')
ylabel('Signal')
subplot(2,1,  2)
hold on
set(gca, 'FontSize', fs,'ColorOrder', colors(2:end,:))
plot(reference_axis, bsxfun(@minus,reference_s,warp_s))
legend(legendText{2:1+size(warp_s,2)},'Location','EastOutside');
hold off
title('Differences between unaligned, smoothed signals')
xlabel('Retention Time (min)')
ylabel('Normalized Signal')


% Plot warped signals

axis_warp = cell(size(allsignals));
ref = cell(1,size(allsignals,2)-1);
sig_wn = cell(1,size(allsignals,2)-1);
cutsig_wn = cell(1,size(allsignals,2)-1);
selref = cell(1,size(allsignals,2)-1);
refn = cell(1,size(allsignals,2)-1);
axis_warp{1} = reference_axis_orig;
for i = 2:size(allsignals,2)
    axis_warp{i} = reference_axis(isel{i-1});
    if size(axis_before,1) ~= 0
        axis_warp{i} = vertcat(axis_before,axis_warp{i});
    end
    if size(axis_after,1) ~= 0
        axis_warp{i} = vertcat(axis_warp{i},axis_after);
    end
    
    sig_wn{i-1} = allsignals{i}/mean(allsignals{i});
    ref{i-1} = vertcat(reference_before/mean(reference_before), ...
                       reference_n(isel{i-1}), ...
                       reference_after/mean(reference_after));    
    selref{i-1} = reference_axis(isel{i-1});
    
    if size(cutsignals{1}) ~= 0
        cutsig_wn{i-1} = cutsigs{i}/mean(cutsigs{i});
        refn{i-1} = reference_n(isel{i-1});
    end

end


figure
subplot(2, 1, 1)
hold all
set(gca, 'FontSize', fs,'ColorOrder', colors,'XLim',...
    reference_axis_orig(end) * [0 1])
cellfun(@plot,axis_warp,horzcat(reference_orig,allsignals(:,2:end)))
legend(legendText{:},'Location','EastOutside');
hold off
title('Aligned signals')
xlabel('Retention Time (min)')
ylabel('Signal')
subplot(2, 1, 2)
hold all
set(gca, 'FontSize', fs,'ColorOrder', colors(2:end,:),'XLim',...
    reference_axis_orig(end) * [0 1])
cellfun(@plot,axis_warp(2:end),cellfun(@minus,ref,sig_wn,...
        'UniformOutput',0))
legend(legendText{2:end},'Location','EastOutside');
hold off 
title('Differences between aligned, normalized data traces')
xlabel('Retention Time (min)')
ylabel('Normalized Signal')


% ---------------------- Save aligned chromatograms ----------------------%

for j = 1:size(warpfiles,2)
    outputfile = warpfiles{j}(1:end-4);
    axis_min = axis_warp{j+1};
    TIC = allsignals{j+1};
    save([outputfile '-w.mat'], 'axis_min', 'TIC')
end


% ----------------- Print correlation coefficients -----------------------%

fprintf('\n\n\n::Alignment Information::\n')
ref = cell(size(isel,2));
for i = 1:size(isel,2)
    ref{i} = vertcat(reference_before, reference(isel{i}), ...
                     reference_after);    
end
allbutref = horzcat(warp_orig,apply_orig);

% calculate and print correlation coefficients for unaligned and aligned
% signals
corr = calculateCorrelationCoefficients(allsignals,ref,reference_orig,...
                                        allbutref,apply_orig,1);


% -------- Alignment window plots and correlation coefficients -----------%

if awindow(1) ~= 0 || awindow(2) ~= 0
    
    % Plot warped, cropped signals
    figure
    subplot(2, 1, 1)
    hold all
    set(gca, 'FontSize', fs,'ColorOrder', colors,'XLim',...
        reference_axis_orig(end) * [0 1])
    cellfun(@plot,horzcat(reference_axis,selref),cutsigs)
    legend(legendText{:},'Location','EastOutside');
    hold off
    title('Aligned signals, cropped to alignment window')
    xlabel('Retention Time (min)')
    ylabel('Signal')
    subplot(2, 1, 2)
    hold all
    set(gca, 'FontSize', fs,'ColorOrder', colors(2:end,:),'XLim',...
        reference_axis_orig(end) * [0 1])
    cellfun(@plot,selref,cellfun(@minus,refn,cutsig_wn,...
            'UniformOutput',0))
    legend(legendText{2:end},'Location','EastOutside');
    title('Differences between normalized, aligned signals cropped to alignment window')
    xlabel('Retention Time (min)')
    ylabel('Normalized Signal')
    
    % correlation coefficients for aligned portion only
    fprintf('\n::Alignment Information for Selected Portion Only::\n')
    ref = cell(size(isel,2));
    for i = 1:size(isel,2)
        ref{i} = reference(isel{i});
    end
    allbutref = horzcat(warp,apply);
    corr = calculateCorrelationCoefficients(cutsigs,ref,reference,...
                                            allbutref,apply,1);
end