How to Run the Code（just follow the step of this pipline ,my project made by diffierents 8 R script）
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
