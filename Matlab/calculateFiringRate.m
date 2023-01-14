% Multi-unit neural Analysis: SMA session 02/23
% Author : Teresa George


%%
% Loading the array containing the information about the trials: Responses, type of trial etc
% Cleaning up the trial array and removing extra trials
% global SMA 
global FR_vals_self
load('Trial_array.mat')
Trial_array=table2array(Trial_array);
Blk_1=Trial_array(1:46,:);
Blk_2=Trial_array(47:91,:);
Blk_3=Trial_array(92:134,:);
Blk_4=Trial_array(135:179,:);
Blk_5=Trial_array(180:219,:);
Blk_6=Trial_array(220:277,:);
Blk_7=Trial_array(278:336,:);
Blk_8=Trial_array(337:356,:);

Blk_2(:,4)=Blk_2(:,4)-94;
Blk_2(:,5)=Blk_2(:,5)-94;

Blk_3(:,4)=Blk_3(:,4)-190;
Blk_3(:,5)=Blk_3(:,5)-190;

Blk_4(:,4)=Blk_4(:,4)-280;
Blk_4(:,5)=Blk_4(:,5)-280;

Blk_5(:,4)=Blk_5(:,4)-382;
Blk_5(:,5)=Blk_5(:,5)-382;


Blk_6(:,4)=Blk_6(:,4)-470;
Blk_6(:,5)=Blk_6(:,5)-470;

Blk_7(:,4)=Blk_7(:,4)-590;
Blk_7(:,5)=Blk_7(:,5)-590;

Blk_8(:,4)=Blk_8(:,4)-712;
Blk_8(:,5)=Blk_8(:,5)-712;



%%
% Initializing all variables
ped_count=3;
analog_blk=[1 2 3 4 5 6 7 8];
sma=[1 2 3 4 5 6 7 8];
Ped=["A","B","C"];


%%
% To get all the 4 pulses from the analog data:

total_blks=8;
for ff=1:total_blks
    sma_name=sprintf("sma%d",sma(ff));
    load (['fatigue_analogData_blk' num2str(analog_blk(ff)) '.mat']) % loading the analog data that contains the timings of the threshold crossing spikes
    
    
    photodiode_event=find(analogData.taskVariables_1kHz.timingPulses>100); % Finding the pulses that have amplitude more than 100
    
    photodiode_grouped = mat2cell( photodiode_event, 1, diff( [0, find(diff(photodiode_event) ~= 1), length(photodiode_event)] )) ;
    i=1;
    
    % The while loop is used to take the time pulse of all the 4 events:
    % Baseline 1, Baseline 2, Tap 1, Tap 2.
    while(i<=size(photodiode_grouped ,2)-4)
        if  length(photodiode_grouped{1, i})>230 && length(photodiode_grouped{1, i+1})<60 && length(photodiode_grouped{1, i+3})>80 && length(photodiode_grouped{1, i+3})<110
            
            i=i+4;
            
        elseif(length(photodiode_grouped{1, i})>230)&& length(photodiode_grouped{1, i+1})<60
            
            photodiode_grouped(i)=[];
            photodiode_grouped(i)=[];
            
        else
            photodiode_grouped(i)=[];
            
        end
    end
    
% Initializing array variables
    BL_1=[];
    BL_2=[];
    tap_1=[];
    tap_2=[];
    BL1_trial=1;
    BL2_trial=1;
    tap1_trial=1;
    tap2_trial=1;
    
    for i=1:4:size(photodiode_grouped ,2) %For loop for finding the photodiode values corresponding to baseline 2
        
        BL_1( BL1_trial)=photodiode_grouped{1,i}(1)./1000;
        BL1_trial= BL1_trial+1;
    end
    
    for i=2:4:size(photodiode_grouped ,2) %For loop for finding the photodiode values corresponding to baseline 1
        
        BL_2(BL2_trial)=photodiode_grouped{1,i}(1)./1000;
        BL2_trial= BL2_trial+1;
    end
    
    for i=3:4:size(photodiode_grouped ,2) %For loop for finding the photodiode values corresponding to tap 1
        
        tap_1(tap1_trial)=photodiode_grouped{1,i}(1)./1000;
        tap1_trial= tap1_trial+1;
    end
    
    for i=4:4:size(photodiode_grouped ,2) %For loop for finding the time values corresponding to tap 2
        
        tap_2(tap2_trial)=photodiode_grouped{1,i}(1)./1000;
        tap2_trial= tap2_trial+1;
    end
    
    SMA.(sma_name).Timings.BL_1=BL_1;
    SMA.(sma_name).Timings.BL_2=BL_2;
    SMA.(sma_name).Timings.Tap_1=tap_1;
    SMA.(sma_name).Timings.Tap_2=tap_2;
    
    
end
SMA.sma8.Timings.BL_1(end)=[];
SMA.sma8.Timings.BL_2(end)=[];


