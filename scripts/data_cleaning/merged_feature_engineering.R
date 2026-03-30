# Load necessary libraries
library(dplyr)
library(readr)
library(janitor)
library(tidyverse)

# Read in new CalCOFI
cal_data <- read_csv("CalCOFI_merged.csv")

# Create magnitude and theta columns
# Depth 55
cal_data[["magnitude_depth_55"]] <- sqrt(cal_data[["zonal_velocity_depth_55"]]^2 + cal_data[["meridional_velocity_depth_55"]]^2)
cal_data[["theta_depth_55"]] <- atan2(cal_data[["zonal_velocity_depth_55"]], cal_data[["meridional_velocity_depth_55"]])

# Depth 105
cal_data[["magnitude_depth_105"]] <- sqrt(cal_data[["zonal_velocity_depth_105"]]^2 + cal_data[["meridional_velocity_depth_105"]]^2)
cal_data[["theta_depth_105"]] <- atan2(cal_data[["zonal_velocity_depth_105"]], cal_data[["meridional_velocity_depth_105"]])

# Depth 280
cal_data[["magnitude_depth_280"]] <- sqrt(cal_data[["zonal_velocity_depth_280"]]^2 + cal_data[["meridional_velocity_depth_280"]]^2)
cal_data[["theta_depth_280"]] <- atan2(cal_data[["zonal_velocity_depth_280"]], cal_data[["meridional_velocity_depth_280"]])

# Standardize all predictors
cal_data <- cal_data %>% select(-unnamed..0) %>% select(-order_occ)
standardize_cols <- function(df, cols) {
  for (col in cols) {
    if (!is.numeric(df[[col]])) stop(paste("Column", col, "is not numeric."))
    new_col <- paste0(col, "_std")
    df[[new_col]] <- (df[[col]] - mean(df[[col]], na.rm = TRUE)) / sd(df[[col]], na.rm = TRUE)
  }
  return(df)
}


cal_data <- standardize_cols(cal_data, c("est_depth",
                                         "temperature_depth_105","temperature_depth_280","temperature_depth_55",
                                         "salinity_depth_105","salinity_depth_280","salinity_depth_55",
                                         "pressure_depth_105","pressure_depth_280","pressure_depth_55",
                                         "vertical_velocity_depth_105","vertical_velocity_depth_280","vertical_velocity_depth_55",
                                         "meridional_velocity_depth_105","meridional_velocity_depth_280","meridional_velocity_depth_55",
                                         "zonal_velocity_depth_105","zonal_velocity_depth_280","zonal_velocity_depth_55",
                                         "magnitude_depth_105", "magnitude_depth_280", "magnitude_depth_55",
                                         "theta_depth_105", "theta_depth_280", "theta_depth_55"))



cal_data <- add_utm_columns(cal_data, ll_names = c("lon", "lat"))

write.csv(cal_data, "merged_std_data_05_13_25.csv")
