% This function takes in NSx data and aligns neural signals based on some
% event vector, E
%
% INPUTS:
%   NSx -- NSx structure formed when loading in NSP data using 'openNSx.m'
%   E_ts -- timestamp index of events you want to align to
%   dur_before -- duration, in ms, before the event you want to look at
%   dur_after -- duration, in ms, after the event you want to look at
%   baseline_window -- range, in ms, of signal to use as baseline for
%                      z-scoring the signal (e.g., [-300, -100])
%   electrodes -- specify which channels you want to anlayze, default is
%                 all of them
%   filter_flag -- boolean flag to filter the data or not
%
% OUTPUT:
%   elec -- structure containing raw signal for each electrode
%   elec_z -- structure containing z-scored signal for each electrode
%
% NOTE:
%   E_ts timestamps should use the same timing information used by
%   data in the NSx structure.


function [neuralsignal] = alignAnalogSignal_tap1(savetrials,Trial_array,electrodes,neuralsignal,Ped_name,tap_type)

global neuralsignal

if tap_type=="selftap"
    cond=1;
elseif tap_type=="autotap"
    cond=2;
    
end

req_tap=Trial_array(:,3)==cond;
Req_trials=Trial_array(:,4);

for ch_no=1:length(electrodes)
    
    ch_name=sprintf("Ch%d",ch_no);
    ch_name_SMA=sprintf("ch%d",ch_no);
    
    data_all_bl=neuralsignal.(Ped_name).(ch_name).all_signal_bl1;
    non_chew=savetrials.(ch_name_SMA);
    signal_alltrials_bl=[];
    signal_alltrials_tap1=[];
    signal_alltrials_tap1_zscore=[];
    for trial_no=1:size(data_all_bl,1) %trial number in the block
        not_chew=any(non_chew==trial_no); % checking if the trial is non chew
        if(not_chew==1)
            
            
            true_cond=any(Req_trials(req_tap)==(trial_no*2)-1); % Checking if trial satisfies the condition
            
            if(true_cond==1)
                signal_bl1=neuralsignal.(Ped_name).(ch_name).all_signal_bl1(trial_no,:);
                signal_tap1= neuralsignal.(Ped_name).(ch_name).all_signal_tap1(trial_no,:);
                signal_z = (signal_tap1 - mean(signal_bl1,2) )./ std(signal_bl1,0,2);
                
                signal_alltrials_bl=[signal_alltrials_bl;signal_bl1];
                signal_alltrials_tap1=[signal_alltrials_tap1;signal_tap1];
                signal_alltrials_tap1_zscore=[signal_alltrials_tap1_zscore;signal_z];
                
                
            end
        end
        neuralsignal.(tap_type).(Ped_name).(ch_name).signal_mean = mean(signal_alltrials_tap1);
        neuralsignal.(tap_type).(Ped_name).(ch_name).signal_std = std(signal_alltrials_tap1);
        neuralsignal.(tap_type).(Ped_name).(ch_name).signal_sem = std(signal_alltrials_tap1)/sqrt(size(signal_alltrials_tap1,2));
        neuralsignal.(tap_type).(Ped_name).(ch_name).signal_raw=signal_alltrials_tap1;
        neuralsignal.(tap_type).(Ped_name).(ch_name).signal_bl1=signal_alltrials_bl;
        
        neuralsignal.(tap_type).(Ped_name).(ch_name).signal_mean_zscore = mean(signal_alltrials_tap1_zscore);
        neuralsignal.(tap_type).(Ped_name).(ch_name).signal_std_zscore  =  std(signal_alltrials_tap1_zscore);
        neuralsignal.(tap_type).(Ped_name).(ch_name).signal_sem_zscore  = std(signal_alltrials_tap1_zscore)/sqrt(size(signal_alltrials_tap1_zscore,2));
        neuralsignal.(tap_type).(Ped_name).(ch_name).signal_raw_zscore =signal_alltrials_tap1_zscore;
        
        
        
    end
    
    
end

