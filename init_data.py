from tqdm import tqdm
import os
import logging
import numpy as np
import requests
import json
import subprocess
import pandas as pd
from datetime import date
from datetime import datetime
import argparse
from tests import test_csv
from helper import remove_duplicates_csv
from helper import filename, get_meterdata, parse_datetime, get_elements, get_element, last_day, json_to_csv, first_day, remove_json_temp
parser = argparse.ArgumentParser(description='PiVision MSU Water Meter Data Automation-Initial Setup')

logging.basicConfig(filename='app.log', level=logging.INFO)
logging.info('Program started')
parser.add_argument('--tests', type=bool, default=True, help='Should the script print tests, recommended True')
parser.add_argument('--start', type=date, default=date(2020,1,1), help='Determines the starting date for the script')

def main(tests = True, start=date(2020,1,1)):
    #INITIAL REQUEST TO LIST ALL BUILDINGS WITH ASSETS ON PIVISION WEBSITE
    webID_dict = pd.DataFrame({'Name' : [], 
                                'WebID': []
                               
                               })
    req = get_elements()
    buildings = pd.read_csv('bldg_to_sampleloc.csv')
    meters = list(buildings['meter_id'])

    if not os.path.isdir('temp_data_csv'):
        print('Creating temp_data_csv')
        os.makedirs('temp_data_csv')
    #ITERATES OVER ALL THE BUILDINGS AND ONLY MAKES DATA REQUEST FOR THOSE INSIDE BLDG_TO_SAMPLELOC
    
    start_date = start

    format_str = "%Y-%m-%dT%H:%M:%S.%fZ"
    today = date.today()
    begin = (today-start_date).days
    meters = list(buildings['meter_id'])
    
    for item in tqdm(req.json()['Items']):
        req2 = get_element(item['WebId'])
        for item2 in req2.json()['Items']:
            if item2['Name'] in meters:

                webID_dict_temp = pd.DataFrame({'Name' : [item2['Name']],
                                   'WebID' : [item2['WebId']]})
                webID_dict = pd.concat([webID_dict, webID_dict_temp], ignore_index=True)
                

                content = []
                recorded = get_meterdata(item2, today, start_date)
                
                    
                cont = recorded.json()['Items'][0]['Items']
                content += cont
                
                dt_object = parse_datetime(last_day(recorded.json()), format_str)

                # Extract the date from the datetime object
                date_object = dt_object.date()
                
                #Makes requests until it gets latest data
                while(date.today() - date_object).days > 7:
                    
                    
                    recorded = get_meterdata(item2, today, date_object)
                    content += recorded.json()['Items'][0]['Items']
                    dt_object = parse_datetime(last_day(recorded.json()), format_str)
                    
                    date_object = dt_object.date()
                
                with open(f'{filename(item, item2).replace("json", "")}', 'w') as outfile:
                    print(outfile)
                    df = pd.json_normalize(content)
                    df.to_csv(outfile, index=False) 
    
    
    #TODO: Improve speed of weekly update
    #webID_dict.to_csv('webId.csv', index=False)
    remove_duplicates_csv()
    #RUN THE R-SCRIPT
    #dir_path = os.path.dirname(os.path.realpath(__file__)) # get the directory of the current Python script
    #r_script_path = os.path.join(dir_path, 'import_wm.R') # build the full path to the R script

    #command = "Rscript"
    #path2script = r_script_path

    #subprocess.call([command, path2script, "TRUE"]) 
    
    #REMOVES THE JSON FILES CREATED
    
    
            


if __name__ == "__main__":
    main()
    #if parser.tests:
     #   test_csv()
    #else:
     #   print('All files have been downloaded, manually check for any errors')