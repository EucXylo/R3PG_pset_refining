# EucXylo: Kim Martin and Oluwaseun Gakenou
# 10/08/2021
# R version 4.0.3 (2020-10-10)

# Aim: test r3PG predictions generated using different candidate parameter sets

# This script to reshape and combine R3PG predictions from all psets for each site



## GET TIMESTAMP FOR OUTPUT FILES (add to RUN file)

tstamp <- format(Sys.time(), '%y%m%d%H%M')



## GET EXPECTED VARIABLES

expect_var <- c('basal_area', 'dbh', 'height', 'volume')

num_var <- length(expect_var)



## IDENTIFY NUMBER OF MEASUREMENTS PER SITE

pred_per_site <- pred_per_site_func(actual_data, num_var)

# data.frame with the following columns: 
# - Site 
# - Pred_per_variable = number of predictions per variable (per site)
# - Pred_per_pset = number of predictions per pset (per site)



## READ IN EACH SITE PREDICTIONS FILE SUCCESSIVELY AND COMBINE VALUES INTO LINEAR MODEL



# Columns to select from each site predictions file:

sel_cols <- c('parameter set', 'site', 'date', 'variable', 'predicted', 'actual') # rename 'parameter set' to 'pset'


for (f in seq_along(p_files[1])) {  # remove [1] to loop through multiple files!
  
  
  
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
  
  # timestamped csv files in 'output site RMSE' folder with the following columns:
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
  
  
  
  
  


  
  
}







## CONVERT PREDICTED AND ACTUAL VALUES TO INTEGERS TO IMPROVE STORAGE EFFICIENCY 

# Convert values to scaled integers (multiply by 1e5 to capture all decimal values)

site_predict$int_pred_e5 <- as.integer(site_predict$predicted * 1e5)

site_predict$int_act_e5 <- as.integer(site_predict$actual * 1e5)


# Remove numeric predicted and actual columns






## RESHAPE PREDICTIONS (PSETS COLUMN-WISE)

# Reshape to one column for each pset

# dt_conn <- lazy_dt(site_predict) # create a data.table connection to use dplyr
# 
# reshaped_pred <- dt_conn %>% 
#   
#   select(pset, site, date, variable, int_act_e5, int_pred_e5) %>% 
#   
#   pivot_wider(names_from = pset,
#               values_from = int_pred_e5) %>%  
#   
#   show_query()  # get native data.table query to run on data.table (see below)

reshaped_pred <- dcast(site_predict[, .(pset, site, date, variable, int_act_e5, int_pred_e5)], 
                       formula = site + date + variable + int_act_e5 ~ pset, value.var = "int_pred_e5")

# data.table with the following columns:
# - 

# NB: reshaped_predict rows are ordered by date, then variable name
# NB: reshaped_predict pset columns are ordered alphabetically (pset1, pset10, pset100, ...)



# Test psets columns are sorted alphabetically in reshaped dt

pset_order  <- sort(paste0('pset', c(1:num_psets)))

msg <- "Pset column order in reshaped data.table does not match expectations."
if (!identical(colnames(reshaped_pred), c('site', 'date', 'variable', 'int_act_e5', pset_order))) stop(msg)



# Test ordering by date and variable gives matching values for 'random' pset

test <- reshaped_pred[, 'pset42']

offset <- (42 - 1) * num_pred_per_pset

cf_pset <- site_predict %>% 
  
  slice((1 + offset):(12 + offset)) %>% 
  
  arrange(date, variable) %>% 
  
  collect()


msg <- "Pset row order in reshaped data.table does not match expectations."
if (!identical(test$pset42, cf_pset$int_pred_e5)) stop(msg)






# Remove original site predictions dt and connection object to free memory

#rm(site_predict)
#rm(dt_conn)


# Save reshaped predictions for this site 

#fwrite(reshaped_pred, paste0('output pset cols/', tstamp, '_', site_name, '_col_pset_pred.csv'))

