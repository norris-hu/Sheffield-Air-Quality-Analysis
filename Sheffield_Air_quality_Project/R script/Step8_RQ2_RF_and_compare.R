# Step 8: Random Forest Analysis & Comparison (RQ2)
#Check different thresholds and compare RF vs OLS


library(tidyverse)
library(readr)
library(randomForest)
library(ggplot2)
library(gridExtra)

# Output folder
out_dir <- "Outputs_RQ2"
if(!dir.exists(out_dir)) dir.create(out_dir)

# 1. Load Data
# print("reading data...")
df <- read_csv("Sheffield_Air_Quality_Engineered_Stage2.csv", show_col_types = FALSE)

# 2. Select Data for Devonshire
# Keeping it simple
df_mod <- df[, c("Devonshire_PM25", "OM_Devon_surface_pressure", 
                 "OM_Devon_relative_humidity_2m", "Devonshire_Temp", 
                 "Devonshire_WS", "Season", "Is_Weekend")]

# Rename columns
names(df_mod) <- c("PM25", "Pressure", "Humidity", "Temp", "WS", "Season", "Is_Weekend")

# Factors
df_mod$Season <- factor(df_mod$Season, levels = c("Spring", "Summer", "Autumn", "Winter"))
df_mod$Is_Weekend <- factor(df_mod$Is_Weekend, labels = c("Weekday", "Weekend"))
df_mod <- na.omit(df_mod)


# 3. Define Thresholds (Manual)
# Calculating values
val_15 <- 15
val_90 <- quantile(df_mod$PM25, 0.90)
val_95 <- quantile(df_mod$PM25, 0.95)
val_25 <- 25

# Put them in a list for looping
threshold_list <- list(
  "A. WHO (>15)"     = val_15,
  "B. High (>P90)"   = val_90,
  "C. Severe (>P95)" = val_95,
  "D. Old (>25)"     = val_25
)


# =======================================================
# PART A: Run RF Models (Loop)
# =======================================================

print("Running RF Loop...")
results_list <- list()
max_gini <- 0

set.seed(123) # consistent result

for(label in names(threshold_list)) {
  
  cut_val <- threshold_list[[label]]
  # print(paste("Processing:", label))
  
  # Prepare data for this run
  d_train <- df_mod
  
  # Create Event column (Binary)
  d_train$Event <- ifelse(d_train$PM25 > cut_val, "Yes", "No")
  d_train$Event <- as.factor(d_train$Event)
  
  # Remove the numeric PM25 column
  # PM25 is column 1
  d_train <- d_train[, -1] 
  
  # Run RF
  rf_model <- randomForest(Event ~ ., data = d_train, ntree = 300, importance = TRUE)
  
  # Extract importance
  imp <- as.data.frame(importance(rf_model))
  imp$Feature <- rownames(imp)
  imp$Gini <- imp$MeanDecreaseGini
  imp$Scenario <- label
  imp$Threshold <- cut_val
  
  # Check max gini for plotting scale later
  if(max(imp$Gini) > max_gini) {
    max_gini <- max(imp$Gini)
  }
  
  # Save to list
  results_list[[label]] <- imp
}

# Add buffer to max_gini
max_gini <- max_gini * 1.1


# Plotting Loop (Manual grid preparation)
# print("Generating grid plots...")
plot_list <- list()
idx <- 1

for(label in names(threshold_list)) {
  data <- results_list[[label]]
  
  # Add color type
  data$Type <- "Physics"
  # Change if Time variable
  # using logic OR
  data$Type[data$Feature == "Season" | data$Feature == "Is_Weekend"] <- "Time"
  
  # Plot
  p <- ggplot(data, aes(x = reorder(Feature, Gini), y = Gini, fill = Type)) +
    geom_col(width = 0.7) +
    coord_flip() +
    # Unified Scale
    scale_y_continuous(limits = c(0, max_gini)) +
    scale_fill_manual(values = c("Physics"="#2c3e50", "Time"="#c0392b")) +
    labs(title = label, 
         subtitle = paste("Threshold >", round(data$Threshold[1], 1)), 
         x="", y="Importance") +
    theme_minimal() + 
    theme(legend.position="none", 
          plot.title = element_text(size=10, face="bold"))
  
  plot_list[[idx]] <- p
  idx <- idx + 1
}

