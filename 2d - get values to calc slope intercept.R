# EucXylo: Kim Martin and Oluwaseun Gakenou
# 10/08/2021
# R version 4.0.3 (2020-10-10)

# Aim: test r3PG predictions generated using different candidate parameter sets

# This script to calculate components of slope-intercept calculations, from each site (to be accumulated)



# Calculate components for slope-intercept calculations for all psets for this site


# dt_conn <- lazy_dt(site_predict) # create a data.table connection to use dplyr
# 
# regress_vals <- dt_conn %>% 
#   
#   select(pset, actual, predicted) %>% 
#   
#   rename(x = actual, y = predicted) %>% 
#   
#   mutate(xy = x * y) %>% 
#   
#   mutate(x2 = x^2) %>% 
#   
#   group_by(pset) %>% 
#   
#   summarize(sum_x = sum(x), sum_y = sum(y), sum_xy = sum(xy), sum_x2 = sum(x2), n = n()) %>% 
#   
#   ungroup() %>% 
# 
#   show_query()  # get native data.table query to run on data.table (see below)
  

regress_vals <- setnames(copy(site_predict)[, .(pset, actual, predicted)], 
                         c("actual", "predicted"), c("x", "y")
                         )[, `:=`(xy = x * y)][, `:=`(x2 = x^2)][
                             , .(sum_x = sum(x), sum_y = sum(y), sum_xy = sum(xy), sum_x2 = sum(x2), n = .N), 
                             keyby = .(pset)]


# NB: sum_x and sum_x2 are constant for all psets (store as single variables, outside data.table?)
# Will need to accumulate separately across sites...


# 'regress_vals' = data.table with the following columns:
# - sum_x
# - sum_y
# - sum_xy
# - sum_x2
# - n

