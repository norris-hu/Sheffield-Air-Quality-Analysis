How to Run the Code（just follow the step. my project Inlude by diffierents 8 R script）
To reproduce the analysis, please install the required packages (tidyverse, lubridate, randomForest, gridExtra) and run the scripts in the following order:

Step1\_raw\_data\_Audit.R: Performs initial quality check on the raw DEFRA data.
Step2\_Data Execution.R: Fetches OpenMeteo weather data via API and merges it with pollution data.
Step3\_step2dataAudit.R: Audits the merged dataset for missing values.
Step4\_Cleaning.R: Applies QA/QC rules (removing negatives and extreme outliers).
Step5\_Feature\_Engineering.R: Calculates wind sectors, seasonal factors, and urban increments.
Step6\_PM2.5\_NO2\_EDA.R: Generates exploratory visualizations (diurnal profiles and boxplots).
Step7\_RQ1\_OLS.R: Runs the Linear Regression models for RQ1.
Step8\_RQ2\_RF.R: Runs the Random Forest threshold analysis for RQ2.

If you want to run all the scripts, place each dataset in the corresponding file path according to its name.

# Sheffield Air Quality Analysis: Meteorological Drivers of NO₂ and PM₂.₅

📍 Project Overview
This repository contains the source code and data analysis pipeline for the dissertation project **"Quantifying the Impact of Meteorological Factors on NO₂ and PM₂.₅ in Sheffield: A Comparative Analysis Using Linear and Non-Linear Models"** (Module: IJC437).

The study investigates the spatiotemporal variations of air pollutants in Sheffield, UK. It utilizes **Ordinary Least Squares (OLS)** regression as a linear baseline and **Random Forest (RF)** algorithms to analyze driver shifts during extreme pollution episodes.

📊 Key Methodologies
* **Lenschow Urban Increment Framework**: To decompose background vs. local traffic contributions.
* **OLS Multiple Linear Regression**: To quantify baseline meteorological sensitivities.
* **Random Forest (Classification)**: To rank variable importance during high-pollution events (threshold analysis).
📂 Repository Structure

The project follows a reproducible directory structure:

```text
Sheffield-Air-Quality/
│
├── data/                  # Raw and processed datasets
│   ├── Origin_raw_data.csv # Aggregated pollution data (DEFRA)
│   └── Sheffield_Data_Step2_Merged # Meteorological data (Open-Meteo)
│
├── scripts/               # R source codes for analysis
│   ├── Step1_raw_data_Audit.R     
│   ├── Step2_Data Execution (OpenAPI & Merge).R     ots)
│   ├── ..........   # step3 - step 7
│   └──Step8_RQ2_RF_and_compare.R      # Random Forest implementation (RQ2)
│
├── output             # Generated figures and tables
│ 
│  
│
└── README.md              # Project documentation
