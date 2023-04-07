from tqdm import tqdm
import os
import numpy as nps
import requests
import json
import pandas as pd
from datetime import datetime
from datetime import date

def main():
    #First request
    req = requests.get('https://osi.ipf.msu.edu/piwebapi/assetdatabases/F1RDxYSRoDn9-066ETsCvigyBwjEBIyuXKmUGi-Jb82kTJRwSVBGLVBQSElTVERBVEFcQ0FMQ19URVNU/elements')
    buildings = pd.read_csv('helper_data/bldg_to_sampleloc.csv')


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



    format_str = "%Y-%m-%dT%H:%M:%S.%fZ"
    #UPDATES ALL THE JSON FILES 
    meters = list(buildings['meter_id'])
    for item in tqdm(req.json()['Items']):
        req2 = requests.get('https://osi.ipf.msu.edu/piwebapi/elements/{}/elements'.format(item['WebId']))
        for item2 in req2.json()['Items']:
            if item2['Name'] in meters:
                
                
                
                

                with open('meters_json/{}_{}.json'.format("_".join(item['Name'].replace('/', '').split(' ')).lower(), item2['Name']), 'w') as outfile:
                    try:
                        dt_object = parse_datetime_with_variable_fraction(recorded.json()['Items'][0]['Items'][-1]['Timestamp'], format_str)
                        
                        existing_data = json.load(outfile)
                        recorded = requests.get('https://osi.ipf.msu.edu/piwebapi/streamsets/{}/recorded?StartTime=*-{}d&EndTime=*-0d&MaxCount=50000'.format(item2['WebId'], (date.today() - dt_object).days))
                        existing_data.update(recorded)
                        
                        json.dump(existing_data , outfile)
                        df = pd.read_json('meters_json/{}_{}.json'.format("_".join(item['Name'].split(' '), item2['Name']).lower()))
                        df.to_csv('meters_csv/{}.{}.csv'.format("_".join(item['Name'].split(' ')).lower(), item2['Name']))
                        
                    except:
                        pass

    #CONVERTS ALL JSON FILES TO CSV
    json_dir = os.listdir('meters_json')
    for json_file in json_dir:
        print(json_file)
        json_data = pd.read_json('meters_json/' + json_file)
        json_data.to_csv('meters_csv/{}.csv'.format(json_file.split('.')[0]))     

if __name__ == "__main__":
    main()      
