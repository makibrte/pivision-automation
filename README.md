# Water Flow Meters Data Automation tool
## About
This script is used to download Water Meter Data from PiVision API and convert it into am appropriate format. 
## Installation

-Clone the repository 

`git clone https://github.com/makibrte/pivision-automation`

-Install all python dependencies 

`pip install -r requirements.txt`

-Install R Packages by running the following in R-Studio 

`install.packages(c("tidyverse", "conflicted", "padr", "zoo"))`

*This is assuming you have installed R and R-Studio 

## Usage
When using the script for the first time, run the following inside terminal:

`python init_data.py`

This will download all the water meter data from start of 2020 until the present day.

### Updating the data(under development)
Once finished instead of running the long init_data.py script you can run weekly_update.py

## Files
### temp_data_csv

Stores the downloaded data to be converted. Each meter has its own csv file. Naming convention for files is 
buildingname_meterID.csv

### .filebrowser.json(depreceated)
Stores configuration for a FileBrowser server. 
### Dockerfile(depreceated)
Docker configuration. 
### bldg_to_sampleloc.csv
Stores the names of meters and buildings needed to be downloaded. 
### helper.py
Helper functions. API calls, name factoris, date string converter etc...
### import_wm.R
R-Script that converts files from temp_data_csv into required format.
### init_data.py
Initial download script. Used for when first time cloning the repository. Downloads data from 2020 untill the day you run the script. Automatically calls the import_wm.R script. 
### requirements.txt
Needed for python dependencies.
### tests.py
Runs tests on download scripts.
### weekly_update.py(In Progress)
Updates the data. Works in a similar way as init_data.py 
