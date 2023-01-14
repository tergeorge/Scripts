% Loading the trial_array; matrix that contains the behavioural response.
% Removing the extra trial (cleaning the data)
addpath(genpath('D:\BMI labwork\Neural Analysis\SMA_0223'))
load('Trial_array.mat')
global neuralsignal
% Removing all the erronous trial time points
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
ped_count=1;
analog_blk=[1 2 3 4 5 6 7 8];
sma=[1 2 3 4 5 6 7 8];
Ped=["A"];

%%
total_blks=8;
for ff=1:total_blks
    sma_name=sprintf("sma%d",sma(ff));
    load (['fatigue_analogData_blk' num2str(analog_blk(ff)) '.mat']) % loading the analog data that contains the timings of the threshold crossing spikes
    time_signal=analogData.taskVariables_1kHz.timingPulses;
    timesignal_new=upsample(time_signal,2);
    
    photodiode_event=find(timesignal_new>100); % Finding the pulses that have amplitude more than 100
    
    
    photodiode_grouped = mat2cell( photodiode_event, 1, diff( [0, find(diff(photodiode_event) ~= 2), length(photodiode_event)] )) ;
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
    
    
    
    BL_1=[];
    BL_2=[];
    tap_1=[];
    tap_2=[];
    BL1_trial=1;
    BL2_trial=1;
    tap1_trial=1;
    tap2_trial=1;
    
    
    
    for i=1:4:size(photodiode_grouped ,2) %For loop for finding the photodiode values corresponding to baseline 2
        
        BL_1( BL1_trial)=photodiode_grouped{1,i}(1);
        BL1_trial= BL1_trial+1;
    end
    
    for i=2:4:size(photodiode_grouped ,2) %For loop for finding the photodiode values corresponding to baseline 1
        
        BL_2(BL2_trial)=photodiode_grouped{1,i}(1);
        BL2_trial= BL2_trial+1;
    end
    
    for i=3:4:size(photodiode_grouped ,2) %For loop for finding the photodiode values corresponding to tap 1
        
        tap_1(tap1_trial)=photodiode_grouped{1,i}(1);
        tap1_trial= tap1_trial+1;
    end
    
    for i=4:4:size(photodiode_grouped ,2) %For loop for finding the time values corresponding to tap 2
        
        tap_2(tap2_trial)=photodiode_grouped{1,i}(1);
        tap2_trial= tap2_trial+1;
    end
    
    SMA.(sma_name).Timings.BL_1=BL_1;
    SMA.(sma_name).Timings.BL_2=BL_2;
    SMA.(sma_name).Timings.Tap_1=tap_1;
    SMA.(sma_name).Timings.Tap_2=tap_2;
    
    
end
SMA.sma8.Timings.BL_1(end)=[];
SMA.sma8.Timings.BL_2(end)=[];



%%

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

%Load Nsp data for ERP analysis
channel_ct=8;
for ch=1:channel_ct
    sma_type=sprintf('sma%d',ch);
    home_dir = "D:\BMI labwork\Neural Analysis\SMA_0223\"+ sprintf("SMA_%d",ch);
    NSP_names = ["A"];
    for NSP_id = 1
        
        NSP = NSP_names(NSP_id);
        Ped_name=sprintf('Ped%s',NSP);
        dir_name = home_dir + "\dataStreamer\"+ sprintf("NSP%s",NSP);
        dir_name=convertStringsToChars(dir_name);
        files = rdir([dir_name,'\*.ns3']);
        files = erase(files,'\*.ns3');
        NSx = openNSx(files{1});
        
        channels = [1:128];
        E_ts_tap1=SMA.(sma_type).Timings.Tap_1;
        E_ts_tap2=SMA.(sma_type).Timings.Tap_2;
        E_ts_BL1=SMA.(sma_type).Timings.BL_1 ;
        dur_before = 4000;  %grab X ms of data before each spike
        dur_after = 3000;  %grab X ms of data after each spike
        baseline_window = [-500, 0];  %window, in ms, to get baseline data for z-scoring (event occurs at zero)
        filter_flag = true; %flag to filter neural data. Need Singal Processing toolbox
        [neuralsignal] = alignAnalogSignal(NSx, E_ts_tap1, dur_before, dur_after, baseline_window, channels, filter_flag,neuralsignal,sma_type,Ped_name,'TapNo_1');
        [neuralsignal] = alignAnalogSignal(NSx, E_ts_tap2, dur_before, dur_after, baseline_window, channels, filter_flag,neuralsignal,sma_type,Ped_name,'TapNo_2');
        [neuralsignal] = alignAnalogSignal_baseline(NSx, E_ts_BL1, dur_before, dur_after, baseline_window, channels, filter_flag,neuralsignal,sma_type,Ped_name,'BL1');
        
    end
end
%%
%Concatenate all neuralsignal blocks



total_blks=8;
for P=1:ped_count
    
    Ped_name=sprintf("Ped%s",Ped(P));
    
    for ch=1:128
        Ch_name=sprintf('Ch%d',ch);
        All_neural_BL1=neuralsignal.baseline_1.(Ped_name).sma1.(Ch_name).baselinesignal;
        
        All_neural_tap1=neuralsignal.TapNo_1.(Ped_name).sma1.(Ch_name).neuralsignal;
        All_neural_tap2=neuralsignal.TapNo_2.(Ped_name).sma1.(Ch_name).neuralsignal;
        
        for ff=2:total_blks
            sma_name=sprintf("sma%d",ff);
            All_neural_BL1=vertcat(All_neural_BL1,neuralsignal.baseline_1.(Ped_name).(sma_name).(Ch_name).baselinesignal);
            
            All_neural_tap1=vertcat( All_neural_tap1,neuralsignal.TapNo_1.(Ped_name).(sma_name).(Ch_name).neuralsignal);
            All_neural_tap2=vertcat(All_neural_tap2,neuralsignal.TapNo_2.(Ped_name).(sma_name).(Ch_name).neuralsignal);
        end
        neuralsignal.(Ped_name).(Ch_name).all_signal_bl1=All_neural_BL1;
        
        neuralsignal.(Ped_name).(Ch_name).all_signal_tap1=All_neural_tap1;
        neuralsignal.(Ped_name).(Ch_name).all_signal_tap2=All_neural_tap2;
    end
end

%%
%Calculating the average of the neural signal
load('savetrials.mat')
tap_type="selftap";
for P=1:ped_count
    
    Ped_name=sprintf("Ped%s",Ped(P));
    channels = [1:128];
    [neuralsignal] = alignAnalogSignal_tap1(savetrials,Trial_array,channels,neuralsignal,Ped_name,tap_type);
    
end


tap_type="autotap";
for P=1:ped_count
    
    Ped_name=sprintf("Ped%s",Ped(P));
    channels = [1:128];
    [neuralsignal] = alignAnalogSignal_tap1(savetrials,Trial_array,channels,neuralsignal,Ped_name,tap_type);
    
end
