# Step 7:OLS_MLRRQ1:

library(tidyverse)
library(readr)

# 1. Load Data
# print("loading stage 2 data...")
infile <- "Sheffield_Air_Quality_Engineered_Stage2.csv"
df <- read_csv(infile, show_col_types = FALSE)

# 2. Prepare Data for Model
# We need Barnsley data for this analysis
# Selecting columns manually by name is safer
# Columns: NO2, PM2.5, WS, WD_Card, Temp, Humid, Press
vars_needed <- c("Barnsley_NO2", "Barnsley_PM25", "Barnsley_WS", 
                 "Barnsley_WD_Card", "Barnsley_Temp", 
                 "OM_Barns_relative_humidity_2m", "OM_Barns_surface_pressure")

# Subset data
df_mod <- df[, vars_needed]

# Rename columns to be simple
# (I hate long names)
names(df_mod) <- c("NO2", "PM25", "WindSpeed", "WindDir", "Temp", "Humid", "Press")

# Remove missing values
# Regression cannot run with NA
df_mod <- na.omit(df_mod)

# Make sure WindDir is a factor (category)
df_mod$WindDir <- as.factor(df_mod$WindDir)

# Check data size
print(paste("Data points used:", nrow(df_mod)))


# 3. Model A: NO2
# Formula: NO2 ~ Weather
print("Running NO2 Model...")
fit_no2 <- lm(NO2 ~ WindSpeed + WindDir + Temp + Humid + Press, data = df_mod)

# Save results manually
# get summary
sum_no2 <- summary(fit_no2)
# get coefficients
res_no2 <- as.data.frame(sum_no2$coefficients)

# Add R-squared to the bottom
# Create a row with r2 in first column, NA in others
r2_val <- sum_no2$r.squared
row_r2 <- c(r2_val, NA, NA, NA)

# Bind it to the table
res_no2 <- rbind(res_no2, row_r2)
# Rename the last row
rownames(res_no2)[nrow(res_no2)] <- "R_Squared"

# Write to file
if(!dir.exists("Outputs")) dir.create("Outputs")
write.csv(res_no2, "Outputs/Result_OLS_NO2_Numeric.csv", row.names = TRUE)


# 4. Model B: PM2.5
# Formula: PM2.5 ~ Weather
print("Running PM2.5 Model...")
fit_pm <- lm(PM25 ~ WindSpeed + WindDir + Temp + Humid + Press, data = df_mod)

# Save results
sum_pm <- summary(fit_pm)
res_pm <- as.data.frame(sum_pm$coefficients)

# Add R2
r2_val_pm <- sum_pm$r.squared
row_r2_pm <- c(r2_val_pm, NA, NA, NA)
res_pm <- rbind(res_pm, row_r2_pm)
rownames(res_pm)[nrow(res_pm)] <- "R_Squared"

# Write file
write.csv(res_pm, "Outputs/Result_OLS_PM25_Numeric.csv", row.names = TRUE)

print("Step 7 Regression Done.")