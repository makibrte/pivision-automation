
# Load req'd libraries
library(tidyverse)
library(lubridate)
library(padr)
library(data.table)
library(zoo)
library(readxl)


# Load sample location details
sample_loc_lookup <- read.csv("bldg_to_sampleloc.csv") %>% 
  
  # removes all data without an associated meter
  filter(meter_id != "??",  meter_id != "???",  meter_id != "NM") %>% 
  
  # removes Chemistry1 building, as flow is always equal to zero
  filter(!building %in% c("Chemistry1", "Chemistry2")) #%>% 
# 
# # Data associated with these meters is still missing
# filter(!building %in% c("MSU FCU1", "MSU FCU2"))


fp <- "<REPLACE WITH YOUR PATH HERE>/temp_data_csv/"


sample_locs <- unique(sample_loc_lookup$sample_loc_alpha)

excluded_bldgs <- c(1802:1810, "Engineering Research", paste0("FRIB", 1:8), "Observatory", "Plant Biology Laboratories2", "MSU FCU1", "MSU FCU2")

# Loop through each sample location
for (s in sample_locs){
  
  # Define list of buildings which contribute to each sample location
  bldg_locs <- sample_loc_lookup$building[sample_loc_lookup$sample_loc_alpha %in% s]
  
  
  # Loop through each building
  for (b in bldg_locs) {
    
    # Treats the first building differently (each subsequent building is appended to this data frame)
    if (length(bldg_locs) > 1){
      
      if (b == bldg_locs[1]){
        x <- fread(paste0(fp, 
                          sample_loc_lookup$filename[sample_loc_lookup$building %in% b &
                                                       sample_loc_lookup$sample_loc_alpha == s])) %>% 
          filter(Good == "TRUE") %>% 
          mutate(timestamp = round_date(Timestamp, "min"), # Rounds to minute - second resolution not necessary
                 volume = as.numeric(Value)) %>% 
          arrange(timestamp) %>%
          filter(!duplicated(volume))
        
        if (!b %in% excluded_bldgs){
          x <- x %>% 
            mutate(d_volume = volume - lag(volume, default = volume[1])) %>% 
            filter(d_volume == 1)
        }
        
        x <- x %>% 
          select(timestamp, volume) %>% 
          pad(interval = "min", break_above = 3) %>%
          mutate(volume = 1000 * na.approx(volume)) %>%
          mutate(date = date(timestamp)) %>% 
          group_by(date) %>% 
          summarise(daily_vol = max(volume) - min(volume)) %>% 
          filter(daily_vol < 10^5 & daily_vol > 0)
      } else {
        # Creates data frame for each subsequent building
        y <- fread(paste0(fp, 
                          sample_loc_lookup$filename[sample_loc_lookup$building %in% b &
                                                       sample_loc_lookup$sample_loc_alpha == s])) %>% 
          filter(Good == "TRUE") %>% 
          mutate(timestamp = round_date(Timestamp, "min"), # Rounds to minute - second resolution not necessary
                 volume = as.numeric(Value)) %>% 
          arrange(timestamp) %>%
          filter(!duplicated(volume))
        
        if (!b %in% excluded_bldgs){
          y <- y %>% 
            mutate(d_volume = volume - lag(volume, default = volume[1])) %>% 
            filter(d_volume == 1)
        }
        
        y <- y %>% 
          select(timestamp, volume) %>% 
          pad(interval = "min", break_above = 3) %>%
          mutate(volume = 1000 * na.approx(volume)) %>%
          mutate(date = date(timestamp)) %>% 
          group_by(date) %>% 
          summarise(daily_vol = max(volume) - min(volume)) %>% 
          filter(daily_vol < 10^8 & daily_vol > 0)
        
        # Combine meters as necessary
        x <- merge(x, y, by = "date", all = TRUE) %>% 
          mutate(daily_vol = rowSums(across(starts_with("daily_vol")), na.rm=TRUE)) %>% 
          select(date, daily_vol)
        
        
        
        
        # assign(paste0("msu_", b), y)
        
        rm(y)
      }
    } else {
      x <- fread(paste0(fp, 
                        sample_loc_lookup$filename[sample_loc_lookup$building %in% b &
                                                     sample_loc_lookup$sample_loc_alpha == s])) %>% 
        filter(Good == "TRUE") %>% 
        mutate(timestamp = round_date(Timestamp, "min"), # Rounds to minute - second resolution not necessary
               volume = as.numeric(Value)) %>% 
        arrange(timestamp) %>%
        filter(!duplicated(volume))
      
      if (!b %in% excluded_bldgs){
        x <- x %>% 
          mutate(d_volume = volume - lag(volume, default = volume[1])) %>% 
          filter(d_volume == 1)
      }
      
      x <- x %>%  # Each meter reading should increase the previous reading by 1 (i.e. 1000 gallons between readings)
        select(timestamp, volume) %>% 
        pad(interval = "min", break_above = 3) %>%
        mutate(volume = 1000 * na.approx(volume)) %>%
        select(timestamp, volume) %>% 
        mutate(date = date(timestamp)) %>% 
        group_by(date) %>% 
        summarise(daily_vol = max(volume) - min(volume)) %>% 
        filter(daily_vol < 10^5 & daily_vol > 0)
    }
  }
  assign(paste0("msu_", s), x)
  
  rm(x, b, s, bldg_locs)
  
}


# Clean up ----------------------------------------------------------------


# List dataframes to be combined
df_list <- list(msu_AH, msu_BA, msu_BH, msu_CR, msu_DC, msu_EH, msu_HL, msu_HO, msu_HU, msu_MC, msu_MS, msu_PL, msu_PU, msu_SC, msu_WI, msu_WO, msu_WY)

# Combine all listed dataframes
wm_daily_dat <- df_list %>% 
  reduce(full_join, by='date') %>% 
  `colnames<-`(c("date", "AH", "BA", "BH", "CR", "DC", "EH", "HL", "HO", "HU", "MC", "MS", "PL", "PU", "SC", "WI", "WO", "WY")) %>% 
  
  arrange(date) %>%
  filter(row_number() <= n()-1) # removes last row (which is likely an incomplete day of meter data)


# Remove all unnecessary data
rm(list=ls()[! ls() %in% c("wm_daily_dat")])


write.csv(wm_daily_dat, "./data/Water Meters/ww_dat_with_flow.csv", row.names = FALSE)

