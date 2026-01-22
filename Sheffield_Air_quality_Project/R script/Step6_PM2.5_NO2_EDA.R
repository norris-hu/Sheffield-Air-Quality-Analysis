
# Step 6: Analysis and Plots (EDA)

library(tidyverse)
library(lubridate)
library(ggplot2) 

# 1. Read the engineered data
# print("reading step 2 file...")
infile <- "Sheffield_Air_Quality_Engineered_Stage2.csv"
df <- read_csv(infile, show_col_types = FALSE)

# check output folder
if(!dir.exists("Outputs")) {
  dir.create("Outputs")
}

# PART 1: NO2 Analysis (Weekday vs Weekend)

# 1. Prepare Data
# Filter data (remove missing NO2 increment)
d_no2 <- subset(df, !is.na(NO2_Increment))

# Add Day Type column manually
# 0 is Weekday, 1 is Weekend
d_no2$Day_Type <- ifelse(d_no2$Is_Weekend == 1, "Weekend", "Weekday")

# T-test to compare means
print("--- T-Test: NO2 Increment (Weekend vs Weekday) ---")
print(t.test(NO2_Increment ~ Day_Type, data = d_no2))


# 2. Summarise Data for Plotting
# We need mean NO2 for each hour
# Using group_by just for this part because ggplot needs it
plot_data <- d_no2 %>%
  group_by(Day_Type, Hour) %>%
  summarise(
    Mean_NO2 = mean(NO2_Increment, na.rm = TRUE),
    # Calculate Standard Error for the ribbon
    SE_NO2 = sd(NO2_Increment, na.rm = TRUE) / sqrt(n()),
    .groups = "drop"
  )

# 3. Plotting with ggplot2
print("Plotting NO2 diurnal profile...")

p1 <- ggplot(plot_data, aes(x = Hour, y = Mean_NO2, fill = Day_Type)) +
  # Add the confidence interval ribbon
  geom_ribbon(aes(ymin = Mean_NO2 - 1.96*SE_NO2, ymax = Mean_NO2 + 1.96*SE_NO2), alpha = 0.3) +
  # Add the main lines
  geom_line(aes(color = Day_Type), size = 1) +
  # Add a reference line at 0
  geom_hline(yintercept = 0, linetype = "dashed") +
  # Labels
  labs(title = "NO2 Patterns: Weekday vs Weekend",
       y = "NO2 Increment (ug/m3)",
       x = "Hour of Day") +
  # Simple theme
  theme_bw()

# Save
ggsave("Outputs/EDA_NO2_Diurnal.png", plot = p1, width = 8, height = 6)


# PART 2: PM2.5 Analysis (Urban vs Rural)

# 1. Prepare Data
# Filter for 2025 and Westerly winds (W, NW, SW)
d_pm <- subset(df, Year == 2025)
# Manual OR logic
d_pm <- subset(d_pm, Barnsley_WD_Card == "W" | Barnsley_WD_Card == "NW" | Barnsley_WD_Card == "SW")

# Remove NA
d_pm <- subset(d_pm, !is.na(Devonshire_PM25) & !is.na(Ladybower_PM25))

# Check if data exists
if(nrow(d_pm) > 0) {
  
  print("--- Paired T-Test: PM2.5 (Urban vs Rural) ---")
  print(t.test(d_pm$Devonshire_PM25, d_pm$Ladybower_PM25, paired = TRUE))
  
  # 2. Reshape for ggplot
  # ggplot likes "long" format for boxplots
  # pivot_longer is standard tidyverse
  d_pm_long <- d_pm %>%
    select(Devonshire_PM25, Ladybower_PM25) %>%
    pivot_longer(cols = everything(), names_to = "Site", values_to = "PM25")
  
  # Rename the sites to look nice
  d_pm_long$Site[d_pm_long$Site == "Devonshire_PM25"] <- "Urban (Devonshire)"
  d_pm_long$Site[d_pm_long$Site == "Ladybower_PM25"] <- "Rural (Ladybower)"
  
  # 3. Plotting
  print("Plotting PM2.5 boxplot...")
  
  p2 <- ggplot(d_pm_long, aes(x = Site, y = PM25, fill = Site)) +
    # Boxplot
    geom_boxplot(alpha = 0.6) +
    # Add mean point (diamond shape)
    stat_summary(fun = mean, geom = "point", shape = 18, size = 3, color = "black") +
    # Labels
    labs(title = "PM2.5: Urban vs Rural (2025 Westerly Winds)",
         y = "Concentration (ug/m3)") +
    theme_bw() +
    theme(legend.position = "none") # hide legend because x-axis is enough
  
  # Save
  ggsave("Outputs/EDA_PM25_Spatial.png", plot = p2, width = 6, height = 6)
  
} else {
  print("Warning: Not enough data for PM2.5 analysis")
}

print("Step 6 Done.")