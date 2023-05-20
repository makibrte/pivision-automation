from tqdm import tqdm
import os
import numpy as np
import requests
import json
import pandas as pd
from datetime import date
from datetime import datetime
import argparse
from .tests import test_csv
from .helper import filename, get_meterdata, parse_datetime, get_elements, get_element, last_day, json_to_csv, first_day
parser = argparse.ArgumentParser(description='PiVision MSU Water Meter Data Automation-Initial Setup')


parser.add_argument('--tests', type=bool, default=True, help='Should the script print tests, recommended True')
parser.add_argument('--start', type=date, default=date(2020,1,1), help='Determines the starting date for the script')

def main(tests = True, start=date(2020,1,1)):
    #INITIAL REQUEST TO LIST ALL BUILDINGS WITH ASSETS ON PIVISION WEBSITE
    req = get_elements()
    buildings = pd.read_csv('meters/data/helper_data/bldg_to_sampleloc.csv')
    meters = list(buildings['meter_id'])

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
                
                content = []
                

                
                recorded = get_meterdata(item2, today, start_date)
                
                    
                cont = recorded.json()['Items'][0]['Items']
                content += cont
                
                dt_object = parse_datetime(last_day(recorded.json()), format_str)

                # Extract the date from the datetime object
                date_object = dt_object.date()
                
                #Makes requests until it gets latest data
                while(date.today() - date_object).days > 0:
                    
                    
                    recorded = get_meterdata(item2, today, date_object)
                    content += recorded.json()['Items'][0]['Items']
                    dt_object = parse_datetime(last_day(recorded.json()), format_str)
                    
                    date_object = dt_object.date()

                with open(filename(item, item2), 'w') as outfile:
                    json.dump(content , outfile)
    
    json_to_csv()
            


if __name__ == "__main__":
    main()
    #if parser.tests:
     #   test_csv()
    #else:
     #   print('All files have been downloaded, manually check for any errors')