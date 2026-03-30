
library(stringr)
#setwd("~/Documents/UCSB/UCSB Dell/Mentoring/scripps-25"). ##Change directory

####All the files that match syntax
files <- list.files("Vertical_desired", pattern = "^Vertical_velocity_depth_.*\\.csv$", full.names = TRUE) #create a datasets folder in the current directory


#####Extract depth and year %month 
depth_month <- data.frame( file = files,
  depth = str_match(files, "depth_([-\\d.]+)")[,2],
  ym = str_match(files, "date_(\\d{4}-\\d{2})")[,2],
  stringsAsFactors = FALSE)

###Now we want to grooup by depth and year/month
library(dplyr)
groups <- depth_month %>% group_by(depth, ym) %>% summarise(file_list = list(file), .groups = "drop")


dir.create("output", showWarnings = FALSE)

 
for (i in seq_len(nrow(groups))) {
  fset <- groups$file_list[[i]]
  depth <- groups$depth[i]
  ym <- groups$ym[i]
  
  ##Extracting lon-lat labels
  first_file <- read.csv(fset[[1]], header = FALSE, check.names = FALSE)
  lat_labels <- as.character(first_file[1, -1])
  lon_labels <- as.character(first_file[-1, 1])
  
  
  
  ########Read and sum all the  matrices
  matrices <- lapply(fset, function(f) {
    m <- read.csv(f, header = FALSE, check.names = FALSE)[-1, -1]
    m <- as.matrix(m)
    storage.mode(m) <- "numeric"
    m
  })
  
  average_mat <- Reduce("+", matrices) / length(matrices)
  rownames(average_mat) <- lon_labels
  colnames(average_mat) <- lat_labels
  
  #write.csv(average_mat, out_file, row.names = TRUE)
  
  ########Save Averge matrix in output folder
  out_file <- sprintf("output/vertical_velocity_avg_depth_%s_month_%s.csv", depth, ym)
  #write.table(average_mat, out_file, sep = ",", col.names = FALSE, row.names = FALSE)
  write.csv(average_mat, out_file, row.names = TRUE)
}
