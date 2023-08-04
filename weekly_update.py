from tqdm import tqdm
import os
from csv import DictWriter
import csv
import numpy as nps
import requests
import json
import pandas as pd
from datetime import datetime
from datetime import date
import argparse
import subprocess
from tests import test_csv
from helper import filename, get_meterdata, parse_datetime, get_elements, get_element, last_day, remove_json_temp
from helper import parse_datetime_update
parser = argparse.ArgumentParser(description='PiVision MSU Water Meter Data Automation - Weekly Update')

parser.add_argument('--tests', type=bool, default=True, help='Should the script print tests, recommended True')
parser.add_argument('--end_date', type=date, default=date.today(), help='Determines the ending date for the script')
parser.add_argument('--max_count', type=int, default=40000, help='Maximum size for the get request of the data from the API. Experimental use only.')

def main():
    #First request
    
    req = get_elements()
    buildings = pd.read_csv('bldg_to_sampleloc.csv')
    format_str = "%Y-%m-%dT%H:%M:%S.%fZ"
    meters = list(buildings['meter_id'])
    
    #UPDATES ALL THE JSON FILES 
    
    for item in tqdm(req.json()['Items']):
        req2 = get_element(item['WebId'])
        for item2 in req2.json()['Items']:
            if item2['Name'] in meters:
                    content = []
                
                
                
                    with open(filename(item, item2, True).replace('json', ''), 'a') as file_:
                        print(file_)
                        existing_data = pd.read_csv(file_.name)
                        dictwriter_object = DictWriter(file_, fieldnames=existing_data.keys())
                        dt_object = parse_datetime_update(existing_data.iloc[-1]['Timestamp'])
                        date_object = dt_object.date()
                        recorded = get_meterdata(item2, date.today(), date_object)
                        cont = recorded.json()['Items'][0]['Items']
                        content += cont
                        
                        dt_object = parse_datetime(last_day(recorded.json()), format_str)
                        if dt_object:
                            date_object = dt_object.date()
                            while(date.today() - date_object).days > 0:
                                recorded = get_meterdata(item2, date.today(), date_object)
                                
                                content += recorded.json()['Items'][0]['Items']
                                dt_object = parse_datetime(last_day(recorded.json()), format_str)
                            

                            #df = pd.read_json(filename(item, item2))
                            dictwriter_object.writerows(content)
                        file_.close()
                        
    
    dir_path = os.path.dirname(os.path.realpath(__file__)) # get the directory of the current Python script
    r_script_path = os.path.join(dir_path, 'import_wm_automated.R') # build the full path to the R script

    #command = "Rscript"
    #path2script = r_script_path
    #TODO: Change later to False when script is updated to handle better updating data.
    #subprocess.call([command, path2script, "TRUE"])
        

if __name__ == "__main__":
    
    main()

    #if parser.tests:
    #    test_csv()
    #else:
    #    print('All files have been downloaded, manually check for any errors')  
