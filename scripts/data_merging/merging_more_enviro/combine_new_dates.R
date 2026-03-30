## This file aim to combine more environmental data from future dates 
## to current environmental file.
## Files are in long form.

library(readr)

setwd("~/Desktop/2025 Winter/PSTAT 197B/capstone-scripps/data/Specificdate/Final_Envi_Data")
# read the additional data
z_2023 <- read.csv("meridional_velocity_avg_reformatted_2023.csv")
# read original data
z <- read.csv("meridional_velocity_avg_reformatted_output.csv")


z <- z %>% filter(!(year == 2023))

library(dplyr)
# remove redundant columns and rename the colname to match
z_2023<-z_2023 %>% select(-X) %>% rename(lat = Lat) %>% rename(lon = Lon)
# combine two files
combined <- bind_rows(z_2023, z)
# save as csv
write.csv(combined, "meridional_velocity_avg_reformatted_output.csv")
