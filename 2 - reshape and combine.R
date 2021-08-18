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
  
  
  # Read in one site predictions file at a time - drop unwanted variables (defined above)
  
  source('2a - read in site predictions.R')
  
  # data.table with the following columns:
  # - pset (parameter sets ordered by pset #... numerical not alphabetical)
  # - site (only one site name)
  # - date (all dates where the trees were > 3yrs old)
  # - variable (order matches 'expect_var', excluding 'volume')
  # - predicted
  # - actual
  
  
  
  

  
  
  


  
  
}




## CALCULATE SQUARED-ERROR FOR THIS SITE FOR ALL PSETS (COMBINE LATER TO CALCULATE RMSE FOR ALL PSETS)

# Calculate squared error for all predictions

site_predict$squared_error <- (site_predict$actual - site_predict$predicted)^2




## CALCULATE RMSE FOR EACH PSET (ALL VARIABLES), AND FOR EACH VARIABLE IN EACH PSET

# Calculate RMSE for all predictions per pset

dt_conn <- lazy_dt(site_predict) # create a data.table connection to use dplyr

pset_RMSE <- dt_conn %>%

  select(-predicted, -actual) %>%

  group_by(pset) %>%

  summarise(n = n(), Sum_SE = sum(squared_error)) %>%

  mutate(RMSE = sqrt(Sum_SE / n)) %>%

  mutate(site = site_name) %>%

  mutate(variable = 'all') %>% 
  
  select(pset, site, variable, RMSE) %>% 
  
  collect()


# Calculate RMSE for all predictions per variable per pset

dt_conn <- lazy_dt(site_predict) # create a data.table connection to use dplyr

var_RMSE <- dt_conn %>% 
  
  select(-predicted, -actual) %>% 
  
  group_by(pset, variable) %>%
  
  summarise(n = n(), Sum_SE = sum(squared_error)) %>% 
  
  mutate(RMSE = sqrt(Sum_SE / n)) %>% 
  
  mutate(site = site_name) %>% 
  
  select(pset, site, variable, RMSE) %>% 
  
  collect()


# Combine pset and variable-pset RMSE calculations and pivot wider

pset_RMSE <- rbind(pset_RMSE, var_RMSE)

pset_RMSE <- pset_RMSE %>% 
  
  pivot_wider(names_from = c(variable, site), values_from = RMSE)


# Write RMSE values to file and remove objects

fwrite()

rm(var_RMSE)




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

