# Sheffield-Air-Quality-Analysis
Sheffield-Air-Quality-Analysis
#IJC437 air quality 

### 🛠️ Technology Stack & Libraries

The following R libraries were utilized to process data, perform statistical analysis, and generate visualizations.

| Library | Core Functionality | Associated Scripts |
| :--- | :--- | :--- |
| **tidyverse** | **Data IO & Manipulation.** Primarily used `readr` for fast CSV loading and `dplyr` for basic data subsetting and merging. serves as the foundation for all data handling. | Steps 1–8 (All Scripts) |
| **lubridate** | **Time Series Processing.** Essential for parsing Defra's raw timestamps, correcting the "24:00:00" format issue, and extracting temporal features (Year, Month, Season). | Steps 2, 3, 4, 5 |
| **ggplot2** | **Visualization.** Used to create diurnal profile plots, boxplots for spatial comparison, and bar charts for feature importance and coefficient analysis. | Steps 6, 7, 8 |
| **randomForest** | **Machine Learning.** Implementation of the Random Forest algorithm to identify non-linear relationships and "Extreme Event" triggers (RQ2). | Step 8 |
| **gridExtra** | **Plot Arrangement.** A utility tool used to combine multiple plots (e.g., Sensitivity Matrices) into a single grid layout for reporting. | Step 8 |
