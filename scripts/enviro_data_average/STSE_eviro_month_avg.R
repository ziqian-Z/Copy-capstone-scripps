# This R script is designed to process a series of CSV files containing 
# temperature data recorded at various geographic coordinates (latitude and longitude) 
# and compile this information to calculate monthly average temperatures. 
# Each CSV file represents data from a specific date and contains temperature 
# measurements across different latitudes and longitudes.

## What you need to change is the `data_directory` and the `output_directory`.

library(dplyr)
library(readr)
library(lubridate)
library(stringr)
library(tidyr)

# Define the path to your data directory
data_directory <- "D:/Desktop/PSTAT 197B/scripps/capstone-scripps/data/Specificdate/Temperature"

# Define output directory for the CSV files
# It's better to create a folder called monthly
output_directory <- "D:/Desktop/PSTAT 197B/scripps/capstone-scripps/data/Specificdate/monthlyavefortemp"

if (!dir.exists(output_directory)) {
  dir.create(output_directory, recursive = TRUE)
}

# List all CSV files
file_paths <- list.files(path = data_directory, pattern = "\\.csv$", full.names = TRUE)

# Function to read and process each file
process_file <- function(file_path) {
  data <- read_csv(file_path)
  
  # Extract date and depth from the filename
  date_part <- str_extract(basename(file_path), "\\d{2}-\\w{3}-\\d{4}")
  depth_part <- str_extract(basename(file_path), "-\\d+\\.")
  depth <- as.numeric(str_remove(depth_part, "\\D"))
  date <- dmy(date_part)
  
  # Reshape data assuming the first column is 'Row' which contains longitude, other columns are latitudes
  data_long <- pivot_longer(data, 
                            cols = -Row, 
                            names_to = "Latitude", 
                            values_to = "Temperature")
  
  # Convert the 'Row' column to just a longitude identifier
  data_long$Longitude <- str_remove(data_long$Row, "Lon_")
  data_long$Latitude <- str_remove(data_long$Latitude, "Lat_")
  data_long$Date <- date
  data_long$Depth <- depth
  
  # Ensure columns are correctly typed
  data_long$Longitude <- as.numeric(data_long$Longitude)
  data_long$Latitude <- as.numeric(data_long$Latitude)
  
  # Adjust longitude from 0-360 to -180 to 180 if necessary
  data_long$Longitude <- ifelse(data_long$Longitude > 180, data_long$Longitude - 360, data_long$Longitude)
  
  return(data_long)
}

# Process all files and combine into a single dataframe
all_data <- bind_rows(lapply(file_paths, process_file))

# Calculate monthly averages by location and depth
monthly_averages_by_location_and_depth <- all_data %>%
  group_by(Month = floor_date(Date, "month"), Latitude, Longitude, Depth) %>%
  summarise(Average_Temperature = mean(Temperature, na.rm = TRUE), .groups = 'drop')

# Split data by Month and Depth, then save each as a CSV
split_data <- split(monthly_averages_by_location_and_depth, list(monthly_averages_by_location_and_depth$Month, monthly_averages_by_location_and_depth$Depth))

# Save each month's and depth's data to a separate CSV file
lapply(names(split_data), function(key) {
  month_depth <- str_split(key, "\\.", simplify = TRUE)
  filename <- sprintf("Temperature_%s_depth_%s.csv", month_depth[1], month_depth[2])
  write.csv(split_data[[key]], file.path(output_directory, filename), row.names = FALSE)
})

# Indicate completion
print("All files have been successfully saved.")