library(conflicted)
library(tidyverse)
library(lubridate)
library(padr)
library(data.table)
library(zoo)
# library(timetk)
args <- commandArgs(trailingOnly = TRUE)
init_run <- args[1]
conflicts_prefer(dplyr::filter)
conflicts_prefer(dplyr::lag)
#CHNAGE THE PATH WHEN EXPORTED TO SERVER
#script_path <- Sys.getenv("R_SCRIPT")
#script_dir <- dirname(script_path)
#setwd(script_dir)
sample_loc_lookup <- read.csv("meters/data/helper_data/bldg_to_sampleloc.csv")

sample_locs <- unique(sample_loc_lookup$sample_loc_alpha)

csv_path = "meters/data/temp_data_csv/"
for (s in sample_locs){
  bldg_locs <- sample_loc_lookup$building[sample_loc_lookup$sample_loc_alpha %in% s]
  
  
  if (s %in% c("PU", "PL")){
    for (b in bldg_locs) {
      
      if (length(bldg_locs) > 1){
        
        if (b == bldg_locs[1]){
          x <- fread(paste0(csv_path, sample_loc_lookup$filename[sample_loc_lookup$building %in% b])) %>% 
            filter(Good == "TRUE") %>% 
            mutate(timestamp = round_date(Timestamp, "min"), # Rounds to minute - second resolution not necessary
                   volume = as.numeric(Value)) %>% 
            arrange(timestamp) %>%
            filter(!duplicated(volume)) %>% 
            select(timestamp, volume) %>% 
            pad(interval = "min",  break_above = 10) %>%
            mutate(volume = 1000 * na.approx(volume)) %>%      # Name building
            mutate(date = date(timestamp)) %>% 
            group_by(date) %>% 
            summarise(daily_vol = max(volume) - min(volume))
        } else {
          y <- fread(paste0(csv_path, sample_loc_lookup$filename[sample_loc_lookup$building %in% b])) %>% 
            filter(Good == "TRUE") %>% 
            mutate(timestamp = round_date(Timestamp, "min"), # Rounds to minute - second resolution not necessary
                   volume = as.numeric(Value)) %>% 
            arrange(timestamp) %>%
            filter(!duplicated(volume)) %>% 
            select(timestamp, volume) %>% 
            pad(interval = "min",  break_above = 10) %>%
            mutate(volume = 1000 * na.approx(volume)) %>%      # Name building
            mutate(date = date(timestamp)) %>% 
            group_by(date) %>% 
            summarise(daily_vol = max(volume) - min(volume))
          
          # Combine two meters
          x <- merge(x, y, by = "date", all = FALSE) %>% 
            mutate(daily_vol = rowSums(across(starts_with("daily_vol")))) %>% 
            select(date, daily_vol)
          rm(y)
        }
      } else {
        x <- fread(paste0(csv_path, sample_loc_lookup$filename[sample_loc_lookup$building %in% b])) %>% 
          filter(Good == "TRUE") %>% 
          mutate(timestamp = round_date(Timestamp, "min"), # Rounds to minute - second resolution not necessary
                 volume = as.numeric(Value)) %>% 
          arrange(timestamp) %>%
          filter(!duplicated(volume)) %>% 
          mutate(d_volume = volume - lag(volume, default = volume[1])) %>% 
          filter(d_volume == 1) %>%  # Each meter reading should increase the previous reading by 1 (i.e. 1000 gallons between readings)
          select(timestamp, volume) %>% 
          pad(interval = "min",  break_above = 10) %>%
          mutate(volume = 1000 * na.approx(volume)) %>%      # Name building
          select(timestamp, volume) %>% 
          mutate(date = date(timestamp)) %>% 
          group_by(date) %>% 
          summarise(daily_vol = max(volume) - min(volume))
      }
    }
    
  }else{
    for (b in bldg_locs) {
      
      if (length(bldg_locs) > 1){
        
        if (b == bldg_locs[1]){
          x <- fread(paste0(csv_path, sample_loc_lookup$filename[sample_loc_lookup$building %in% b])) %>% 
            filter(Good == "TRUE") %>% 
            mutate(timestamp = round_date(Timestamp, "min"), # Rounds to minute - second resolution not necessary
                   volume = as.numeric(Value)) %>% 
            arrange(timestamp) %>%
            filter(!duplicated(volume)) %>% 
            mutate(d_volume = volume - lag(volume, default = volume[1])) %>% 
            filter(d_volume == 1) %>%  # Each meter reading should increase the previous reading by 1 (i.e. 1000 gallons between readings)
            select(timestamp, volume) %>% 
            pad(interval = "min", break_above = 10) %>%
            mutate(volume = 1000 * na.approx(volume)) %>%      # Name building
            select(timestamp, volume) %>% 
            mutate(date = date(timestamp)) %>% 
            group_by(date) %>% 
            summarise(daily_vol = max(volume) - min(volume))
        } else {
          y <- fread(paste0(csv_path, sample_loc_lookup$filename[sample_loc_lookup$building %in% b])) %>% 
            filter(Good == "TRUE") %>% 
            mutate(timestamp = round_date(Timestamp, "min"), # Rounds to minute - second resolution not necessary
                   volume = as.numeric(Value)) %>% 
            arrange(timestamp) %>%
            filter(!duplicated(volume)) %>% 
            mutate(d_volume = volume - lag(volume, default = volume[1])) %>% 
            filter(d_volume == 1) %>%  # Each meter reading should increase the previous reading by 1 (i.e. 1000 gallons between readings)
            select(timestamp, volume) %>% 
            pad(interval = "min", break_above = 10) %>%
            mutate(volume = 1000 * na.approx(volume)) %>%      # Name building
            select(timestamp, volume) %>% 
            mutate(date = date(timestamp)) %>% 
            group_by(date) %>% 
            summarise(daily_vol = max(volume) - min(volume))
          
          # Combine two meters
          x <- merge(x, y, by = "date", all = FALSE) %>% 
            mutate(daily_vol = rowSums(across(starts_with("daily_vol")))) %>% 
            select(date, daily_vol)
          rm(y)
        }
      } else {
        x <- fread(paste0(csv_path, sample_loc_lookup$filename[sample_loc_lookup$building %in% b])) %>% 
          filter(Good == "TRUE") %>% 
          mutate(timestamp = round_date(Timestamp, "min"), # Rounds to minute - second resolution not necessary
                 volume = as.numeric(Value)) %>% 
          arrange(timestamp) %>%
          filter(!duplicated(volume)) %>% 
          mutate(d_volume = volume - lag(volume, default = volume[1])) %>% 
          filter(d_volume == 1) %>%  # Each meter reading should increase the previous reading by 1 (i.e. 1000 gallons between readings)
          select(timestamp, volume) %>% 
          pad(interval = "min", break_above = 10) %>%
          mutate(volume = 1000 * na.approx(volume)) %>%      # Name building
          select(timestamp, volume) %>% 
          mutate(date = date(timestamp)) %>% 
          group_by(date) %>% 
          summarise(daily_vol = max(volume) - min(volume))
      }
    }
  }
  
  
  
  assign(paste0("msu_", s), x)
  
  rm(x, b, s, bldg_locs)
  
}



# Create single combined data frame
volume_daily <- list(msu_PL, msu_PU, msu_MS, msu_AH, msu_BA, msu_BH, msu_DC, msu_EH, msu_HU, msu_WY, msu_HL, msu_HO, msu_MC, msu_WI, msu_WO) %>% 
  reduce(full_join, by="date") %>% 
  `colnames<-`(c("date", sample_locs)) %>% 
  pivot_longer(col = -date, names_to = "sample_loc", values_to = "vol_daily")


rm(sample_locs,
   msu_PL, msu_PU, msu_MS, msu_AH, msu_BA, 
   msu_BH, msu_DC, msu_EH, msu_HU, msu_WY, 
   msu_HL, msu_HO, msu_MC, msu_WI, msu_WO)
if(args == FALSE){
  write.csv(volume_daily, "meters/data/temp.csv", row.names = FALSE)
}else{
  write.csv(volume_daily, "meters/data/flow_meters.csv", row.names = FALSE)
}