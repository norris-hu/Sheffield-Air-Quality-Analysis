# Step 4: Cleaning Data
# Purpose: Remove bad values (negatives, too high) and specific errors

library(tidyverse)
library(lubridate)

# 1. Load merged data
# print("loading step 2 data...")
file_in <- "Sheffield_Data_Step2_Merged.csv"
file_out <- "Sheffield_Air_Quality_Cleaned_Stage1.csv"

# read data
df <- read_csv(file_in, show_col_types = FALSE)

# Fix timezone first
# force to UTC to avoid daylight saving problems
df$DateTime <- as.POSIXct(df$DateTime, tz = "UTC")

# sort by time just in case
df <- df %>% arrange(DateTime)


# 2. Physics Check (Remove Impossible Values)
# Pollution cannot be negative.
# Also > 1000 is probably error.
# Wind speed > 50 is hurricane, impossible in Sheffield.
# Temp > 45 is too hot.

# print("cleaning pollution data...")

# --- Ladybower ---
# NO2
df$Ladybower_NO2[df$Ladybower_NO2 < 0] <- NA
df$Ladybower_NO2[df$Ladybower_NO2 > 1000] <- NA
# PM2.5
df$Ladybower_PM25[df$Ladybower_PM25 < 0] <- NA
df$Ladybower_PM25[df$Ladybower_PM25 > 1000] <- NA

# --- Barnsley ---
# NO2
df$Barnsley_NO2[df$Barnsley_NO2 < 0] <- NA
df$Barnsley_NO2[df$Barnsley_NO2 > 1000] <- NA
# PM2.5
df$Barnsley_PM25[df$Barnsley_PM25 < 0] <- NA
df$Barnsley_PM25[df$Barnsley_PM25 > 1000] <- NA

# --- Devonshire ---
# NO2
df$Devonshire_NO2[df$Devonshire_NO2 < 0] <- NA
df$Devonshire_NO2[df$Devonshire_NO2 > 1000] <- NA
# PM2.5
df$Devonshire_PM25[df$Devonshire_PM25 < 0] <- NA
df$Devonshire_PM25[df$Devonshire_PM25 > 1000] <- NA


# print("cleaning weather data...")

# Wind Speed (max 50)
df$Ladybower_WS[df$Ladybower_WS < 0] <- NA
df$Ladybower_WS[df$Ladybower_WS > 50] <- NA

df$Barnsley_WS[df$Barnsley_WS < 0] <- NA
df$Barnsley_WS[df$Barnsley_WS > 50] <- NA

df$Devonshire_WS[df$Devonshire_WS < 0] <- NA
df$Devonshire_WS[df$Devonshire_WS > 50] <- NA

# Temperature (max 45)
df$Ladybower_Temp[df$Ladybower_Temp > 45] <- NA
df$Barnsley_Temp[df$Barnsley_Temp > 45] <- NA
df$Devonshire_Temp[df$Devonshire_Temp > 45] <- NA


# 3. Special Masking (Stop Loss)
# Some sensors were broken or maintenance
# print("applying special filters...")

# extract year and month to check
y <- year(df$DateTime)
m <- month(df$DateTime)

# Case A: Ladybower PM2.5 is bad in 2023
# set to NA if year is 2023
# using vector indexing
idx_lady <- which(y == 2023)
df$Ladybower_PM25[idx_lady] <- NA

# Case B: Devonshire NO2 bad in Spring 2024
# maintenance happened in month 3, 4, 5
# need check both year and month
idx_devon <- which(y == 2024 & (m == 3 | m == 4 | m == 5))
df$Devonshire_NO2[idx_devon] <- NA


# 4. Save clean file
# check rows number
# print(paste("Final rows:", nrow(df)))

write_csv(df, file_out)
print("Step 4 cleaning done. Saved Stage 1 file.")