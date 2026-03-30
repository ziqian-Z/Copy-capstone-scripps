# Copy-capstone-scripps
This repository contains a sanitized version of a cetacean distribution capstone project implemented with R. It is designed to demonstrate core programming concepts, including data preprocessing, EDA, and model design, without exposing any sensitive or proprietary data.


# capstone-scripps 🐋

<img width="550" alt="Modeling" src="https://github.com/user-attachments/assets/f3eea430-426c-421c-9596-c709648a972c" />

**Sponsor:** Michaela Alksne

**Mentor:** Dr. Baracaldo 

## Overview 📝

Researching the presence of blue and fin whales and their reliance on distinct call types for behaviors (such as foraging and reproduction) is important for monitoring ecosystem health and guiding conservation efforts in the California Current System. By analyzing their calls in relation with environmental data, we can gain insight into their behavioral patterns and habitat use across time.

Several foundational studies guided our research by providing us a solid background understanding on our topic. For example, Becker et al. (2022) studied how different whale species use habitat across the California Current and showed that it's important to use flexible models that can account for changes in space and time. Campbell et al. (2015) showed that there were long-term trends in whale sightings using CalCOFI visual survey data, while Oleson et al. (2007) and Širović et al. (2013) demonstrated that specific whale call types correlate with behavioral states, supporting our decision to model each call type separately.

Therefore, the goal of this project is to develop species distribution models for blue and fin whale acoustic presence using environmental drivers, and to visualize their occurrence across time. We also aim to interpret call-type-specific patterns to better understand behavioral ecology.

**Our final deliverables include:**
1. A species distribution model for blue and fin whales in the Southern California Bight. Combining acoustic call types for each species, we can relate blue and fin whale acoustic presence to environmental drivers. Additional models will be made with call types separated to tease apart nuanced relationships between behavioral state and environmental conditions (ie, could there be a stronger relationship between blue whale D calls (foraging) and zooplankton abundance than with blue whale A/B calls (reproduction) and zooplankton abundance?). One outcome of this analysis will be our interpretation of the summary statistics of each model. Another outcome will be predicted maps of species distribution as a function of environmental conditions. 
2. Conducting data visualization of relationships between the predictor and response variables in the models. These visualizations include the following:
    - Animated maps that overlay whale acoustic presence with environmental variables. The maps should move sequentially through time. There should be one map for every environmental variable, for every call type, and for every cruise, ie: map of fin whale 20Hz call rates overlaid on SST @ -105 m, for 2009-01, 2009-04, 2009-06, 2009-10, 2010-01, 2010-04....2021-10, ect ect. Use the full gridded map of environmental data and the station-by-station call rates for acoustic presence.
    - Histograms/scatter plots/x-y plots of the relationships between call rates and environmental variables, ie, SST @ -105 m on x axis and fin whale 20Hz call rates on y axis.
3. A well documented, organized, and reproducible github repository.

## Directory Structure ✍️

```
/capstone-scripps/
│
├── data/                                        # Main data directory
│   ├── acoustic_data/
│   │   └── monthly                              # Various CalCOFI datasets scaled by effort
│   │   └── calcofi_cleaned_05_12_25             # Cleaned CalCOFI dataset for 05/12/25
│
│   ├── archived_datasets/                       # Archived datasets
|
|   ├── larvae/                                  # Archived datasets
│   │   └── modified_euphasiid.csv               # Modified euphasiid data
│   │   └── modified_larvae                      # Modified larvae data
|
|   ├── Merged_CalCOFI                           # Merged CalCOFI datasets
|   │   └── archived                             # Archived datasets
│   │   └── merged_std_data_05_13_25.csv         # Merged standardized data for CalCOFI on 05/13/25
|
│   ├── Specificdate/                            # Raw + processed CASE-STSE environmental data containing folders for Final_Envi_Data, Meridional_velocity, Pressure, Salinity, Temperature, Vertical_velocity folders, each of which contains folders for desired variable, other, and avg_output
│   │   ├── Final_Envi_data/                    
│   │   ├── Meridional Velocity/         
│   │   ├── Pressure/                  
│   │   ├── Salinity/
│   │   ├── Temperature/
│   │   ├── Zonal_velocity/  
│
├── docs/
|   ├──  20 Hz Report                             # Folder for 20 Hz final report + insights
|   ├──  40 Hz Report                             # Folder for 40 Hz final report + insights
|   ├──  A Call Final Report                      # Folder for A Call final report + insights
|   ├──  B Call Final Report                      # Folder for B Call final report + insights 
|   ├──  D Call Final Report                      # Folder for D Call final report + insights
|   ├──  individual_project_summaries             # Folder for individual project summaries
|   ├──  interim_report                           # Folder for our interim reports
│
│   ├── interim_report/                           # Mid-project report
│   │   ├── figures                               # Figure images
│   │   └── Scripps-interim-report-25.pdf         # Report PDF
│   │   └── Scripps-interim-report-25.rmd         # Report rmd
│   │   └── Scripps-interim-report-25.tex         # Report latex
│
├── results/
|   ├── best_models                               # Folder for our final deliverable (contains all of our best models)
│   ├── visualizations/                           # Folder for Matlab visualizations
│       └── matlab/                               # Animated and static MATLAB outputs on Temperature, Salinity, and Velocity
│           ├── NewData_AnimatedPlots.gif 
│           ├── NewData_AveragedMaps.png
│           ├── drafted_plot.gif
│           └── legend.gif
│       └── whale_call_seasonal_presence_figures/ # Includes blue and whale call type seasonal figures
│
├── scripts/
│   ├── archived_scripts/                         # Old script versions
│
│   ├── data_cleaning/                            # Cleans CalCOFI and CASE-STSE raw files
│   │   └── calcofi_cleaning.R                    # Cleans CalCOFI acoustic and survey data
│   │   └── case_stse_long_form.R                 # Converts CASE-STSE environmental matrices (Lat × Lon) into long-format tables
│   │   └── merged_feature_engineering.R          # Creates magnitude and theta columns for various depths and standardize all predictors
│
│   ├── data_merging/                             # Combines datasets into modeling-ready format
│   │   ├── merging_more_enviro/                  # Contains scripts that combine environmental data + combines dates
│   │   ├── organism/                             # Contains scripts that combine euphasiid data and larvae data
│
│   ├── eda/                                      # Exploratory Data Analysis for Acoustic, CalCoFI, and Ocean Maps
│   │   ├── Acoustic_EDA/                         # EDA for Acoustic Data Files
│   │   ├── CALCOFI_EDA/                          # EDA for CALCOFI Data Files
│
│   ├── enviro_data_average/                      # Scripts for computing monthly CASE-STSE averages across different environmental predictors
│   │   ├── baracaldo_meridional_avg_code.R
│   │   ├── baracaldo_pressure_avg_code.R
│   │   ├── baracaldo_salinity_avg_code.R
│   │   ├── baracaldo_temp_avg_code.R
│   │   ├── baracaldo_vertical_avg_code.R
│   │   ├── baracaldo_zonal_avg_code.R
│   │   └── temperature_average_code.R
│
│   └── modeling/                                  # Modeling scripts for different calls for blue and fin whales
│       ├── 20 hz call
│       ├── 40 hz call
│       ├── a call
│       ├── b call
│       ├── d call
│       ├── fin call
│
├── visualizations/                               # Folder that contains r outputs for gg_anim plots
│
├── .gitignore                                    # Files to exclude from version control
├── LICENSE                                       # Open-source license
├── README.md                                     # Contains information about the github

```

