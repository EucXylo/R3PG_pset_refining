# EucXylo: Kim Martin and Oluwaseun Gakenou
# 10/08/2021
# R version 4.0.3 (2020-10-10)

# Aim: test r3PG predictions generated using different candidate parameter sets

# This script to calculate 'extended RMSE' for each pset across all sites (to be used for ranking psets)


## Calculate 'extended-RMSE' combining prediction error and fit error:
#
# Prediction error = difference between actual and R3PG prediction (equivalent to residuals from line with slope 1 
#                    and intercept 0)... see 'all_Sum_SE'
# 
# Fit error = difference between actual (line with slope 1 and intercept 0) and line fit to actual-vs-predictions
#             (calculate using actual values and slope-intercept in 'all_regress_vals')
# 
# Low prediction error => model gives good predictions (predictions are generally close to actual values)
# 
# Low fit error => predictions are not biased (not systematically too-low/too-high, and not underpredicting low/high)
# 
# Combine all residuals (prediction error residuals, fit error residuals) and calculate 'extended-RMSE' as a single 
# metric for comparing psets.



## CALCULATE SUM SE FOR FIT-PREDICTIONS


# Use actual_data to calculate summed squared errors for fit-predicted values from slope-intercept calculated for each pset

source('3a - calculate fit-prediction values from slope-intercept.R')

# 'all_regress_vals' = data.table with the following columns:
# - pset (parameter sets ordered alphabetically by pset = pset1, pset10, pset100, ...)
# - slope 
# - intercept
# - Sum_SE (squared fit-prediction errors summed for each pset, accumulated across all sites)
# - n (number of predictions per pset, accumulated across all sites)



## CALCULATE 'EXTENDED RMSE'

# Square root average Sum_SE from R3PG-predictions and fit-predictions to get 'extended RSME' for each pset across all sites

source('3b - calculate eRMSE for each pset.R')


