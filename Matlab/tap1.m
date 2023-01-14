% Function used to calculate the firing rate of the first tap
% ('self-generated/ sutomatically generated )
% Author: Teresa George

function [SMA,FR_vals]= tap1(tap_type,Trial_array,Ped,ped_count,SMA)
global FR_vals;
if tap_type=="selftap"
    cond=1;
elseif tap_type=="autotap"
    cond=2;
    
end

self_tap=Trial_array(:,3)==cond;
Req_trials=Trial_array(:,4);
for P=1:ped_count
    
    Ped_name=sprintf("Ped%s",Ped(P));
    FR_trial_BL1=[];
    FR_trial_RW=[];
    BL_FR_mean=[];
    BL_FR=[];
    Diff_BL2_final=[];
    Diff_tap1_final=[];
    Diff_tap2_final=[];
    
    Diff_BL1_tap1_final=[];
    Diff_BL2_tap1_final=[];
    FR_smooth_tapBL1={}; 
    FR_smooth_tapBL1={};
    FR_smooth_BL_BL1={};
    FR_unsmooth_tapBL1={};
    FR_unsmooth_BL_BL1={};
    raw_FR_trial_tap1={};
    raw_FR_trial_BL1={};
    BL1_timings=SMA.Timings.BL1;
    BL2_timings=SMA.Timings.BL2;
    tap1_timings=SMA.Timings.Tap1;
    tap2_timings=SMA.Timings.Tap2;
    
%     Looking at time difference between the different stimulus (used in
%     plotting)
    Diff_BL2=BL2_timings-BL1_timings;
    Diff_tap1=tap1_timings-BL1_timings;
    Diff_tap2=tap2_timings-BL1_timings;
    
    Diff_BL1_tap1=tap1_timings-BL1_timings;
    Diff_BL2_tap1=tap1_timings-BL2_timings;
    
    for k=1:128 % total channel number
        ct=1;
        FR_BL1=[];
        FR_BL2=[];
        FR_tap1=[];
        
        
        ch_name=sprintf('ch%d',k);
        all_spks_BL1=SMA.(Ped_name).all_spikes_bl1; % All the neural data where 0s corresponds to BL1
        all_spks_tap1=SMA.(Ped_name).all_spikes_tap1; % All the neural data where 0s corresponds to tap 1 stimulus
        all_spks_BL2=SMA.(Ped_name).all_spikes_bl2; % All the neural data where 0s corresponds to BL2
        
        non_chew=SMA.(Ped_name).savetrials.(ch_name); % taking only the non-chew trials
        
        for trial_no=1:size(all_spks_BL1,2) %trial number in the block
            
            not_chew=any(non_chew==trial_no); % checking if the trial is non chew
            if(not_chew==1)
                true_cond=any(Req_trials(self_tap)==(trial_no*2)-1); % Checking if trial satisfies the condition
                if(true_cond==1)
                    
                    spks_hist_BL1=all_spks_BL1{k,trial_no}; % Taking the neural data corresponding to the required trial and channel number
                    spks_hist_tap1=all_spks_tap1{k,trial_no};
                    spks_hist_BL2=all_spks_BL2{k,trial_no};
                    
                    edges=(-2:0.0005:6);
                    
                    edges_tap1=(-4:0.0005:6);
                    
                    bin_width=diff(edges);
                    bin_width_tap1=diff(edges_tap1);
                    
                    [N_BL1,edges] = histcounts(spks_hist_BL1,'BinEdges',edges); % taking the histogram
                    [N_BL2,edges] = histcounts(spks_hist_BL2,'BinEdges',edges);
                    [N_tap1, edges_tap1] = histcounts(spks_hist_tap1,'BinEdges',edges_tap1);
                    
                    firing_rate_BL1=N_BL1/mean(bin_width);  % calculating the firing rate
                    firing_rate_BL2=N_BL2/mean(bin_width);
                    firing_rate_tap1=N_tap1/mean(bin_width);
                    
                    raw_FR_trial_BL1{k,ct}=firing_rate_BL1;
                    raw_FR_trial_BL2{k,ct}=firing_rate_BL2;
                    FR_trial_BL1(k, ct)=mean(firing_rate_BL1(3000:4000)); % Taking mean of baseline firing rate : -500ms to 0s on the onset of the baseline stimulus
                    FR_BL1_norm_trial=firing_rate_BL1-FR_trial_BL1(k, ct);
                    avg_FR_BL_trial=firing_rate_tap1-FR_trial_BL1(k, ct);  % Normalizing the neural data
                    [FR_smooth_BL_tap_trial, window_trial] = smoothdata(avg_FR_BL_trial,'gaussian',300);
                    [FR_smooth_BL_BL_norm_trial, window_trial] = smoothdata(FR_BL1_norm_trial,'gaussian',300); % smoothening it for plots
                    FR_smooth_tapBL1{k,ct}=FR_smooth_BL_tap_trial;
                    FR_smooth_BL_BL1{k,ct}=FR_smooth_BL_BL_norm_trial;
                    FR_unsmooth_tapBL1{k,ct}=avg_FR_BL_trial;
                    FR_unsmooth_BL_BL1{k,ct}=FR_BL1_norm_trial;
                    raw_FR_trial_tap1{k,ct}= firing_rate_tap1;
                    raw_FR_trial_BL1{k,ct}=firing_rate_BL1;
                    FR_trial_BL2(k, ct)=mean(firing_rate_BL2(3000:4000));
                    
                    FR_trial_BL1_swin(k,ct)=mean(firing_rate_BL1(3500:4000)); % Calculating baseline mean per trail of a smaller window from -250ms to 0s
                    FR_trial_BL2_swin(k,ct)=mean(firing_rate_BL2(3500:4000));
                    
                    FR_trial_RW(k, ct)=mean(firing_rate_tap1(7600:8600)); % calculating the response window mean from -200ms to 300ms from baseline
                    FR_trial_RW_swin(k, ct)=mean(firing_rate_tap1(8000:8500));% calculating the small response window mean from 0ms to 250ms  from baseline
                    Diff_RW_BL1(k, ct)=FR_trial_RW_swin(k, ct)-FR_trial_BL1_swin(k,ct); % Subtracting response window mean from baseline mean (MOR calculaion)
                    Diff_RW_BL2(k, ct)=FR_trial_RW_swin(k, ct)- FR_trial_BL2_swin(k,ct);
                    
                    ct=ct+1;
                    Concatinating all the trial values
                    FR_BL1=[FR_BL1;firing_rate_BL1];
                    FR_BL2=[FR_BL2;firing_rate_BL2];
                    FR_tap1=[FR_tap1;firing_rate_tap1];
                    
                    
                    Diff_BL2_trial=Diff_BL2(trial_no);
                    Diff_tap1_trial=Diff_tap1(trial_no);
                    Diff_tap2_trial=Diff_tap2(trial_no);
                    
                    Diff_BL1tap1_trial=Diff_BL1_tap1(trial_no);
                    Diff_BL2tap1_trial=Diff_BL2_tap1(trial_no);
                    
                    Diff_BL2_final=[Diff_BL2_final;Diff_BL2_trial];
                    Diff_tap1_final=[Diff_tap1_final;Diff_tap1_trial];
                    Diff_tap2_final=[Diff_tap2_final;Diff_tap2_trial];
                    
                    Diff_BL1_tap1_final=[Diff_BL1_tap1_final;Diff_BL1tap1_trial];
                    Diff_BL2_tap1_final=[Diff_BL2_tap1_final;Diff_BL2tap1_trial];
                             
                end
            end
        end
        Taking mean of all the trials
        avg_FR_BL1=mean(FR_BL1,1);
        avg_FR_BL2=mean(FR_BL2,1);
        
        avg_FR_tap1=mean(FR_tap1,1);
        
        
        avg_DiffBL2=mean(Diff_BL2_final,1);
        avg_Difftap1=mean(Diff_tap1_final,1);
        avg_Difftap2=mean(Diff_tap2_final,1);
        
        avg_diffBL1tap1=mean(Diff_BL1_tap1_final,1);
        avg_diffBL2tap1=mean(Diff_BL2_tap1_final,1);
        
        
        baseline1_window_FR=avg_FR_BL1(3000:4000);
        
        baseline_window_avg_FR=mean(baseline1_window_FR);
        baseline_window_std_FR=std(baseline1_window_FR);
        
        
        %  baseline adjusted
        avg_FR_BL=avg_FR_BL1-baseline_window_avg_FR;
        avg_FR_tap1=avg_FR_tap1-baseline_window_avg_FR;
        
        [FR_smooth_BL, window] = smoothdata(avg_FR_BL,'gaussian',300);
        [FR_smooth_tap1, window] = smoothdata(avg_FR_tap1,'gaussian',300);
        
        baseline_smooth = std(FR_smooth_BL(3000:4000));
      
        BL_FR_std_smooth(k) = baseline_smooth;
        FR_avg_smooth_BLonset{k}=FR_smooth_BL;
        FR_avg_smooth_taponset{k}=FR_smooth_tap1;
        
        Diff_all_BL2(k)=avg_DiffBL2;
        Diff_all_tap1(k)=avg_Difftap1;
        Diff_all_tap2(k)=avg_Difftap2;
        
        Diff_all_BL1tap1(k)=avg_diffBL1tap1;
        Diff_all_BL2tap1(k)=avg_diffBL2tap1;
            
    end
    SMA.FR.(Ped_name).(tap_type).FR_norm_trial_unsmooth_tapBL1=FR_unsmooth_tapBL1;
    SMA.FR.(Ped_name).(tap_type).FR_norm_trial_unsmooth_BL1=FR_unsmooth_BL_BL1;
    FR_vals.FR.(Ped_name).(tap_type).FR_raw_trial_unsmooth_tap1=raw_FR_trial_tap1;
    SMA.FR.(Ped_name).(tap_type).FR_raw_trial_unsmooth_BL1=raw_FR_trial_BL1;
    SMA.FR.(Ped_name).(tap_type).FR_norm_trial_smooth_BL1=FR_smooth_BL_BL1;                                                                 FR_smooth_tapBL1;
    SMA.FR.(Ped_name).(tap_type).FR_norm_trial_smooth_tap1=FR_smooth_tapBL1;
    FR_vals.FR.(Ped_name).(tap_type).FR_raw_trial_unsmooth_BL1=raw_FR_trial_BL1;
    FR_vals.FR.(Ped_name).(tap_type).FR_raw_trial_unsmooth_BL2=raw_FR_trial_BL2;
    
%     Storing all the data in the struct
    SMA.(Ped_name).FR.(tap_type).FR_trial_BL1= FR_trial_BL1;
    SMA.(Ped_name).FR.(tap_type).FR_trial_RW= FR_trial_RW;
    %
    SMA.(Ped_name).FR.(tap_type).FR_trial_BL2= FR_trial_BL2;
    SMA.(Ped_name).FR.(tap_type).FR_trial_BL1_swin=FR_trial_BL1_swin;
    SMA.(Ped_name).FR.(tap_type).FR_trial_BL2_swin= FR_trial_BL2_swin;
    SMA.(Ped_name).FR.(tap_type).FR_trial_tapBL1_diff= Diff_RW_BL1;
    SMA.(Ped_name).FR.(tap_type).FR_trial_tapBL2_diff= Diff_RW_BL2;
    SMA.(Ped_name).FR.(tap_type).FR_trial_smooth_tapBL1= FR_smooth_tapBL1;
    
    SMA.(Ped_name).FR.(tap_type).FR_trial_RW_swin= FR_trial_RW_swin;
    
    SMA.(Ped_name).FR.(tap_type).FR_smooth_all=FR_avg_smooth_BLonset;
    SMA.(Ped_name).FR.(tap_type).FR_smooth_tap1=FR_avg_smooth_taponset;
    SMA.(Ped_name).FR.(tap_type).BL_FR_std=BL_FR_std_smooth;
    
    SMA.timings.(tap_type).BL2_diff=Diff_all_BL2;
    SMA.timings.(tap_type).tap1_diff=Diff_all_tap1;
    SMA.timings.(tap_type).tap2_diff=Diff_all_tap2;
    
    SMA.timingstap1.(tap_type).tap1_BL1=Diff_all_BL1tap1;
    SMA.timingstap1.(tap_type).tap1_BL2=Diff_all_BL2tap1;
    
    
    
    disp('--- DONE Histogram Photo_onset ----')
    
end

end
