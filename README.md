There are 3 main folders in this repo:
1) Matlab folder:
   The matlab folder contains matlab scripts used for analysis neural spike data and neural voltage data recorded from microelctrode arrays surgically
   implanted in a human participant. 
   
   The following scripts are in the folder:
   1. calculateFiringRate.m
      This script is used for calculating the firing rate of the signal. It calls the function tap1.m
   2. Calculate_ERP.m and alignAnalogSignal_tap1.m 
      These two scripts are used to calculate the Event related potential of the neural signal recorded. 
      
   3. Compute_spectrogram.m
      This script is used to compute the time-frequency spectrogram of the neural signal recorded. 
      
2) Python folder:
    This folder contains scripts written in python
    1. image_analysis.py
       This script is used for the analysis of tissue image collected using in vivo fluorescence imaging using open cv python package. 
    2. heartrhythm_dataanalysis.py
       This script is used for the data analysis of ECG data and capturing features related to arrhythmia.
        
    3. pandas_dataanalysis_1.ipynb and pandas_dataanalysis_2.ipynb are jupyter notebooks that contain scripts used for data analysis using python packages like pandas and seaborn. 
   
  3) R folder
   This folder contains scripts written in R programming language. 
   Breastcancer_detectionApp.R
   This script is used to create a shiny application on R that is used for the detection of breast cancer tissues using ML algorithms. 
       
