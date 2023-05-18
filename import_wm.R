
library(tidyverse)
library(lubridate)
library(padr)
library(data.table)
library(zoo)

sample_loc_lookup <- read.csv("helper_data/bldg_to_sampleloc.csv")

sample_locs <- unique(sample_loc_lookup$sample_loc_alpha)


for (s in sample_locs){
  bldg_locs <- sample_loc_lookup$building[sample_loc_lookup$sample_loc_alpha %in% s]
  
  if (s %in% c("PU", "PL")){
    for (b in bldg_locs) {
      
      if (length(bldg_locs) > 1){
        
        if (b == bldg_locs[1]){
          x <- fread(paste0("https://raw.githubusercontent.com/makibrte/pivision-automation/master/meters_csv/", 
                            sample_loc_lookup$filename[sample_loc_lookup$building %in% b])) %>% 
            filter(Good == "TRUE") %>% 
            mutate(timestamp = round_date(Timestamp, "min"), # Rounds to minute - second resolution not necessary
                   volume = as.numeric(Value)) %>% 
            arrange(timestamp) %>%
            filter(!duplicated(volume)) %>% 
            select(timestamp, volume) %>% 
            pad(interval = "min", break_above = 3) %>%
            mutate(volume = 1000 * na.approx(volume)) %>%      # Name building
            mutate(date = date(timestamp)) %>% 
            group_by(date) %>% 
            summarise(daily_vol = max(volume) - min(volume)) %>% 
            filter(daily_vol < 10^5 & daily_vol > 0)
        } else {
          y <- fread(paste0("https://raw.githubusercontent.com/makibrte/pivision-automation/master/meters_csv/", 
                            sample_loc_lookup$filename[sample_loc_lookup$building %in% b])) %>% 
            filter(Good == "TRUE") %>% 
            mutate(timestamp = round_date(Timestamp, "min"), # Rounds to minute - second resolution not necessary
                   volume = as.numeric(Value)) %>% 
            arrange(timestamp) %>%
            filter(!duplicated(volume)) %>% 
            select(timestamp, volume) %>% 
            pad(interval = "min", break_above = 3) %>%
            mutate(volume = 1000 * na.approx(volume)) %>%      # Name building
            mutate(date = date(timestamp)) %>% 
            group_by(date) %>% 
            summarise(daily_vol = max(volume) - min(volume)) %>% 
            filter(daily_vol < 10^5 & daily_vol > 0)
          
          # Combine two meters
          x <- merge(x, y, by = "date", all = FALSE) %>% 
            mutate(daily_vol = rowSums(across(starts_with("daily_vol")))) %>% 
            select(date, daily_vol)
          rm(y)
        }
      } else {
        x <- fread(paste0("https://raw.githubusercontent.com/makibrte/pivision-automation/master/meters_csv/", 
                          sample_loc_lookup$filename[sample_loc_lookup$building %in% b])) %>% 
          filter(Good == "TRUE") %>% 
          mutate(timestamp = round_date(Timestamp, "min"), # Rounds to minute - second resolution not necessary
                 volume = as.numeric(Value)) %>% 
          arrange(timestamp) %>%
          filter(!duplicated(volume)) %>% 
          mutate(d_volume = volume - lag(volume, default = volume[1])) %>% 
          filter(d_volume == 1) %>%  # Each meter reading should increase the previous reading by 1 (i.e. 1000 gallons between readings)
          select(timestamp, volume) %>% 
          pad(interval = "min", break_above = 3) %>%
          mutate(volume = 1000 * na.approx(volume)) %>%      # Name building
          select(timestamp, volume) %>% 
          mutate(date = date(timestamp)) %>% 
          group_by(date) %>% 
          summarise(daily_vol = max(volume) - min(volume)) %>% 
          filter(daily_vol < 10^5 & daily_vol > 0)
      }
    }
    
  }else{
    for (b in bldg_locs) {
      
      if (length(bldg_locs) > 1){
        
        if (b == bldg_locs[1]){
          x <- fread(paste0("https://raw.githubusercontent.com/makibrte/pivision-automation/master/meters_csv/", 
                            sample_loc_lookup$filename[sample_loc_lookup$building %in% b])) %>% 
            filter(Good == "TRUE") %>% 
            mutate(timestamp = round_date(Timestamp, "min"), # Rounds to minute - second resolution not necessary
                   volume = as.numeric(Value)) %>% 
            arrange(timestamp) %>%
            filter(!duplicated(volume)) %>% 
            mutate(d_volume = volume - lag(volume, default = volume[1])) %>% 
            filter(d_volume == 1) %>%  # Each meter reading should increase the previous reading by 1 (i.e. 1000 gallons between readings)
            select(timestamp, volume) %>% 
            pad(interval = "min", break_above = 3) %>%
            mutate(volume = 1000 * na.approx(volume)) %>%      # Name building
            select(timestamp, volume) %>% 
            mutate(date = date(timestamp)) %>% 
            group_by(date) %>% 
            summarise(daily_vol = max(volume) - min(volume)) %>% 
            filter(daily_vol < 10^5 & daily_vol > 0)
        } else {
          y <- fread(paste0("https://raw.githubusercontent.com/makibrte/pivision-automation/master/meters_csv/", 
                            sample_loc_lookup$filename[sample_loc_lookup$building %in% b])) %>% 
            filter(Good == "TRUE") %>% 
            mutate(timestamp = round_date(Timestamp, "min"), # Rounds to minute - second resolution not necessary
                   volume = as.numeric(Value)) %>% 
            arrange(timestamp) %>%
            filter(!duplicated(volume)) %>% 
            mutate(d_volume = volume - lag(volume, default = volume[1])) %>% 
            filter(d_volume == 1) %>%  # Each meter reading should increase the previous reading by 1 (i.e. 1000 gallons between readings)
            select(timestamp, volume) %>% 
            pad(interval = "min", break_above = 3) %>%
            mutate(volume = 1000 * na.approx(volume)) %>%      # Name building
            select(timestamp, volume) %>% 
            mutate(date = date(timestamp)) %>% 
            group_by(date) %>% 
            summarise(daily_vol = max(volume) - min(volume)) %>% 
            filter(daily_vol < 10^5 & daily_vol > 0)
          
          # Combine two meters
          x <- merge(x, y, by = "date", all = FALSE) %>% 
            mutate(daily_vol = rowSums(across(starts_with("daily_vol")))) %>% 
            select(date, daily_vol)
          rm(y)
        }
      } else {
        x <- fread(paste0("https://raw.githubusercontent.com/makibrte/pivision-automation/master/meters_csv/", 
                          sample_loc_lookup$filename[sample_loc_lookup$building %in% b])) %>% 
          filter(Good == "TRUE") %>% 
          mutate(timestamp = round_date(Timestamp, "min"), # Rounds to minute - second resolution not necessary
                 volume = as.numeric(Value)) %>% 
          arrange(timestamp) %>%
          filter(!duplicated(volume)) %>% 
          mutate(d_volume = volume - lag(volume, default = volume[1])) %>% 
          filter(d_volume == 1) %>%  # Each meter reading should increase the previous reading by 1 (i.e. 1000 gallons between readings)
          select(timestamp, volume) %>% 
          pad(interval = "min", break_above = 3) %>%
          mutate(volume = 1000 * na.approx(volume)) %>%      # Name building
          select(timestamp, volume) %>% 
          mutate(date = date(timestamp)) %>% 
          group_by(date) %>% 
          summarise(daily_vol = max(volume) - min(volume)) %>% 
          filter(daily_vol < 10^5 & daily_vol > 0)
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
#TODO : Create into a csv file

rm(sample_locs,
   msu_PL, msu_PU, msu_MS, msu_AH, msu_BA, 
   msu_BH, msu_DC, msu_EH, msu_HU, msu_WY, 
   msu_HL, msu_HO, msu_MC, msu_WI, msu_WO)

