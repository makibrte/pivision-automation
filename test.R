library(conflicted)
library(tidyverse)
library(lubridate)
library(padr)
library(data.table)
library(zoo)

conflicts_prefer(dplyr::filter)
conflicts_prefer(dplyr::lag)

sample_loc_lookup <- read.csv("helper_data/bldg_to_sampleloc.csv")
sample_locs <- unique(sample_loc_lookup$sample_loc_alpha)

volume_daily <- data.frame()
batch_size <- 100000

for (s in sample_locs) {
  bldg_locs <- sample_loc_lookup$building[sample_loc_lookup$sample_loc_alpha %in% s]
  num_batches <- ceiling(length(bldg_locs) / batch_size)

  for (batch in seq_len(num_batches)) {
    start_idx <- (batch - 1) * batch_size + 1
    end_idx <- min(batch * batch_size, length(bldg_locs))
    batch_bldg_locs <- bldg_locs[start_idx:end_idx]

    if (s %in% c("PU", "PL")){
    for (b in bldg_locs) {
      
      if (length(bldg_locs) > 1){
        
        if (b == bldg_locs[1]){
          x <- fread(paste0("meters_csv/", sample_loc_lookup$filename[sample_loc_lookup$building %in% b])) %>% 
            filter(Good == "TRUE") %>% 
            mutate(timestamp = round_date(Timestamp, "min"), # Rounds to minute - second resolution not necessary
                   volume = as.numeric(Value)) %>% 
            arrange(timestamp) %>%
            filter(!duplicated(volume)) %>% 
            select(timestamp, volume) %>% 
            pad(interval = "min") %>%
            mutate(volume = 1000 * na.approx(volume)) %>%      # Name building
            mutate(date = date(timestamp)) %>% 
            group_by(date) %>% 
            summarise(daily_vol = max(volume) - min(volume))
        } else {
          y <- fread(paste0("meters_csv/", sample_loc_lookup$filename[sample_loc_lookup$building %in% b])) %>% 
            filter(Good == "TRUE") %>% 
            mutate(timestamp = round_date(Timestamp, "min"), # Rounds to minute - second resolution not necessary
                   volume = as.numeric(Value)) %>% 
            arrange(timestamp) %>%
            filter(!duplicated(volume)) %>% 
            select(timestamp, volume) %>% 
            pad(interval = "min") %>%
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
        x <- fread(paste0("meters_csv/", sample_loc_lookup$filename[sample_loc_lookup$building %in% b])) %>% 
          filter(Good == "TRUE") %>% 
          mutate(timestamp = round_date(Timestamp, "min"), # Rounds to minute - second resolution not necessary
                 volume = as.numeric(Value)) %>% 
          arrange(timestamp) %>%
          filter(!duplicated(volume)) %>% 
          mutate(d_volume = volume - lag(volume, default = volume[1])) %>% 
          filter(d_volume == 1) %>%  # Each meter reading should increase the previous reading by 1 (i.e. 1000 gallons between readings)
          select(timestamp, volume) %>% 
          pad(interval = "min") %>%
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
          x <- fread(paste0("meters_csv/", sample_loc_lookup$filename[sample_loc_lookup$building %in% b])) %>% 
            filter(Good == "TRUE") %>% 
            mutate(timestamp = round_date(Timestamp, "min"), # Rounds to minute - second resolution not necessary
                   volume = as.numeric(Value)) %>% 
            arrange(timestamp) %>%
            filter(!duplicated(volume)) %>% 
            mutate(d_volume = volume - lag(volume, default = volume[1])) %>% 
            filter(d_volume == 1) %>%  # Each meter reading should increase the previous reading by 1 (i.e. 1000 gallons between readings)
            select(timestamp, volume) %>% 
            pad(interval = "min") %>%
            mutate(volume = 1000 * na.approx(volume)) %>%      # Name building
            select(timestamp, volume) %>% 
            mutate(date = date(timestamp)) %>% 
            group_by(date) %>% 
            summarise(daily_vol = max(volume) - min(volume))
        } else {
          y <- fread(paste0("meters_csv/", sample_loc_lookup$filename[sample_loc_lookup$building %in% b])) %>% 
            filter(Good == "TRUE") %>% 
            mutate(timestamp = round_date(Timestamp, "min"), # Rounds to minute - second resolution not necessary
                   volume = as.numeric(Value)) %>% 
            arrange(timestamp) %>%
            filter(!duplicated(volume)) %>% 
            mutate(d_volume = volume - lag(volume, default = volume[1])) %>% 
            filter(d_volume == 1) %>%  # Each meter reading should increase the previous reading by 1 (i.e. 1000 gallons between readings)
            select(timestamp, volume) %>% 
            pad(interval = "min") %>%
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
        x <- fread(paste0("meters_csv/", sample_loc_lookup$filename[sample_loc_lookup$building %in% b])) %>% 
          filter(Good == "TRUE") %>% 
          mutate(timestamp = round_date(Timestamp, "min"), # Rounds to minute - second resolution not necessary
                 volume = as.numeric(Value)) %>% 
          arrange(timestamp) %>%
          filter(!duplicated(volume)) %>% 
          mutate(d_volume = volume - lag(volume, default = volume[1])) %>% 
          filter(d_volume == 1) %>%  # Each meter reading should increase the previous reading by 1 (i.e. 1000 gallons between readings)
          select(timestamp, volume) %>% 
          pad(interval = "min") %>%
          mutate(volume = 1000 * na.approx(volume)) %>%      # Name building
          select(timestamp, volume) %>% 
          mutate(date = date(timestamp)) %>% 
          group_by(date) %>% 
          summarise(daily_vol = max(volume) - min(volume))
      }
    }
  }

  }
}

if (file.exists("test.csv")) {
  write.table(volume_daily, "test.csv", sep = ",", col.names = FALSE, row.names = FALSE, append = TRUE)
} else {
  write.csv(volume_daily, "test.csv", row.names = FALSE)
}