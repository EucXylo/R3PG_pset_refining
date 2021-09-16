# EucXylo: Kim Martin and Oluwaseun Gakenou
# 10/08/2021
# R version 4.0.3 (2020-10-10)

# Aim: test r3PG predictions generated using different candidate parameter sets

# This script to match predictions with actual values taken from input file (replace incorrect actual values in prediction files)



# Calculate number of psets

num_psets <- dim(site_predict)[1]/num_pred_per_pset


# Get site measurement dates and predicted variables

check_dates <- as.data.frame(site_predict[c(1:num_pred_per_pset), c('date', 'variable')])

msg <- "Measurement dates don't follow same pattern for all psets"
if (!identical(site_predict$date, rep(check_dates$date, num_psets))) stop(msg)

msg <- "Measurement dates don't have the expected format (yyyy-mm-dd)"
if (!all(substr(as.character(check_dates$date), 5, 5) == '-', substr(as.character(check_dates$date), 8, 8) == '-')) stop(msg)

check_dates$year <- as.integer(substr(as.character(check_dates$date), 1, 4))

check_dates$month <- as.integer(substr(as.character(check_dates$date), 6, 7))



# Create a subset of actual data for this site

site_actuals <- actual_data %>%
  
  filter(Age > 3) %>% 
  
  filter(PlantComp == site_name) %>% 
  
  rename_with(tolower) %>% 
  
  select(year, month, all_of(want_var)) %>% 
  
  pivot_longer(cols = all_of(want_var), names_to = 'variable', values_to = 'values') %>% 
  
  arrange(variable, year, month)



# Sanity-check dates and variable names match expected order

msg <- "Failed to match actual with predicted data"

if (!identical(site_actuals$year, check_dates$year)) stop(msg)

if (!identical(site_actuals$month, check_dates$month)) stop(msg)

if (!identical(site_actuals$variable, check_dates$variable)) stop(msg)



# Overwrite actual data in predictions file with actual data from 'input actual/actual_data.csv'

site_predict$actual <- rep(site_actuals$values, num_psets)

