
import pandas as pd

# Load all the files
df_episodes = pd.read_csv ('C:\\Users\\Teresa George\\Downloads\\data\\episodes_data.csv') 
df_outcomesdata= pd.read_csv('C:\\Users\\Teresa George\\Downloads\\data\\outcomes_data.csv')
df_deviceinfo = pd.read_csv('C:\\Users\\Teresa George\\Downloads\\data\\device_info.csv')

# Get the device IDS
device_IDS = df_episodes['device_id'].unique()

count = 0
# Initialize the data frame to store the output data
cols = ['Sub_ID', 'Total_Arr1_burden', 'Total_Arr2_burden', 'Awake_Arr1_burden', 'Sleep_Arr1_burden', 'Awake_Arr2_burden', 'Sleep_Arr2_burden']
output_df = pd.DataFrame(columns=cols, index=range(len(device_IDS)))
  
# Run loop to calculate value for each device   
for device_ids in device_IDS:
    # Get all episodes for a subject or device is
    df_device = df_episodes.loc[(df_episodes['device_id'] ==device_ids)]
    # Get the corresponding sunject id
    sub_ID = df_deviceinfo.loc[df_deviceinfo['device_id'] == device_ids, 'subj_id'].item()  
    df_device.drop(df_device[df_device['rhythm_type'] == "NOISE"].index, inplace = True) # Drop Noise
    df_device['end_time'] = pd.to_datetime(df_device['end_time']) # Convert end time to date time
    df_device['start_time'] = pd.to_datetime(df_device['start_time'])  # Convert start time to date time
    df_device['Duration'] = (df_device['end_time'] - df_device['start_time']).dt.total_seconds() # Calculate duration in s
     
        
    #Total ARR_1 and ARR_2 duration
    df_ARR_1 = df_device.loc[(df_device['rhythm_type'] == "ARR1")] # Get all values for event ARR1
    df_ARR_2 = df_device.loc[(df_device['rhythm_type'] == "ARR2")] # Get all values for event ARR2
    Duration_ARR1 = df_ARR_1['Duration'].sum() #Get the total duration of the event
    Duration_ARR2 = df_ARR_2['Duration'].sum()
    Total_Duration = df_device['Duration'].sum() 
    # Calculate the burden for ARR1 and ARR2
    Arr_1_burden = Duration_ARR1/Total_Duration
    Arr_2_burden = Duration_ARR2/Total_Duration
     
    # awake and sleep ARR_1 and ARR_2 duration
    df_device['end_time_hrs'] = pd.to_datetime(df_device['end_time']).dt.hour # Get Hour
    df_device['start_time_hrs'] = pd.to_datetime(df_device['start_time']).dt.hour
    df_waking = df_device.loc[(df_device['start_time_hrs'] >= 6) & (df_device['start_time_hrs'] < 22)] # Check for awake 
    df_sleep = df_device.loc[(df_device['start_time_hrs'] >= 22) | (df_device['start_time_hrs'] < 6)]  # Check for sleep
     
    # Awake
    # Calculate the total duration for ARR1 and 2 during wake time
    df_ARR_1_awake = df_waking.loc[(df_waking['rhythm_type'] == "ARR1")]
    df_ARR_2_awake = df_waking.loc[(df_waking['rhythm_type'] == "ARR2")]
    Duration_ARR1_awake = df_ARR_1_awake['Duration'].sum()
    Duration_ARR2_awake = df_ARR_2_awake['Duration'].sum()
     
    #Sleep
    # Calculate the total duration for ARR1 and 2 during sleep time
    df_ARR_1_sleep = df_sleep.loc[(df_sleep['rhythm_type'] == "ARR1")]
    df_ARR_2_sleep = df_sleep.loc[(df_sleep['rhythm_type'] == "ARR2")]
    Duration_ARR1_sleep = df_ARR_1_sleep['Duration'].sum()
    Duration_ARR2_sleep = df_ARR_2_sleep['Duration'].sum()
    
    #Calculate burden during awake time
    Total_Duration_awake = df_waking['Duration'].sum()
    Arr_1_burden_awake = Duration_ARR1_awake/Total_Duration_awake
    Arr_2_burden_awake = Duration_ARR2_awake/Total_Duration_awake
    
    #Calculate burden during sleep time
    Total_Duration_sleep = df_sleep['Duration'].sum()
    Arr_1_burden_sleep = Duration_ARR1_sleep/Total_Duration_sleep
    Arr_2_burden_sleep = Duration_ARR2_sleep/Total_Duration_sleep
     
    # Store all the values in a dataframe    
    output_df.loc[count].Sub_ID = sub_ID
    output_df.loc[count].Total_Arr1_burden = Arr_1_burden
    output_df.loc[count].Total_Arr2_burden = Arr_2_burden
    output_df.loc[count].Awake_Arr1_burden = Arr_1_burden_awake
    output_df.loc[count].Sleep_Arr1_burden = Arr_1_burden_sleep                 
    output_df.loc[count].Awake_Arr2_burden = Arr_2_burden_awake
    output_df.loc[count].Sleep_Arr2_burden = Arr_2_burden_sleep
    count = count + 1


print(output_df)
# save dataframe as .csv
output_df.to_csv("C:\\Users\\Teresa George\\Desktop\\assignment_irhythm.csv")





