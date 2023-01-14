%% LFP spectrogram
% Define frequency bands
freq_start = [7 12 35 60 100 150 200];
freq_end   = [12 35 60 100 150 200 250];

freq_ticks = [freq_start freq_end(end)];
center_freq = mean([freq_start;freq_end]);
num_freq   = numel(freq_end);

instances = 0:2; %NSPs
nChan = length(instances) * 128; %total channels
maxBufferLength = 256; %length of signal (L), change for better time/freq resolution

hammingWindow = hamming(maxBufferLength)';
hanningWindow = hann(maxBufferLength)';
Fs = 2000; %sampling frequency
t = -0.5:1/Fs:1;
Srate = Fs;
freqs = Fs*(0:maxBufferLength/2)/maxBufferLength; %frequencies
lfpBuffer = cell(nChan, 1);

LFP_Freq_lp = 12;
EMG_Freq_lp = 6;
Order = 6;
ch = 80;% [1, 10, 20, 50, 110];
for c = 1:numel(ch)
    ch_str = sprintf('Ch%d', ch(c));
    trial_count = 0;
    for tr = 1:170 %loop through trials
        trial_count = trial_count+1;
        LFP =neuralsignal.selftap.PedA.(ch_str).signal_raw(tr,:); % Get the Neural signal per trial
        LFP = LFP(1:3001); % Extract for specific time period
        LFP = lp_butter(LFP, Srate, LFP_Freq_lp, Order)/5; % Low pass filter the signal
        LFP_all(trial_count,:) = LFP;
        
        for f = 1:num_freq % Run loop for each of the specified frequency ranges
            freqIdx = freqs >= freq_start(f) & freqs <= freq_end(f);
            win_start = 1;
            win_size  = maxBufferLength-1;
            step_size = 32;
            win_end = win_start+win_size;
            cnt_movwin = 0;
            while win_end <= length(LFP)
                cnt_movwin = cnt_movwin+1;
                X_lfp = LFP(win_start:win_end);
                T(cnt_movwin) = mean(t(win_start:win_end));
                Y_lfp = fft(hanningWindow(1:size(X_lfp, 1), :) .* X_lfp); % Compute fast fourier transform for each window
                P2_lfp = abs(Y_lfp/maxBufferLength);
                P_lfp = P2_lfp(:,1:maxBufferLength/2+1);
                P_lfp(:,2:end-1) = 2*P_lfp(:,2:end-1);
                power_lfp_mn = mean(P_lfp(:,freqIdx), 2);
                power_lfp_sd = std(P_lfp(:,freqIdx),[],2);
                POWER_LFP_mn(f,cnt_movwin) = power_lfp_mn;
                POWER_LFP_sd(f,cnt_movwin) = power_lfp_sd;
                
                win_start = win_start+step_size;
                win_end = win_start+win_size;
            end
            
            BL_1 = neuralsignal.selftap.PedA.(ch_str).signal_bl1;
            BL_yfp = fft(hanningWindow(1:size(BL_1, 1), :) .* BL_1);
            BL2_lfp = abs(BL_yfp/maxBufferLength);
            BL_lfp = BL2_lfp(:,1:maxBufferLength/2+1);
            BL_lfp(:,2:end-1) = 2*BL_lfp(:,2:end-1);
            power_bl_mn = mean(BL_lfp(:,freqIdx), 2);
            power_bl_sd = std(BL_lfp(:,freqIdx),[],2);
            POWER_bl_mn(f) = power_bl_mn;
            POWER_bl_sd(f) = power_bl_sd;
            
        end
        
        
        base_mn = mean(POWER_LFP_mn(:,1),2);
        base_sd = std(POWER_LFP_mn(:,1),[],2);
        
        base_mn = mean(POWER_bl_mn);
        base_sd = std(POWER_bl_mn);
        HG_LFP_norm(trial_count,:,:) = log10(POWER_LFP_mn./base_mn);
        HG_LFP_norm(trial_count,:,:) = (POWER_LFP_mn-base_mn)./base_sd;
        LFP =lp_butter(LFP, Srate, LFP_Freq_lp, Order)/5;
        
    end % tr loop
    power_spect = squeeze(mean(HG_LFP_norm,1));
    figure(ch),subplot(2,1,2)
    pcolor(T,log10(freq_start),power_spect),colormap jet,shading interp
    c = colorbar;
    c.Label.String = 'Log normalized power';
    hold on
    plot([0 0],[0 250],'-m')
    title('LFP spectrogram')
    caxis([-0.3 0.25])
    set(gca,'YTick',log10(freq_ticks),'YTickLabel',num2str(freq_ticks'))
    xlabel('time(s)'),ylabel('frequency (Hz)')
end % ch loop

subplot(2,1,1)
plot(t,mean(LFP_all)),title('LFP'),grid on,ylabel('Amplitude')
set(gcf,'Color','White')
