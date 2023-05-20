import pandas as pd
import os 

def test_csv():

    list_dir = os.listdir('meters_csv')
    for file in list_dir:
        df = pd.read_csv('meters_csv/{}'.format(file))
        print('Start date for the data frame {}: {}'.format(file, df.iloc[0]['Timestamp']))
        print("End date for the data frame {}: {}".format(file, df.iloc[-1]['Timestamp']))