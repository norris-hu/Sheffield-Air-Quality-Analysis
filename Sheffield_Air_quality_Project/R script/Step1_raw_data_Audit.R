# Step 1: Raw Data Audit
library(tidyverse)
library(lubridate)

# 1. Read the data
# The file has 11 lines of header we don't need
print("reading csv file...")
raw_data <- read_csv("Origin_raw_data.csv", skip = 11, col_names = FALSE, show_col_types = FALSE)

# 2. Select columns
# We create a new dataframe df1
# Keep Date(1), Time(2) and then the data columns (odd numbers)
df1 <- raw_data[, c(1, 2, seq(3, 31, by = 2))]

# 3. Rename columns manually
# Site 1: Ladybower (Rural), Site 2: Barnsley (Traffic), Site 3: Devonshire (Urban)
names(df1) <- c(
  "Date", "Time",
  "Lady_NO2", "Lady_PM25", "Lady_WD", "Lady_WS", "Lady_Temp",
  "Barns_NO2", "Barns_PM25", "Barns_WD", "Barns_WS", "Barns_Temp",
  "Devon_NO2", "Devon_PM25", "Devon_WD", "Devon_WS", "Devon_Temp"
)

# 4. Force numeric conversion
# Using loop is better than writing 15 lines
# Columns 3 to 17 are the data
for(i in 3:17){
  df1[[i]] <- as.numeric(df1[[i]])
}

# 5. Build the Audit Table (Manual Way)
# I want to see Missing count, Min, Max, Mean and Negative values for each variable
# Create empty vectors first
var_names <- names(df1)[3:17]
count_total <- numeric(length(var_names))
count_miss <- numeric(length(var_names))
val_min <- numeric(length(var_names))
val_max <- numeric(length(var_names))
val_mean <- numeric(length(var_names))
count_neg <- numeric(length(var_names))

# Loop through each column to calculate stats
# This is like what we did in Week 4 for success rate
print("calculating statistics...")

for(i in 1:length(var_names)) {
  # get the column data (offset by 2 because date/time are col 1-2)
  col_idx <- i + 2
  data_vec <- df1[[col_idx]]
  
  # basic counts
  count_total[i] <- length(data_vec)
  count_miss[i] <- sum(is.na(data_vec))
  
  # stats (must use na.rm=TRUE)
  val_min[i] <- min(data_vec, na.rm = TRUE)
  val_max[i] <- max(data_vec, na.rm = TRUE)
  val_mean[i] <- round(mean(data_vec, na.rm = TRUE), 2)
  
  # logic check for negative values
  # sum TRUE/FALSE gives count
  count_neg[i] <- sum(data_vec < 0, na.rm = TRUE)
}

# 6. Combine into a dataframe
audit_table <- data.frame(
  Variable = var_names,
  Total_N = count_total,
  Missing_N = count_miss,
  Missing_Pct = round((count_miss / count_total) * 100, 1),
  Min = val_min,
  Max = val_max,
  Mean = val_mean,
  Negatives = count_neg
)

# 7. Print the result
print("==================================================")
print("             RAW DATA CHECK REPORT                ")
print("==================================================")
print(audit_table)
print("==================================================")
