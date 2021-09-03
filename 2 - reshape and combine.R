# EucXylo: Kim Martin and Oluwaseun Gakenou
# 10/08/2021
# R version 4.0.3 (2020-10-10)

# Aim: test r3PG predictions generated using different candidate parameter sets

# This script to reshape and combine R3PG predictions from all psets for each site




## GET EXPECTED VARIABLES

expect_var <- c('basal_area', 'dbh', 'height', 'volume')

num_var <- length(expect_var)



## IDENTIFY NUMBER OF MEASUREMENTS PER SITE

pred_per_site <- pred_per_site_func(actual_data, num_var)

# data.frame with the following columns: 
# - Site = site name, ordered alphabetically
# - Pred_per_variable = number of predictions per variable (per site)
# - Pred_per_pset = number of predictions per pset (all variables, per site)



## READ IN EACH SITE PREDICTIONS FILE SUCCESSIVELY AND COMBINE VALUES INTO LINEAR MODEL



# Columns to select from each site predictions file:

sel_cols <- c('parameter set', 'site', 'date', 'variable', 'predicted', 'actual') # rename 'parameter set' to 'pset'


for (f in seq_along(p_files[1:5])) {    ### NB: remove [1] to loop through multiple files!
  
  
  message(paste("Processing", p_files[f]))
  
  
  # Read in one site predictions file at a time (exclude 'volume' predictions)
  
  source('2a - read in site predictions.R')
  
  # 'site_predict' = data.table with the following columns:
  # - pset (parameter sets ordered by pset #... numerical not alphabetical)
  # - site (only one site name)
  # - date (all dates where the trees were > 3yrs old)
  # - variable (order matches 'expect_var', excluding 'volume')
  # - predicted
  # - actual
  
  
  
  # Calculate squared error for all individual predictions in this site (combine later for RMSE calculations)

  site_predict$squared_error <- (site_predict$actual - site_predict$predicted)^2
  
  site_predict$squared_error <- signif(site_predict$squared_error, 7)  # predicted, actual values have 7 sig figs
  

  
  # Calculate RMSE for each pset (combined variables) and for each variable in each pset
  
  source('2b - calc RMSE for each site.R')
  
  # timestamped csv files saved in 'output site RMSE' folder with the following columns:
  # - pset (parameter sets ordered alphabetically by pset = pset1, pset10, pset100, ...)
  # - site (only one site name)
  # - RMSE_all_var
  # - RMSE_basal_area
  # - RMSE_dbh
  # - RMSE_height
  #
  # AND 'pset_Sum_SE' = data.table with the following columns:
  # - pset (parameter sets ordered alphabetically by pset = pset1, pset10, pset100, ...)
  # - Sum_SE (squared prediction errors summed for each pset)
  # - n (number of predictions per pset... use to calculate 'all sites' RMSE)
  
  
  
  # Combine Sum_SE for all sites (per pset) and also combine number of predictions per pset (from each site)
  
  source('2c - sum squared errors across all sites.R')
  
  # 'all_Sum_SE' = data.table with the following columns:
  # - pset (parameter sets ordered alphabetically by pset = pset1, pset10, pset100, ...)
  # - Sum_SE (squared prediction errors summed for each pset, accumulating across all sites)
  # - n (number of predictions per pset, accumulating across all sites)
  
  
  
  # Convert values to scaled integers for efficiency (multiply by 1e5 to capture all decimal values)
  
  #site_predict$int_pred_e5 <- as.integer(site_predict$predicted * 1e5)
  
  #site_predict$int_act_e5 <- as.integer(site_predict$actual * 1e5)

  
  

  

  
  # Get 'components' to calculate slopes and intercepts for each pset (use scaled integers)

  
  
  # 'regress_vals' = data.table with the following columns:
  # - sum_x
  # - sum_y
  # - sum_xy
  # - sum_x2
  # - n
  
  
  
  
}


# Calculate slope and intercept for each pset across all sites


# slope = ((bar-x * bar-y) - bar-xy) / ((bar-x)^2 - bar-x2)

# intercept = bar-y - (slope * bar-x)




# Calculate Sum_SE between actual and fit-predicted values



# Square root accumulated Sum_SE to get (extended) RSME for each pset across all sites













# Remove original site predictions dt and connection object to free memory

#rm(site_predict)
#rm(dt_conn)




