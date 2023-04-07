from tqdm import tqdm
import os
import numpy as np
import requests
import json
import pandas as pd
from datetime import date
from datetime import datetime

def parse_datetime_with_variable_fraction(datetime_str, format_str):
    """
        Parses the datetime from json response so it can be used to calculate the day difference between two dates 
        
        Paramaters:
            datetime_str (str) : Timestamp string from the json response by pyvision API
            format_str (str) : Method used to format the string

        Returns:
            dt_object (datetime.date) : Correct dtype for the date 
    """
    fractional_start = datetime_str.index('.') + 1
    fractional_end = datetime_str.index('Z')
    fractional_part = datetime_str[fractional_start:fractional_end]

    # Truncate or pad the fractional part to fit exactly six digits
    adjusted_fractional_part = (fractional_part[:6] + '000000')[:6]

    # Replace the original fractional part with the adjusted one
    adjusted_datetime_str = datetime_str[:fractional_start] + adjusted_fractional_part + datetime_str[fractional_end:]

    dt_object = datetime.strptime(adjusted_datetime_str, format_str)

    return dt_object

def main():
    #INITIAL REQUEST TO LIST ALL BUILDINGS WITH ASSETS ON PIVISION WEBSITE
    req = requests.get('https://osi.ipf.msu.edu/piwebapi/assetdatabases/F1RDxYSRoDn9-066ETsCvigyBwjEBIyuXKmUGi-Jb82kTJRwSVBGLVBQSElTVERBVEFcQ0FMQ19URVNU/elements')
    buildings = pd.read_csv('helper_data/bldg_to_sampleloc.csv')
    meters = list(buildings['meter_id'])

    #ITERATES OVER ALL THE BUILDINGS AND ONLY MAKES DATA REQUEST FOR THOSE INSIDE BLDG_TO_SAMPLELOC
    
    start_date = date(2020,1,1)

    format_str = "%Y-%m-%dT%H:%M:%S.%fZ"
    today = date.today()
    interval = (today-start_date).days
    meters = list(buildings['meter_id'])
    for item in tqdm(req.json()['Items']):
        req2 = requests.get('https://osi.ipf.msu.edu/piwebapi/elements/{}/elements'.format(item['WebId']))
        for item2 in req2.json()['Items']:
            if item2['Name'] in meters:
                interval_temp = interval
                content = []
                for i in range(0,4):

                    recorded = requests.get('https://osi.ipf.msu.edu/piwebapi/streamsets/{}/recorded?StartTime=*-{}d&EndTime=*-{}&MaxCount=50000'.format(item2['WebId'], interval_temp, int(interval / 4 * (3-i))))
                    interval_temp = interval / 4 * (4-i)
                    cont = recorded.json()['Items'][0]['Items']
                    content += cont
                dt_object = parse_datetime_with_variable_fraction(recorded.json()['Items'][0]['Items'][-1]['Timestamp'], format_str)

                # Extract the date from the datetime object
                date_object = dt_object.date()
                while(date.today() - date_object).days > 0:
                    
                    recorded = requests.get('https://osi.ipf.msu.edu/piwebapi/streamsets/{}/recorded?StartTime=*-{}d&EndTime=*-0d&MaxCount=50000'.format(item2['WebId'], (date.today() - date_object).days))
                    content += recorded.json()['Items'][0]['Items']
                    dt_object = parse_datetime_with_variable_fraction(recorded.json()['Items'][0]['Items'][-1]['Timestamp'], format_str)
                    date_object = dt_object.date()

                with open('example_json/{}_{}.json'.format("_".join(item['Name'].replace('/', '').split(' ')).lower(), item2['Name']), 'w') as outfile:
                    try:
                        
                        
                        
                        json.dump(content , outfile)
                        df = pd.read_json('example_json/{}_{}.json'.format("_".join(item['Name'].split(' '), item2['Name']).lower()))
                        df.to_csv('example_csv/{}.{}.csv'.format("_".join(item['Name'].split(' ')).lower(), item2['Name']))
                        
                    except:
                        pass
    json_dir = os.listdir('example_json')
    for json_file in json_dir:
        print(json_file)
        json_data = pd.read_json('example_json/' + json_file)
        json_data.to_csv('example_csv/{}.csv'.format(json_file.split('.')[0]))
            


if __name__ == "__main__":
    main()