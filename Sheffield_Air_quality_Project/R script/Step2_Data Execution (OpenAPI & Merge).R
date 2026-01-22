library(tidyverse)
library(lubridate)

# 1. Read the raw data
# skip 11 rows because they are just description
# print("Reading Defra raw data")
d0 <- read_csv("Origin_raw_data.csv", skip = 11, col_names = FALSE, show_col_types = FALSE)

# 2. Clean the data
# Keep only useful columns and give them simple names
d1 <- d0 %>%
  select(c(1, 2, seq(3, 31, by = 2))) %>%
  set_names(c(
    "Date", "Time",
    "Ladybower_NO2", "Ladybower_PM25", "Ladybower_WD", "Ladybower_WS", "Ladybower_Temp",
    "Barnsley_NO2", "Barnsley_PM25", "Barnsley_WD", "Barnsley_WS", "Barnsley_Temp",
    "Devonshire_NO2", "Devonshire_PM25", "Devonshire_WD", "Devonshire_WS", "Devonshire_Temp"
  )) %>%
  # Fix time format issue
  # R doesn't like 24:00, so change to 00:00
  mutate(Time = as.character(Time)) %>%
  mutate(
    # check which rows are midnight
    is_mid = Time == "24:00:00",
    # replace 24:00 with 00:00
    Time = if_else(is_mid, "00:00:00", Time),
    # make datetime object (GMT zone)
    DateTime = ymd_hms(paste(Date, Time), tz = "GMT"),
    # add one day if it was 24:00
    DateTime = if_else(is_mid, DateTime + days(1), DateTime),
    # make sure numbers are numbers
    across(3:17, as.numeric)
  ) %>%
  # remove temp columns
  select(DateTime, everything(), -Date, -Time, -is_mid)

# check rows
# print(nrow(d1))


# 3. Get Weather Data (API)
# print("getting weather from open meteo...")

# helper function to download data
get_weather <- function(lat, lon, site_prefix) {
  # build the long url
  base <- "https://archive-api.open-meteo.com/v1/archive?"
  coords <- paste0("latitude=", lat, "&longitude=", lon)
  dates <- "&start_date=2023-01-01&end_date=2025-12-31"
  vars <- "&hourly=relative_humidity_2m,surface_pressure"
  opts <- "&timezone=GMT&format=csv"
  
  full_url <- paste0(base, coords, dates, vars, opts)
  
  # read csv from url
  # skip 3 lines header
  temp <- read_csv(full_url, skip = 3, show_col_types = FALSE, 
                   col_types = cols(time = col_character(), .default = col_double()))
  
  # clean up the downloaded weather data
  temp %>%
    rename(DateTime = time) %>%
    mutate(DateTime = ymd_hm(DateTime, tz = "GMT")) %>%
    # rename cols with prefix so we know which site
    rename_with(~ paste0(site_prefix, .), .cols = -DateTime)
}

# Download for 3 sites
# Ladybower
w1 <- get_weather(53.40337, -1.75200,  "OM_Lady_")
# Barnsley
w2 <- get_weather(53.40495, -1.455815, "OM_Barns_")
# Devonshire
w3 <- get_weather(53.37862, -1.47810,  "OM_Devon_")


# 4. Merge everything together
# print("merging...")

# use left_join to keep original pollution data
d2 <- d1 %>%
  left_join(w1, by = "DateTime") %>%
  left_join(w2, by = "DateTime") %>%
  left_join(w3, by = "DateTime")

# Reorder columns to look nice
# put weather next to pollution for each site
d_final <- d2 %>%
  select(
    DateTime,
    # Ladybower
    starts_with("Ladybower"), starts_with("OM_Lady"),
    # Barnsley
    starts_with("Barnsley"),  starts_with("OM_Barns"),
    # Devonshire
    starts_with("Devonshire"), starts_with("OM_Devon")
  )

# Save result
write_csv(d_final, "Sheffield_Data_Step2_Merged.csv")
print("Step 2 done. File saved.")