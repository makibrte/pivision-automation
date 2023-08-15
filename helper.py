import requests
from datetime import datetime
from datetime import date
import os, shutil 
import pandas as pd
import decimal

def parse_datetime_update(time_string):
    
    try:
        return datetime.strptime(time_string, "%Y-%m-%dT%H:%M:%S.%fZ")
    except ValueError:
        pass 

    
    try:
        dt = datetime.strptime(time_string, "%Y-%m-%d %H:%M:%S.%f%z")
        return dt.astimezone(datetime.timezone.utc)  
    except ValueError:
        pass  

    
    print(f"Unexpected format: {time_string}")
    return None 


def filename(item, item2, csv = False):
    item['Name'] = item['Name'].replace('.', '')
    
    return  'temp_data_csv/{}_{}.csv'.format("_".join(item['Name'].replace("/", " ").split(' ')).lower(), item2['Name'].replace('.', ''))
    
    
def get_meterdata(data, end_date, start_date):
    days = (end_date - start_date).days
    return requests.get('https://osi.ipf.msu.edu/piwebapi/streamsets/{}/recorded?StartTime=*-{}d&EndTime=*-0d&MaxCount=40000'.format(data['WebId'], days))

def parse_datetime(datetime_str, format_str):
        """
            Parses the datetime from json response so it can be used to calculate the day difference between two dates 
            
            Paramaters:
                datetime_str (str) : Timestamp string from the json response by pyvision API
                format_str (str) : Method used to format the string

            Returns:
                dt_object (datetime.date) : Correct dtype for the date 
        """
        
        format_with_fraction = "%Y-%m-%dT%H:%M:%S.%fZ"
        format_without_fraction = "%Y-%m-%dT%H:%M:%SZ"

        try:
            fractional_start = datetime_str.index('.') + 1
            fractional_end = datetime_str.index('Z')
        except ValueError:
            # The timestamp doesn't have a fractional part
            dt_object = datetime.strptime(datetime_str, format_without_fraction)
        else:
            fractional_part = datetime_str[fractional_start:fractional_end]

            # Truncate or pad the fractional part to fit exactly six digits
            adjusted_fractional_part = (fractional_part[:6] + '000000')[:6]

            # Replace the original fractional part with the adjusted one
            adjusted_datetime_str = datetime_str[:fractional_start] + adjusted_fractional_part + datetime_str[fractional_end:]

            dt_object = datetime.strptime(adjusted_datetime_str, format_with_fraction)

        return dt_object





def get_elements():
    return requests.get('https://osi.ipf.msu.edu/piwebapi/assetdatabases/F1RDxYSRoDn9-066ETsCvigyBwjEBIyuXKmUGi-Jb82kTJRwSVBGLVBQSElTVERBVEFcQ0FMQ19URVNU/elements')

def get_element(id):
    return requests.get('https://osi.ipf.msu.edu/piwebapi/elements/{}/elements'.format(id))

def last_day(data):
     try:
        return data['Items'][0]['Items'][-1]['Timestamp']
     except:
         return None

def first_day(data):
    return data['Items'][0]['Items'][-1]['Timestamp']

def json_to_csv(dir = 'temp_data_jsn'):
    json_dir = os.listdir(dir)
    for json_file in json_dir:
        
        json_data = pd.read_json('temp_data_jsn/' + json_file)
        json_data.to_csv('temp_data_csv/{}.csv'.format(json_file.split('.')[0]))

def remove_json_temp(folders = ['temp_data_jsn']):
    for folder in folders:
        for filename in os.listdir(folder):
            file_path = os.path.join(folder, filename)
            try:
                if os.path.isfile(file_path) or os.path.islink(file_path):
                    os.unlink(file_path)
                elif os.path.isdir(file_path):
                    shutil.rmtree(file_path)
            except Exception as e:
                print('Failed to delete %s. Reason: %s' % (file_path, e))

