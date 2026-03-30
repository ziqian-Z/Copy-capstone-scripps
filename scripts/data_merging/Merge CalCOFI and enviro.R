library(readr)
library(dplyr)
library(purrr)
library(FNN)  # For fast nearest neighbor search

# Load Data Environmental Data
setwd("~/Desktop/2025 Winter/PSTAT 197B/capstone-scripps/data/Specificdate/Final_Envi_Data")
temp_avg_output_reformat <- read_csv("temp_avg_reformatted_output.csv")
pres_avg_output_reformat <- read_csv("pressure_avg_reformatted_output.csv")
sal_avg_output_reformat <- read_csv("salinity_avg_reformatted_output.csv")
mari_velocity_avg_output_reformat <- read_csv("meridional_velocity_avg_reformatted_output.csv")
zonal_velocity_avg_output_reformat <- read_csv("zonal_velocity_avg_reformatted_output.csv")
verti_velocity_avg_output_reformat <- read_csv("vertical_velocity_avg_reformatted_output.csv")

# Reformat Lat and Lon and Rename column names
temp_avg_output_reformat <- temp_avg_output_reformat %>%
  mutate(lon = ifelse(lon > 180, lon - 360, lon)) %>% 
  rename(temperature_depth_105 = temp_depth_.105.0) %>% 
  rename(temperature_depth_280 = temp_depth_.280.0) %>% 
  rename(temperature_depth_55 = temp_depth_.55.0)

pres_avg_output_reformat <- pres_avg_output_reformat %>%
  mutate(lon = ifelse(lon > 180, lon - 360, lon))%>% 
  rename(pressure_depth_105 = `pressure_depth_.105.0`) %>% 
  rename(pressure_depth_280 = `pressure_depth_.280.0`) %>% 
  rename(pressure_depth_55 = `pressure_depth_.55.0`)

sal_avg_output_reformat <- sal_avg_output_reformat %>%
  mutate(lon = ifelse(lon > 180, lon - 360, lon))%>% 
  rename(salinity_depth_105 = `salinity_depth_.105.0`) %>% 
  rename(salinity_depth_280 = `salinity_depth_.280.0`) %>% 
  rename(salinity_depth_55 = `salinity_depth_.55.0`)

mari_velocity_avg_output_reformat <- mari_velocity_avg_output_reformat %>%
  mutate(lon = ifelse(lon > 180, lon - 360, lon))%>% 
  rename(meridional_velocity_depth_105 = `meridional_velocity_depth_.105.0`) %>% 
  rename(meridional_velocity_depth_280 = `meridional_velocity_depth_.280.0`) %>% 
  rename(meridional_velocity_depth_55 = `meridional_velocity_depth_.55.0`)

verti_velocity_avg_output_reformat <- verti_velocity_avg_output_reformat %>%
  mutate(lon = ifelse(lon > 180, lon - 360, lon))%>% 
  rename(vertical_velocity_depth_105 = `vertical_velocity_depth_.105.0`) %>% 
  rename(vertical_velocity_depth_280 = `vertical_velocity_depth_.280.0`) %>% 
  rename(vertical_velocity_depth_55 = `vertical_velocity_depth_.55.0`)


zonal_velocity_avg_output_reformat <- zonal_velocity_avg_output_reformat %>%
  mutate(lon = ifelse(lon > 180, lon - 360, lon))%>% 
  rename(zonal_velocity_depth_105 = `zonal_velocity_depth_.105.0`) %>% 
  rename(zonal_velocity_depth_280 = `zonal_velocity_depth_.280.0`) %>% 
  rename(zonal_velocity_depth_55 = `zonal_velocity_depth_.55.0`)

# Load CalCoFI data
setwd("~/Desktop/2025 Winter/PSTAT 197B/capstone-scripps/data/acoustic_data")
cal_data <- read_csv("calcofi_cleaned_05_12_25.csv")
cal_data <- cal_data %>% mutate(month = as.numeric(month))
# cal_data_subset <- cal_data %>% 
#   select(-zonal_velocity_depth_55,-zonal_velocity_depth_280,-zonal_velocity_depth_105,
#          -vertical_velocity_depth_55,-vertical_velocity_depth_280, -vertical_velocity_depth_105,
#          -meridional_velocity_depth_55, -meridional_velocity_depth_280, -meridional_velocity_depth_105,
#          -salinity_depth_55, -salinity_depth_280, -salinity_depth_105,
#          -pressure_depth_55, -pressure_depth_280,-pressure_depth_105,
#          -temperature_depth_55, -temperature_depth_280, -temperature_depth_105)

