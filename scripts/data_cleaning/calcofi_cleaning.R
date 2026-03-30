# Load necessary libraries
library(dplyr)
library(readr)
library(janitor)
library(tidyverse)

# Read in new CalCOFI
cal_data <- read_csv("calcofi_all_concatenated.csv")

# Scale the response variables
cal_data <- cal_data %>% 
  clean_names() %>% 
  mutate(
    a_scaled = a/duration_hrs,
    b_scaled = b/duration_hrs,
    d_scaled = d/duration_hrs,
    x20hz_scaled = x20hz/duration_hrs,
    x40hz_scaled = x40hz/duration_hrs,
  ) %>% 
  select(-c(x20hz, a, b, d, x40hz, station_key_2))

# Create a year and month column
cal_data <- cal_data %>%
  separate(yymm, into = c("year", "month"), sep = "_") %>%
  mutate(
    year = as.integer(year),
    month = as.integer(month)
  )

# Create season variable
cal_data <- cal_data %>%
  mutate(
    season_decimal = case_when(
      month %in% c(12, 1, 2)  ~ 0.00,  # Winter
      month %in% c(3, 4, 5)   ~ 0.25,  # Spring
      month %in% c(6, 7, 8)   ~ 0.50,  # Summer
      month %in% c(9, 10, 11) ~ 0.75,
    ),
    
    # Combine into final "YYYY.DD" format
    season = year + season_decimal
  )

write.csv(cal_data, "calcofi_cleaned_05_12_25.csv")