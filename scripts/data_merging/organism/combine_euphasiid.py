import pandas as pd
import numpy as np

# Load the data files and standardize column names to lowercase
df_combined = pd.read_csv(
    "data/Merged_CalCOFI/Imputed_Data/CalCOFI_merged_2012-2023.csv")
df_combined.columns = df_combined.columns.str.lower()

df_larvae = pd.read_csv("data/larvae/modified_euphasiid.csv")
df_larvae.columns = df_larvae.columns.str.lower()

# Process larvae data: parse full date and extract year and month.
df_larvae['larvae_date'] = pd.to_datetime(df_larvae['date'])
df_larvae['year'] = df_larvae['larvae_date'].dt.year
df_larvae['month'] = df_larvae['larvae_date'].dt.month

# Combined data already has 'year' and 'month' columns.
# Add new columns for larvae count and full larvae date.

print("Combined columns:", df_combined.columns)
print("Larvae columns:", df_larvae.columns)


# print type of df_combined['station'] and df_larvae['station']
print("Type of df_combined['station']:", df_combined['sta'].dtype)
print("Type of df_combined['station']:", df_larvae['station'].dtype)
# convert df_larvae['station'] to float
# some station values might be strings ending with 'E' like 55E, conver them to float
df_larvae['station'] = df_larvae['station'].str.replace('E', '', regex=False)
# if there are any non-numeric values, convert them to NaN
df_larvae['station'] = pd.to_numeric(df_larvae['station'], errors='coerce')
# convert df_combined['station'] to float
df_larvae['station'] = df_larvae['station'].astype(float)

def find_closest_match(row, larvae_df, date_tolerance_days=31):
    # Construct a representative target date from the combined row using day 15.
    target_date = pd.Timestamp(year=int(row['year']), month=int(row['month']), day=15)
    
    # Filter by station: 'station' in larvae should match combined 'sta' within an error of 1.
    subset = larvae_df[abs(larvae_df['station'] - row['sta']) <= 1]
    if subset.empty:
        return None

    # Filter by line with an allowed error of 1.
    subset = subset[abs(subset['line'] - row['line']) <= 1]
    if subset.empty:
        return None

    # Filter by latitude and longitude with an allowed error of 0.1.
    subset = subset[(abs(subset['latitude'] - row['lat']) <= 0.1) & 
                    (abs(subset['longitude'] - row['lon']) <= 0.1)]
    if subset.empty:
        return None

    # Compute the absolute date difference for each candidate
    subset = subset.copy()
    subset['date_diff'] = subset['larvae_date'].apply(lambda d: abs((d - target_date).days))
    
    # Filter candidates that are within the date tolerance
    subset = subset[subset['date_diff'] <= date_tolerance_days]
    if subset.empty:
        return None

    # If multiple candidates remain, use Euclidean distance as a tie-breaker.
    if len(subset) > 1:
        subset['distance'] = ((subset['latitude'] - row['lat'])**2 + 
                              (subset['longitude'] - row['lon'])**2)**0.5
        best_candidate = subset.loc[subset['distance'].idxmin()]
        return best_candidate

    # If there is only one candidate, return it.
    return subset.iloc[0]

# Loop over combined data and update rows with matched larvae data.
for idx, row in df_combined.iterrows():
    match = find_closest_match(row, df_larvae)
    if match is not None:
        df_combined.at[idx, 'euphasia_abundance'] = match['euphausia_total']
        df_combined.at[idx, 'total_abundance'] = match['total_abundance']

# Save the updated dataframe to a new CSV.
df_combined.to_csv("combined_data_with_larvae_euphasiid.csv", index=False)
print("Combined data with larvae count and date has been saved to 'combined_data_with_larvae.csv'.")
# Check the euphasiid columns in the combined data and the emptiness of the new columns
print("Euphasiid columns in combined data:", [col for col in df_combined.columns if 'euphasia' in col or 'abundance' in col])
print("Number of non-empty rows in 'euphasia_abundance':", df_combined['euphasia_abundance'].notna().sum())
print("Number of non-empty rows in 'total_abundance':", df_combined['total_abundance'].notna().sum())
