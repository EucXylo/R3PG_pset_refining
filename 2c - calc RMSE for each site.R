# EucXylo: Kim Martin and Oluwaseun Gakenou
# 10/08/2021
# R version 4.0.3 (2020-10-10)

# Aim: test r3PG predictions generated using different candidate parameter sets

# This script to calculate RMSE for each pset and for all variables in each pset (outputs one file per site)




# Calculate RMSE for all predictions per pset


# dt_conn <- lazy_dt(site_predict) # create a data.table connection to use dplyr
# 
# pset_RMSE <- dt_conn %>%
#   
#   select(-predicted, -actual) %>%
#   
#   group_by(pset) %>%
#   
#   summarise(n = n(), Sum_SE = sum(squared_error)) %>%
#   
#   mutate(RMSE = sqrt(Sum_SE / n)) %>%
#   
#   mutate(site = site_name) %>%
#   
#   mutate(variable = 'all_var') %>% 
#   
#   select(pset, site, variable, RMSE, Sum_SE, n) %>% 
#   
#   show_query()  # get native data.table query to run on data.table (see below)


pset_RMSE <- site_predict[, .(pset, site, date, variable, squared_error)][, 
              .(n = .N, Sum_SE = sum(squared_error)), keyby = .(pset)][, 
              `:=`(RMSE = sqrt(Sum_SE/n))][, `:=`(site = ..site_name)][, 
              `:=`(variable = "all_var")][, .(pset, site, variable, 
              RMSE, Sum_SE, n)]
  

# Extract summed squared errors for each pset, with number of predictions per pset (to calc RMSE across all sites)

pset_Sum_SE <- pset_RMSE[, .(pset, Sum_SE, n)]



# Drop unneeded columns

pset_RMSE <- pset_RMSE[, .(pset, site, variable, RMSE)]




# Calculate RMSE for all predictions per variable per pset


# dt_conn <- lazy_dt(site_predict) # create a data.table connection to use dplyr
# 
# var_RMSE <- dt_conn %>% 
#   
#   select(-predicted, -actual) %>% 
#   
#   group_by(pset, variable) %>%
#   
#   summarise(n = n(), Sum_SE = sum(squared_error)) %>% 
#   
#   mutate(RMSE = sqrt(Sum_SE / n)) %>% 
#   
#   mutate(site = site_name) %>% 
#   
#   select(pset, site, variable, RMSE) %>% 
#   
#   show_query()  # get native data.table query to run on data.table (see below)


var_RMSE <- site_predict[, .(pset, site, date, variable, squared_error)][, 
            .(n = .N, Sum_SE = sum(squared_error)), keyby = .(pset, variable)][, 
            `:=`(RMSE = sqrt(Sum_SE/n)), by = .(pset)][, `:=`(site = ..site_name), 
            by = .(pset)][, .(pset, site, variable, RMSE)]



# Combine pset and variable-pset RMSE calculations and pivot wider

pset_RMSE <- rbind(pset_RMSE, var_RMSE)


# dt_conn <- lazy_dt(pset_RMSE) # create a data.table connection to use dplyr
# 
# pset_RMSE <- dt_conn %>%
#   
#   pivot_wider(names_from = variable, values_from = RMSE, names_prefix = 'RMSE_') %>% 
#   
#   show_query()  # get native data.table query to run on data.table (see below)


pset_RMSE <- setnames(dcast(pset_RMSE, formula = pset + site ~ variable, 
             value.var = "RMSE"), old = c("all_var", "basal_area", 
             "dbh", "height"), new = c("RMSE_all_var", "RMSE_basal_area", 
             "RMSE_dbh", "RMSE_height"))



# Write RMSE values to file and remove objects

fwrite(pset_RMSE, paste0('output site RMSE/', tstamp, '_', site_name, '_RMSE.csv'))

rm(var_RMSE)

rm(pset_RMSE)

