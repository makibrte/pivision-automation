import os 
import pandas as pd
import numpy as np

dir_ = os.listdir()
df = pd.read_csv("akers_hall_0326W1.csv")
type_ = type(df['Timestamp'])
names = df.columns
for file in dir_:
    if file != 'search.py':
        df_temp = pd.read_csv(file)
        
            
        print(f'{np.sum(df_temp.duplicated(subset=["Timestamp"]))}')
         
    
    