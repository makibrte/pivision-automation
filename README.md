# PiVision-Automation

## About

A tool used to automate downloading and updating the water flow data from Michigan State University Campus. The main website is built in Django, while the scripts for fetching and processing data are written in Python(fetching) and R(processing). The result of these scripts are stored in a csv file that can be directly downloaded from the website. 

## Installation
### Getting the project files

Simply, clone the repository in directory you want by running:
```bash{cmd}
git clone https://github.com/makibrte/pivision-automation
```


## Running the Django Website(Not Recommended)

One way to run this app is by hosting the Django project yourself. It is not recommended as there are a lot of libraries that need to be installed both for Python and R. 

#### Installation Steps
- Install Python packages when inside root folder
```bash {cmd}
pip install -r requirements.txt
```
- If you have not installed R, install it. Installation depends on OS(In some cases).
  ### Installing R Packages
  
  - ```install.packages(c("tidyverse", "conflicted", "padr", "zoo"))```

## Running the Docker Image(Recommended)

Another way to host this tool is by running a Docker image. This documentation assumes that Docker is already installed. You can either create a Docker Image yourself or you can clone the existing Docker Image from Docker website. 

### 

