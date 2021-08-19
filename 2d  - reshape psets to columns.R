# EucXylo: Kim Martin and Oluwaseun Gakenou
# 10/08/2021
# R version 4.0.3 (2020-10-10)

# Aim: test r3PG predictions generated using different candidate parameter sets

# This script to reshape predictions (psets column-wise) in preparation for fitting a linear model







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