% SMA struct is used to store all the time points corresponding to the 4
% events.
%% To get all the force pulses from the analog data (100ms pulses)
total_blks=8;
totalforce={};
count=1;
for ff=1:total_blks
    sma_name=sprintf("sma%d",sma(ff));
    load (['fatigue_analogData_blk' num2str(analog_blk(ff)) '.mat'])
    
    photodiode_event=find(analogData.taskVariables_1kHz.timingPulses>100);
    
    photodiode_grouped = mat2cell( photodiode_event, 1, diff( [0, find(diff(photodiode_event) ~= 1), length(photodiode_event)] )) ;
    
    
    for i=1:size(photodiode_grouped,2)
        
        if  length(photodiode_grouped{1, i})>80 && length(photodiode_grouped{1, i})<115
            totalforce{count}= photodiode_grouped{1,i};
            count=count+1;
        end
        
    end
end

%%
% Cut the neural data with respect to the 1st pulse. 2s before the pulse and
% 6s after the pulse.

total_blks=8;
for ff=1:total_blks
    for P=1:ped_count
        
        sma_name=sprintf("sma%d",ff);
        Ped_name=sprintf("Ped%s",Ped(P));
        pd_BL1=SMA.(sma_name).Timings.BL_1;
        load("SMA_"+num2str(sma(ff))+"\stimAndNeuralResp_byBlock_20210223.mat"); % loading the neural spikes data
        
        spike_trial=[];
        
        spikeTimes={};
        ct=1;
        
        for trial=1:length(pd_BL1)
            for ch=1:128
                
                spike_name=eval(sprintf("spikeTimes%s",Ped(P))+"_matrix");
                % Taking 2s before the onset of the baseline 1 activity and
                % 6s after the onset of baseline 1 activity.
                spike_electrode=spike_name{1,1}(ch,:);
                logicalIndex=(spike_electrode>=(pd_BL1(trial)-2) & spike_electrode<=(pd_BL1(trial)+6));
                spike_trial=find(logicalIndex);
                
                try
                    spikeTimes{ch,trial}=spike_electrode(spike_trial(1):spike_trial(end));
                    
                catch
                    spikeTimes{ch,trial}=1;
                    
                end
                
            end
        end
        
        SMA.(sma_name).(Ped_name).all_spikes=spikeTimes;
        disp('--- DONE Neural ----')
        
    end
end
%%
% Subtracting the timings of the events from the neural spike arrays so
% that 0s becomes the onset of the event.

% BL1 at 0s
% BL2 at 0s
% Tap 1 at 0s
% Tap 2 at 0s

for ff=1:total_blks
    for P=1:ped_count
        
        sma_name=sprintf("sma%d",ff);
        Ped_name=sprintf("Ped%s",Ped(P));
        BL1_start=SMA.(sma_name).Timings.BL_1;
        BL2_start=SMA.(sma_name).Timings.BL_2;
        tap1_start=SMA.(sma_name).Timings.Tap_1;
        tap2_start=SMA.(sma_name).Timings.Tap_2;
        
        spikeTimes_trial=SMA.(sma_name).(Ped_name).all_spikes;
        
        spiketimes_BL1=cell(128,length(BL1_start));
        spiketimes_BL2=cell(128,length(BL1_start));
        spiketimes_tap1=cell(128,length(BL1_start));
        spiketimes_tap2=cell(128,length(BL1_start));
        
        
        for trial=1:length(BL1_start)
            for ch=1:128
                
                
                spiketimes_BL1{ch,trial}=spikeTimes_trial{ch,trial}-BL1_start(trial);
                spiketimes_BL2{ch,trial}=spikeTimes_trial{ch,trial}-BL2_start(trial);
                spiketimes_tap1{ch,trial}=spikeTimes_trial{ch,trial}-tap1_start(trial);
                spiketimes_tap2{ch,trial}=spikeTimes_trial{ch,trial}-tap2_start(trial);
                
                
            end
        end
        SMA.(sma_name).(Ped_name).all_spikes_bl1=spiketimes_BL1;
        SMA.(sma_name).(Ped_name).all_spikes_bl2=spiketimes_BL2;
        SMA.(sma_name).(Ped_name).all_spikes_tap1=spiketimes_tap1;
        SMA.(sma_name).(Ped_name).all_spikes_tap2=spiketimes_tap2;
        
        
    end
end
%%
%Concatenate all sma blocks
% Concatenating all the SMA blocks into 1 matrix.
% Final SMA matrix contains 128 * total no of trials

for P=1:ped_count
    
    Ped_name=sprintf("Ped%s",Ped(P));
    
    
    
    All_SMA_BL1=SMA.sma1.(Ped_name).all_spikes_bl1;
    All_SMA_BL2=SMA.sma1.(Ped_name).all_spikes_bl2;
    All_SMA_tap1=SMA.sma1.(Ped_name).all_spikes_tap1;
    All_SMA_tap2=SMA.sma1.(Ped_name).all_spikes_tap2;
    
    for ff=2:total_blks
        sma_name=sprintf("sma%d",ff);
        All_SMA_BL1=horzcat(All_SMA_BL1,SMA.(sma_name).(Ped_name).all_spikes_bl1);
        All_SMA_BL2=horzcat(All_SMA_BL2,SMA.(sma_name).(Ped_name).all_spikes_bl2);
        All_SMA_tap1=horzcat( All_SMA_tap1,SMA.(sma_name).(Ped_name).all_spikes_tap1);
        All_SMA_tap2=horzcat(All_SMA_tap2,SMA.(sma_name).(Ped_name).all_spikes_tap2);
    end
    SMA.(Ped_name).all_spikes_bl1=All_SMA_BL1;
    SMA.(Ped_name).all_spikes_bl2= All_SMA_BL2;
    SMA.(Ped_name).all_spikes_tap1=All_SMA_tap1;
    SMA.(Ped_name).all_spikes_tap2=All_SMA_tap2;
    
