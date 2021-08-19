# EucXylo: Kim Martin and Oluwaseun Gakenou
# 10/08/2021
# R version 4.0.3 (2020-10-10)

# Aim: test r3PG predictions generated using different candidate parameter sets

# This script to reshape predictions (psets column-wise) in preparation for fitting a linear model





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



# Test ordering 'site_predict' by date and variable gives matching values for random pset in reshaped data

test_pset <- sample(1:num_psets, size = 1)

offset <- (test_pset - 1) * num_pred_per_pset

cf_pset <- site_predict %>% 
  
  slice((1 + offset):(12 + offset)) %>% 
  
  arrange(date, variable) %>% 
  
  collect()


test_pset <- paste0('pset', test_pset)

msg <- "Pset row order in reshaped data.table does not match expectations."
if (!identical(reshaped_pred[[test_pset]], cf_pset$int_pred_e5)) stop(msg)



rm(site_predict)  # no longer needed - clear from memory

