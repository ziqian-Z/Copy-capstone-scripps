## This script aim to reformat the environmental data from CASE-STSE
## from matrix form where lat and long are coordinates into long form
## where lat lon year month and variable_depth are the column names with corresponding value

library(tidyverse)
library(stringr)

# List files
# path = the directory where files are saved 
# pattern = format of the file name
files <- list.files(path = "~/Desktop/2025 Winter/PSTAT 197B/capstone-scripps/data/Specificdate/Meridional_velocity/meridional_2023", 
                    pattern = "^meridional_velocity_avg_depth_.*\\.csv$", full.names = TRUE)

# Function to change all files to long form
reshape_file <- function(file) {
  # Extract metadata
  meta <- str_match(file, "depth_(-?\\d+\\.?\\d*)_month_(\\d{4})-(\\d{2})")
  depth <- meta[2]  # keep as string to use in column name
  year <- as.integer(meta[3])
  month <- as.integer(meta[4])
  
  # Read and reshape data
  df <- read.csv(file, row.names = 1, check.names = FALSE) %>%
    rownames_to_column(var = "Lon") %>%
    pivot_longer(cols = -Lon, names_to = "Lat", values_to = "meridional_velocity_value") %>%
    mutate(
      Lon = as.numeric(str_remove(Lon, "Lon_")),
      Lat = as.numeric(str_remove(Lat, "Lat_")),
      year = year,
      month = month
    ) %>%
    select(Lon, Lat, year, month, meridional_velocity_value) %>%
    rename(!!paste0("meridional_velocity_depth_", depth) := meridional_velocity_value)

  return(df)
}

# Read and combine all files
combined <- map_dfr(files, reshape_file)


library(dplyr)
# reduce the redundant columns
combined <- combined  %>%
  group_by(Lat, Lon, year, month) %>%
  summarise(across(starts_with("meridional_velocity_depth_"), ~ na.omit(.)[1]), .groups = "drop")

# Set saving directory
setwd("~/Desktop/2025 Winter/PSTAT 197B/capstone-scripps/data/Specificdate/Final_Envi_Data")

# Save as csv
write.csv(combined , "meridional_velocity_avg_reformatted_2023.csv")