end
%%
% Concatenate timings

total_blks=8;
All_timings_BL1=SMA.sma1.Timings.BL_1;
All_timings_BL2=SMA.sma1.Timings.BL_2;
All_timings_tap1=SMA.sma1.Timings.Tap_1;
All_timings_tap2=SMA.sma1.Timings.Tap_2;

for ff=2:total_blks
    sma_name=sprintf("sma%d",ff);
    All_timings_BL1=horzcat(All_timings_BL1,SMA.(sma_name).Timings.BL_1);
    All_timings_BL2=horzcat(All_timings_BL2,SMA.(sma_name).Timings.BL_2);
    All_timings_tap1=horzcat(All_timings_tap1,SMA.(sma_name).Timings.Tap_1);
    All_timings_tap2=horzcat(All_timings_tap2,SMA.(sma_name).Timings.Tap_2);
    
end

SMA.Timings.BL1= All_timings_BL1;
SMA.Timings.BL2=All_timings_BL2;
SMA.Timings.Tap1=All_timings_tap1;
SMA.Timings.Tap2=All_timings_tap2;

%%
% Remove chew trials (artifact removal)
% Only saving trials where the firing rate is less that 150 for a period
% of 150ms or less in all the 4 windows that are considered (Baseline 1
% window, baseline 2 window, tap 1 window and tap 2 window).


for P=1:ped_count   % Three Peds (A,B,C)
    
    Ped_name=sprintf("Ped%s",Ped(P));
    for k=1:128
        trial_count=1;
        ch_name=sprintf('ch%d',k);
        spikes_bl1=SMA.(Ped_name).all_spikes_bl1;
        spikes_bl2=SMA.(Ped_name).all_spikes_bl2;
        spikes_tap1=SMA.(Ped_name).all_spikes_tap1;
        spikes_tap2=SMA.(Ped_name).all_spikes_tap2;
        
        for i=1:size(spikes_bl1,2) % Trials per block : same number of trisl for all 4 pulses
            
            spks_hist_bl1=spikes_bl1{k,i};
            spks_hist_bl2=spikes_bl2{k,i};
            spks_hist_t1=spikes_tap1{k,i};
            spks_hist_t2=spikes_tap2{k,i};
            
            
            edges=(-2:0.0005:6);
            bin_width=diff(edges);
            
            [N_bl1,edges] = histcounts(spks_hist_bl1,'BinEdges',edges);
            [N_bl2,edges] = histcounts(spks_hist_bl2,'BinEdges',edges);
            [N_tap1,edges] = histcounts(spks_hist_t1,'BinEdges',edges);
            [N_tap2,edges] = histcounts(spks_hist_t2,'BinEdges',edges);
            
            
            
            firing_rate_bl1=N_bl1/mean(bin_width);
            firing_rate_bl2=N_bl2/mean(bin_width);
            firing_rate_tap1=N_tap1/mean(bin_width);
            firing_rate_tap2=N_tap2/mean(bin_width);
            
            [FR_smooth_bl1] = smoothdata(firing_rate_bl1,'gaussian',300);
            [FR_smooth_bl2] = smoothdata(firing_rate_bl2,'gaussian',300);
            [FR_smooth_tap1] = smoothdata(firing_rate_tap1,'gaussian',300);
            [FR_smooth_tap2] = smoothdata( firing_rate_tap2,'gaussian',300);
            
            high_BL1=find(FR_smooth_bl1(3000:4000)>=150);
            high_BL2=find(FR_smooth_bl2(3000:4000)>=150);
            high_tap1=find(FR_smooth_tap1(3600:4600)>=150);
            high_tap2=find(FR_smooth_tap2(3600:4600)>=150);
            
            
            
            if(length(high_BL1)<150)
                
                
                if length(high_BL2)<150 && length(high_tap1)<150 && length(high_tap2)<150
                    
                    
                    SMA.(Ped_name).savetrials.(ch_name)(trial_count)=i;
                    trial_count=trial_count+1;
                    
                    
                    
                end
            end
        end
    end
end


%%
%tap1 function is used to calculate the firing rate corresponding to the
%first tap ( either self-generated or externally generated)
global FR_vals;
Ped=['A'];
ped_count=1;
tap_type="autotap";

[SMA,FR_vals]= tap1(tap_type,Trial_array,Ped,ped_count,SMA);

tap_type="selftap";
%
[SMA,FR_vals]= tap1(tap_type,Trial_array,Ped,ped_count,SMA);

save('FR_valstrials_BL2_0223.mat','FR_vals','-v7.3')
