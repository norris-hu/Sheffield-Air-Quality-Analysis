# Step 5: Feature Engineering
# Adding season, wind direction categories, and time features

library(tidyverse)
library(lubridate)

# 1. Load Cleaned Data
# print("loading stage 1 data...")
infile <- "Sheffield_Air_Quality_Cleaned_Stage1.csv"

# read data
df <- read_csv(infile, show_col_types = FALSE)

# Clean column names just in case
# Sometimes OpenMeteo adds units like (hPa)
# Removing brackets using gsub (base R)
names(df) <- gsub(" \\(.*\\)", "", names(df))
# remove spaces
names(df) <- trimws(names(df))

# Check names
# print(names(df))

# 2. Add Time Features
# Breaking down DateTime
df$Year <- year(df$DateTime)
df$Month <- month(df$DateTime)
df$Day <- day(df$DateTime)
df$Hour <- hour(df$DateTime)

# Weekend feature
# 1 is Sunday, 7 is Saturday
w <- wday(df$DateTime)
# if w is 1 or 7, it is weekend (1), else 0
df$Is_Weekend <- ifelse(w == 1 | w == 7, 1, 0)


# 3. Add Season
# Doing this manually
df$Season <- "Winter" # set default

# Change for Spring (March, April, May)
spring_months <- c(3, 4, 5)
df$Season[df$Month %in% spring_months] <- "Spring"

# Change for Summer (June, July, August)
summer_months <- c(6, 7, 8)
df$Season[df$Month %in% summer_months] <- "Summer"

# Change for Autumn (Sept, Oct, Nov)
autumn_months <- c(9, 10, 11)
df$Season[df$Month %in% autumn_months] <- "Autumn"

# (Winter is already default, but includes 12, 1, 2)


# 4. Wind Direction Math
# Convert Degree to Radian for Sin/Cos
# Only doing this for Barnsley as it is our main station for model
rad <- df$Barnsley_WD * (pi / 180)
df$Barnsley_WD_Sin <- sin(rad)
df$Barnsley_WD_Cos <- cos(rad)


# 5. Wind Cardinal (N, NE, E...)
# Need text version of wind direction
# I use a simple formula: index = round(degree / 45)
# Directions list
dirs <- c("N", "NE", "E", "SE", "S", "SW", "W", "NW")

# --- Barnsley Wind Card ---
# logic: (deg + 22.5) / 45 floor mod 8
deg_b <- df$Barnsley_WD %% 360
idx_b <- floor((deg_b + 22.5) / 45) %% 8
# R index starts at 1, so +1
df$Barnsley_WD_Card <- dirs[idx_b + 1]

# --- Devonshire Wind Card ---
# copy paste logic
deg_d <- df$Devonshire_WD %% 360
idx_d <- floor((deg_d + 22.5) / 45) %% 8
df$Devonshire_WD_Card <- dirs[idx_d + 1]

# --- Ladybower Wind Card ---
deg_l <- df$Ladybower_WD %% 360
idx_l <- floor((deg_l + 22.5) / 45) %% 8
df$Ladybower_WD_Card <- dirs[idx_l + 1]


# 6. Calculate Increments (Urban - Background)
# Difference between Barnsley (Road) and Devonshire (Urban Back)
df$NO2_Increment <- df$Barnsley_NO2 - df$Devonshire_NO2
df$PM25_Increment <- df$Barnsley_PM25 - df$Devonshire_PM25


# 7. Save Final Master File
outfile <- "Sheffield_Air_Quality_Engineered_Stage2.csv"
write_csv(df, outfile)

print("Step 5 done.")
print(paste("Saved to:", outfile))
print(paste("Total columns:", ncol(df)))