# Define a function to copy the nearest non-NA value from enviro to CalCOFI
copy_by_next_valid_nearest <- function(Envi, CALCOFI, value_columns, k = 10) {
  joined <- CALCOFI %>%
    split(., list(.$year, .$month)) %>%
    imap_dfr(function(CALCOFI_group, key) {
      key_parts <- strsplit(key, "\\.")[[1]]
      year <- as.integer(key_parts[1])
      month <- as.integer(key_parts[2])
      
      # Exclude year and month that are not included
      Envi_group <- Envi %>% filter(year == !!year, month == !!month)
      
      if (nrow(Envi_group) == 0 || nrow(CALCOFI_group) == 0) {
        # Fill with NAs for each value column
        for (col in value_columns) {
          CALCOFI_group[[col]] <- NA
        }
        return(CALCOFI_group)
      } # For safety. In fact there shouldn't have any new NA inserted. 
      
      # Use KNN to locate the nearest data
      nn_idx_list <- get.knnx(
        data = Envi_group[, c("lat", "lon")],
        query = CALCOFI_group[, c("lat", "lon")],
        k = k
      )$nn.index
      
      # get non-NA value
      get_valid_neighbor <- function(row_idx) {
        indices <- nn_idx_list[row_idx, ]
        for (idx in indices) {
          vals <- Envi_group[idx, value_columns]
          if (!all(is.na(vals))) {
            return(as.list(vals))
          }
        }
        return(as.list(setNames(rep(NA, length(value_columns)), value_columns)))
      }
      
      matched_list <- lapply(seq_len(nrow(CALCOFI_group)), get_valid_neighbor)
      matched_df <- bind_rows(matched_list)
      
      CALCOFI_group <- bind_cols(CALCOFI_group, matched_df)
      
      return(CALCOFI_group)
    })
  
  return(joined)
}


# Apply the function

## Environmental Variables
temp_all <- c("temperature_depth_280","temperature_depth_105","temperature_depth_55")
pressure_all <- c("pressure_depth_280","pressure_depth_105","pressure_depth_55")
salinity_all <- c("salinity_depth_280","salinity_depth_105","salinity_depth_55")
meri_v_all<- c("meridional_velocity_depth_280","meridional_velocity_depth_105","meridional_velocity_depth_55")
ver_v_all<- c("vertical_velocity_depth_280","vertical_velocity_depth_105","vertical_velocity_depth_55")
zonal_v_all <- c("zonal_velocity_depth_280","zonal_velocity_depth_105","zonal_velocity_depth_55")

## Environmental lists
temp_list <- list(temp_avg_output_reformat, temp_all)
pressure_list <- list(pres_avg_output_reformat, pressure_all)
salinity_list <- list(sal_avg_output_reformat, salinity_all)
meridional_list <- list(mari_velocity_avg_output_reformat, meri_v_all)
vertical_list <- list(verti_velocity_avg_output_reformat, ver_v_all)
zonal_list <- list(zonal_velocity_avg_output_reformat, zonal_v_all)

## All list
Environ_list <- list(temp_list,
                     pressure_list,
                     salinity_list,
                     meridional_list,
                     vertical_list,
                     zonal_list )

for (var in Environ_list) {
  df <- var[[1]]            # the data frame to copy from
  col_names <- var[[2]]     # the vector of column names
  
  for (col in col_names) {
    Cal_COFI_merge <- copy_by_next_valid_nearest(df, cal_data, col, k = 10)
    cal_data<- Cal_COFI_merge
  }
}


# write into csv file
setwd("~/Desktop/2025 Winter/PSTAT 197B/capstone-scripps/data/Merged_CalCOFI")
write_csv(Cal_COFI_merge, "CalCOFI_merged.csv")
