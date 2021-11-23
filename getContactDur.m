function lick_struct = getContactDur(lick_struct, saveFlag)
% Modifies lick_struct by adding analog lick sensor onset/offset times
% Written by Brendan Ito

if ~exist('saveFlag', 'var')
    % Option to save modified lick_struct to file as well as returning.
    saveFlag = false;
end

for x = 1:numel(lick_struct)
   
    % let's first identify contact onsets, which are pretty robust and easy to
    % identify:
    analog_lick = lick_struct(x).analog_lick;
    analog_lick_filt = smoothdata(analog_lick, 'movmean', [0 10]);
    
    % first identify all threshold crossings
    analog_lick_filt_thresh = find(analog_lick_filt < 4.9);
    
    % make sure analog_lick_filt_thresh is not empty (e.g., no contacts)
    if ~isempty(analog_lick_filt_thresh)
        % the first crossing is first contact
        sp_contact_onset_temp = analog_lick_filt_thresh(1);

        % take the derivative to find the other onsets (identifies offset inds, so add 1)
        analog_lick_filt_thresh_diff = find(diff(analog_lick_filt_thresh) > 1) + 1;

        % concatenate to create onset list
        sp_contact_onset_temp = [sp_contact_onset_temp; analog_lick_filt_thresh(analog_lick_filt_thresh_diff)];

        % first, let's filter all contacts that happened less than 80 ms
        % from each other - these are artifacts due to lick sensor.  
        %contact_ind = find(~isnan([t_stats_temp.spout_contact]));
        j = 1;
        for i = 1:(numel(sp_contact_onset_temp) - 1)
            contact_temp = sp_contact_onset_temp(i+1) - sp_contact_onset_temp(i);
            if contact_temp < 80
                ind(j) = i + 1;
                j = j + 1;
            end
        end

        if exist('ind', 'var')
            sp_contact_onset_temp(ind) = [];
        end

        clear ind
        
%         % next, let's filter out all contacts that happened during the
%         % SSM/retraction phase - as these are artifacts as well.
%         j = 1;
%         for i = 1:(numel(sp_contact_onset_temp) - 1)
%             contact_temp = sp_contact_onset_temp(i+1) - sp_contact_onset_temp(i);
%             ssm_ret_dur = numel(t_stats_temp(contact_ind(i)).tip_x) - t_stats_temp(contact_ind(i)).SSM_start;
%             if contact_temp <= ssm_ret_dur
%                 ind(j) = i + 1;
%                 j = j + 1;
%             end
%         end

        if exist('ind', 'var')
            sp_contact_onset_temp(ind) = [];
        end

        clear ind

        % now we need to identify the offsets
        % first, let's get all potential offset times, but this skips the last
        sp_contact_offset_all = find(diff(analog_lick_filt_thresh) > 1);

        % added this to delete onsets with an offset that happened after
        % trial ended 
        if analog_lick_filt_thresh(end) == 1300
            sp_contact_offset_all = [analog_lick_filt_thresh(sp_contact_offset_all)];
            sp_contact_onset_temp(end) = [];       
        elseif analog_lick_filt_thresh(end) < 1300
            sp_contact_offset_all = [analog_lick_filt_thresh(sp_contact_offset_all); analog_lick_filt_thresh(end)];
        end

%         % added this to look for mismatches between contact ind and
%         % sp_contact_onset/offsets
%         if numel(sp_contact_onset_temp) < numel(contact_ind)
%             contact_ind(end) = [];
%         elseif numel(sp_contact_onset_temp) > numel(contact_ind)
%             if ~isempty(contact_ind)
%                 missing_ind = setdiff(contact_ind(1):contact_ind(end), contact_ind);
%                 contact_ind = sort([contact_ind, missing_ind]);
%             elseif isempty(contact_ind)
%                 [~, ind] = min(abs([t_stats_temp.time_rel_cue] - sp_contact_onset_temp));
%                 contact_ind = ind;
%             end
%         end

        % now we need to find the first of these, given contact times
        sp_contact_offset_temp = zeros(size(sp_contact_onset_temp));
        for i = 1:numel(sp_contact_onset_temp)
            if i < numel(sp_contact_onset_temp)
                sp_contact_offset_temp1 = sp_contact_offset_all(sp_contact_offset_all > sp_contact_onset_temp(i) & sp_contact_offset_all < sp_contact_onset_temp(i+1));
                sp_contact_offset_temp(i) = sp_contact_offset_temp1(1);
            elseif i == numel(sp_contact_onset_temp)
                sp_contact_offset_temp1 = sp_contact_offset_all(sp_contact_offset_all > sp_contact_onset_temp(i));

                % in some cases, the lick onset came before the cue went off,
                % but the offset came after.  in these cases, make both lick
                % onset and offset NaN
                if ~isempty(sp_contact_offset_temp1)
                    sp_contact_offset_temp(i) = sp_contact_offset_temp1(1);
                elseif isempty(sp_contact_offset_temp1)
                    sp_contact_onset_temp(i) = NaN;
                    sp_contact_offset_temp(i) = NaN;
                end
            end
        end

        lick_struct(x).sp_contact_onset = sp_contact_onset_temp';
        lick_struct(x).sp_contact_offset = sp_contact_offset_temp';
    
    % if there are no contacts, then everything is a NaN
    elseif isempty(analog_lick_filt_thresh)
        sp_contact_onset_empty = NaN;
        sp_contact_offset_empty = NaN;      
        lick_struct(x).sp_contact_onset = sp_contact_onset_empty;
        lick_struct(x).sp_contact_offset = sp_contact_offset_empty;
    end
    
end  

if saveFlag
    % Save modified lick_struct to file
    save('lick_struct', 'lick_struct'); 
end

end