# Save Grid
png("Outputs_RQ2/RQ2_Sensitivity_Matrix.png", width=1000, height=800)
grid.arrange(grobs = plot_list, ncol=2)
dev.off()


# =======================================================
# PART B: Compare OLS vs RF (Manual Logic)
# =======================================================
print("Comparing OLS and RF...")

# 1. Linear Model (OLS)
# Standardize numeric columns using scale()
df_scaled <- df_mod
df_scaled$Pressure <- scale(df_scaled$Pressure)
df_scaled$Humidity <- scale(df_scaled$Humidity)
df_scaled$Temp <- scale(df_scaled$Temp)
df_scaled$WS <- scale(df_scaled$WS)

# Run OLS
lm_fit <- lm(PM25 ~ ., data = df_scaled)
summ <- summary(lm_fit)

# Get coefficients
res_ols <- as.data.frame(summ$coefficients)
# Remove Intercept
res_ols <- res_ols[-1, ]
# We use absolute t-value as importance score
res_ols$Score <- abs(res_ols$`t value`)
res_ols$Feature <- rownames(res_ols)

# Fix feature names
# OLS splits factors (e.g. SeasonSummer, SeasonWinter)
# We need to group them to match RF features
# I will loop through the main variable names
vars <- c("Pressure", "Humidity", "Temp", "WS", "Season", "Is_Weekend")
final_ols <- data.frame(Feature=character(), Score=numeric(), Model=character())

for(v in vars) {
  # find all rows that have this variable name
  # grep returns index
  rows_idx <- grep(v, res_ols$Feature)
  
  if(length(rows_idx) > 0) {
    # get the max score among them (e.g. max of SeasonSummer, SeasonWinter...)
    sub_scores <- res_ols$Score[rows_idx]
    max_s <- max(sub_scores)
    
    # Add to our clean table
    # using rbind
    row_new <- data.frame(Feature=v, Score=max_s, Model="Linear OLS")
    final_ols <- rbind(final_ols, row_new)
  }
}


# 2. Random Forest Importance
# We use the "Severe" (>95%) model as the comparison
# Usually Model C
imp_c <- results_list[["C. Severe (>P95)"]]
rf_imp <- data.frame(
  Feature = imp_c$Feature,
  Score = imp_c$Gini,
  Model = "RF (Extreme)"
)


# 3. Normalize Scores (Manual Calculation)
# Formula: (x - min) / (max - min)

# OLS
min_o <- min(final_ols$Score)
max_o <- max(final_ols$Score)
final_ols$Norm_Score <- (final_ols$Score - min_o) / (max_o - min_o)

# RF
min_r <- min(rf_imp$Score)
max_r <- max(rf_imp$Score)
rf_imp$Norm_Score <- (rf_imp$Score - min_r) / (max_r - min_r)


# 4. Combine and Plot
comp_data <- rbind(final_ols, rf_imp)

p_comp <- ggplot(comp_data, aes(x = reorder(Feature, Norm_Score), y = Norm_Score, fill = Model)) +
  geom_col(position = "dodge", width = 0.7) +
  coord_flip() +
  scale_fill_manual(values = c("#95a5a6", "#2c3e50")) +
  labs(title = "Methodology Comparison",
       subtitle = "Linear Trends (OLS) vs Extreme Triggers (RF)",
       x = "", y = "Normalized Importance") +
  theme_minimal() +
  theme(legend.position = "bottom")

ggsave("Outputs_RQ2/RQ2_OLS_vs_RF_Compare.png", p_comp, width = 8, height = 5)

print("Step 8 Done.")
