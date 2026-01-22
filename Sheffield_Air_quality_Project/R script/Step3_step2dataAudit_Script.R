
# Step 3: Check the Merged Data (Audit)

library(tidyverse)
library(lubridate)

# 1. Load Data
# print("loading step 2 file...")
# read the file we just saved
d0 <- read_csv("Sheffield_Data_Step2_Merged.csv", show_col_types = FALSE)

# 2. Filter Years (2023-2025)
# We only want to analyze actual data.
# 2026 is in the future/empty, so we ignore it for stats
# print("filtering years...")

d_check <- d0 %>%
  filter(year(DateTime) >= 2023 & year(DateTime) <= 2025)

# 3. Simple Count Check
# check how many rows we have
rows <- nrow(d_check)
cols <- ncol(d_check)

print("--- Data Summary (2023-2025) ---")
print(paste("Total Rows:", rows))
print(paste("Total Cols:", cols))


# 4. Range Check (Weather Variables)
# want to check min, max and mean for weather columns to see if they make sense
# picking columns that have "Temp", "WD", "WS", "humidity", "pressure"
# using grep is easier to find them

# find column indexes
# (Weather variables usually start from col 3 onwards, but let's be safe)
# finding names that match our keywords
target_names <- names(d_check)[grepl("Temp|WD|WS|humidity|pressure", names(d_check))]

# exclude precipitation as requested (if exists)
target_names <- target_names[!grepl("precipitation", target_names)]

# Create empty vectors for the table
var_col <- character()
min_col <- numeric()
max_col <- numeric()
mean_col <- numeric()

# Loop through each weather variable
for(v in target_names) {
  vals <- d_check[[v]]
  
  # calculate stats
  v_min <- min(vals, na.rm = TRUE)
  v_max <- max(vals, na.rm = TRUE)
  v_mean <- mean(vals, na.rm = TRUE)
  
  # append to vectors
  var_col <- c(var_col, v)
  min_col <- c(min_col, round(v_min, 2))
  max_col <- c(max_col, round(v_max, 2))
  mean_col <- c(mean_col, round(v_mean, 2))
}

# make dataframe
range_table <- data.frame(
  Variable = var_col,
  Min = min_col,
  Max = max_col,
  Mean = mean_col
)

print("--- Physical Range Check ---")
print(range_table)


# 5. Missing Value Check (For EVERYTHING)
# Checking NAs for all columns
# using loop again because it is clear

all_vars <- names(d_check)
# remove "DateTime" from check
all_vars <- all_vars[all_vars != "DateTime"]

# vectors for result
name_vec <- character()
valid_vec <- numeric()
miss_vec <- numeric()
pct_vec <- numeric()

for(v in all_vars) {
  # get column data
  vals <- d_check[[v]]
  
  # count
  n_miss <- sum(is.na(vals))
  n_valid <- sum(!is.na(vals))
  pct <- (n_miss / rows) * 100
  
  # store
  name_vec <- c(name_vec, v)
  valid_vec <- c(valid_vec, n_valid)
  miss_vec <- c(miss_vec, n_miss)
  pct_vec <- c(pct_vec, round(pct, 2))
}

missing_table <- data.frame(
  Variable = name_vec,
  Valid_N = valid_vec,
  Missing_N = miss_vec,
  Pct_Missing = pct_vec
)

print("--- Missing Data Audit ---")
print(missing_table)

print("Step 3 check finished.")