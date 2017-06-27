function [ fixedsignals, sig_trace ] = fixsigdiscrep( alignfiles, reference_starttime, reference_endtime, reference_axis, reference_raw, traces )
%fixsigdiscrep: Fix discrepancies between the reference signal and the
%other ("warp" and "apply") signals. 
% The other signals are changed so that their start and end retention times
% (RT) are the same as those of the reference signal. Also, the "warp" and
% "apply" signals are interpolated so that they have the same number of
% data points (scans) as the reference signal. The reference signal is
% not modified by this function.
%
% After loading the "warp" or "apply" signals, the RTs are checked. If the
% start and end times don't match those of the reference signal, data
% points are removed or added (by adding zeros) to the corresponding end of
% the "warp" or "apply" signal.
% If RT lengths are the same but the number of scans is different, the
% "warp" or "apply" signal is interpolated so that all chromatograms have
% the same number of data points as the reference signal. This is the case,
% for example, when different scan rates were used for different
% measurements.
%
% Input:
%   alignfiles: "warp" or "apply" files to modify
%   reference_starttime: start RT of the reference
%   reference_endtime: end RT of the reference
%   reference_axis: RT axis of the reference signal
%   reference_raw: raw reference signal
%   traces: list of user-specified mass traces 
%
% Output:
%   fixedsignals: matrix of all "warp" and "apply" signals that have been
%       adjusted to be the same length and cover the same range of
%       retention times as the reference signal
%   sig_trace: the user-specified traces of the "warp" and "apply" signals,
%       adjusted to match those of the reference chromatogram
%
% Christina de Bruyn Kops, 2015


sig_raw = cell(1,size(alignfiles,1));
sig_trace = cell(1,size(alignfiles,1));
for i = 1:size(alignfiles,2)
    load(alignfiles{1,i})
    sig_raw{i} = TIC; 
    sig_axis = axis_min;
    timestep = axis_min(2)-axis_min(1);
    
    % get specific traces for warping function, if specified
    if any(traces) == 1
        sig_trace{i} = zeros(size(A,1),size(traces,2));
        for j = 1:size(traces,2)
            if isempty(find(axis_mz==traces(j))) == 0
                sig_trace{i}(:,j) = A(:,find(axis_mz==traces(j)));
            else
                sig_trace{i}(:,j) = [];
                disp(['Error - trace ', num2str(i),' is not available in the warp signal'])
            end
        end
    else
        sig_trace{i} = zeros(size(TIC,1),1);
    end

    % Find closest point in signal to reference_starttime, find closest
    % point to reference_endtime
    [cs inds] = min(abs(axis_min - reference_starttime));
    [ce inde] = min(abs(axis_min - reference_endtime));
    len = length(sig_raw{i});

    % If the closest point to reference_starttime isn't the first point
    % and/or the closest point to reference_endtime isn't the last
    % point, crop the signal.
    if inds ~= 1
        sig_raw{i} = sig_raw{i}(inds:end);
        sig_trace{i} = sig_trace{i}(inds:end);
        sig_axis = sig_axis(inds:end);
    end
    if inde ~= len
        sig_raw{i} = sig_raw{i}(1:inde);
        sig_trace{i} = sig_trace{i}(1:inde);
        sig_axis = sig_axis(1:inde);
    end

    % check if need to add zeros on either end
    if reference_starttime < axis_min(1)-timestep
        toadd = round((axis_min(1)-reference_starttime)/timestep);
        sig_raw{i} = vertcat(zeros(toadd,1),sig_raw{i});
        sig_trace{i} = vertcat(zeros(toadd,size(sig_trace{i},2)),sig_trace{i});
        sig_axis = vertcat( axis_min(1) - ...
                            timestep*linspace(1,toadd,toadd),sig_axis);
    end
    if reference_endtime > axis_min(end)+timestep
        toadd = round((reference_endtime - axis_min(end))/timestep);
        sig_raw{i} = vertcat(sig_raw{i},zeros(toadd,1));
        sig_trace{i} = vertcat(sig_trace{i},zeros(toadd,size(sig_trace{i},2)));
        sig_axis = vertcat(sig_axis,axis_min(end) + ...
                           timestep*linspace(1,toadd,toadd)');
    end

    % interpolate to fix the scan rate
    if length(sig_raw{i}) ~= length(reference_raw)
        sig_raw{i} = interp1(sig_axis,sig_raw{i},reference_axis,...
                             'linear','extrap');
        sig_trace{i} = interp1(sig_axis,sig_trace{i},reference_axis,...
                             'linear','extrap');
    end 
   
end

% now that all signals are the same length, convert to matrix
fixedsignals = cell2mat(sig_raw);

end