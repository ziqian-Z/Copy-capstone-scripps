library(readr)


old = read_csv('data/Merged_CalCOFI/STD_CalCOFI_final')
new = read_csv('data/acoustic_data/calcofi_cleaned_05_12_25.csv')


# sort old by the year then month
old = old[order(old$date),]


# comprae old and new ensure lat, lon, stationkey, and season match