## Set Up Instructions 🔨

1. Clone repository

```
git clone https://github.com/Capstone-24-25/capstone-scripps.git
cd capstone-scripps
```

2. Install the following packages

```
install.packages(c("tidyverse", "sdmTMB", "ggplot2", "readr", "ggcorrplot", "Metrics", "naniar", "tibble", "rsample", "caret", "purrr", "tune", "patchwork"))
```

3. Running the models:

We model acoustic presence using delta-gamma spatiotemporal models in sdmTMB based on the (final preprocessed) STD_CalCOFI_final dataset, structured around different whale call types.

- `a_call.Rmd` – Models A-call presence
- `b_call.Rmd` – Models B-call presence
- `d_call.Rmd` – Models D-call presence
- `20hz_call.Rmd` - Models 20Hz-call presence
- `40hz_call.Rmd` - Models 40Hz-call presence

Each file includes:
- Data loading and preprocessing steps
- Mesh construction and model fitting
- Predictions and evaluation
- Optional interpretation of spatial/spatiotemporal fields

*To run a model: Open the relevant file (ex: `scripts/modeling/b_call.Rmd`) in RStudio and click "Knit" to execute all chunks and generate an output HTML with results.

4. Visualizing Matlab Animations (TBD)

## Reference List 📙

1. Becker, Elizabeth A., Karin A. Forney, David L. Miller, Jay Barlow, Lorenzo Rojas-Bracho, Jorge Urbán R., and Jeff E. Moore. 2022. “Dynamic Habitat Models Reflect Interannual Movement of Cetaceans Within the California Current Ecosystem.” Frontiers in Marine Science 9: Article 829523. https://doi.org/10.3389/fmars.2022.829523.

2. Campbell, Gregory S., Len Thomas, Katherine Whitaker, Annie B. Douglas, John Calambokidis, and John A. Hildebrand. 2015. “Inter-Annual and Seasonal Trends in Cetacean Distribution, Density and Abundance off Southern California.” Deep Sea Research Part II: Topical Studies in Oceanography 112: 143–157. https://doi.org/10.1016/j.dsr2.2014.10.008.

3. Oleson, Erin M., John Calambokidis, William C. Burgess, Mark A. McDonald, Carrie A. LeDuc, and John A. Hildebrand. 2007. “Behavioral Context of Call Production by Eastern North Pacific Blue Whales.” Marine Ecology Progress Series 330: 269–284. https://doi.org/10.3354/meps330269.

4. Širović, Ana, Lauren N. Williams, Sara M. Kerosky, Sean M. Wiggins, and John A. Hildebrand. 2013. “Temporal Separation of Two Fin Whale Call Types across the Eastern North Pacific.” Marine Biology 160: 47–57. https://doi.org/10.1007/s00227-012-2061-z.

5. Thorson, James T., Sean C. Anderson, Pamela Goddard, and Christopher N. Rooper. 2024. tinyVAST: R Package with an Expressive Interface to Specify Lagged and Simultaneous Effects in Multivariate Spatio-Temporal Models. Alaska Fisheries Science Center, National Marine Fisheries Service, NOAA.





