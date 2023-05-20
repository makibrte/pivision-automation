from tqdm import tqdm
import os
import numpy as nps
import requests
import json
import pandas as pd
from datetime import datetime
from datetime import date
import argparse
from .tests import test_csv
from .helper import filename, get_meterdata, parse_datetime, get_elements, get_element, last_day

parser = argparse.ArgumentParser(description='PiVision MSU Water Meter Data Automation - Weekly Update')

parser.add_argument('--tests', type=bool, default=True, help='Should the script print tests, recommended True')
parser.add_argument('--end_date', type=date, default=date.today(), help='Determines the ending date for the script')
parser.add_argument('--max_count', type=int, default=40000, help='Maximum size for the get request of the data from the API. Experimental use only.')

def main():
    #First request
    req = get_elements()
    buildings = pd.read_csv('../data/helper_data/bldg_to_sampleloc.csv')


    



    format_str = "%Y-%m-%dT%H:%M:%S.%fZ"
    #UPDATES ALL THE JSON FILES 
    meters = list(buildings['meter_id'])
    for item in tqdm(req.json()['Items']):
        req2 = get_element(item['WebId'])
        for item2 in req2.json()['Items']:
            if item2['Name'] in meters:
                
                
                with open(filename(item, item2), 'w') as outfile:
                    
                    existing_data = json.load(outfile)
                    dt_object = parse_datetime(last_day(existing_data), format_str)
                    date_object = dt_object.date()
                    recorded = get_meterdata(item2, parser.end_date, date_object)
                    
                        
                    
                    
                    existing_data = existing_data.update(recorded)
                    
                    json.dump(existing_data , outfile)
                    df = pd.read_json(filename(item, item2))
                    df.to_csv(filename(item, item2))
                        

        
        

if __name__ == "__main__":
    main()    
    if parser.tests:
        test_csv()
    else:
        print('All files have been downloaded, manually check for any errors')  
