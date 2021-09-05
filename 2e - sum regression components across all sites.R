# EucXylo: Kim Martin and Oluwaseun Gakenou
# 10/08/2021
# R version 4.0.3 (2020-10-10)

# Aim: test r3PG predictions generated using different candidate parameter sets

# This script to sum regression components across all sites, along with number of predictions per pset



# create 'accumulation' data.table when starting looping through sites, then progressively sum

if (f == 1) {
  
  num_psets <- dim(regress_vals)[1]
  
  regress_vals_all <- regress_vals
  
  rm(regress_vals)
  

} else {
  
  
  # add regression components, and accumulate number of predictions (n) of components included in sum
  
  regress_vals_all <- rbind(regress_vals_all, regress_vals)
  
  rm(regress_vals)
  
  
  # dt_conn <- lazy_dt(regress_vals_all) # create a data.table connection to use dplyr
  # 
  # regress_vals_all <- dt_conn %>%
  # 
  #   group_by(pset) %>%
  # 
  #   summarise(sum_x = sum(sum_x),
  #             sum_y = sum(sum_y),
  #             sum_xy = sum(sum_xy),
  #             sum_x2 = sum(sum_x2),
  #             n = sum(n)) %>%
  #   
  #   ungroup() %>% 
  # 
  #   show_query()  # get native data.table query to run on data.table (see below)
  
  
  regress_vals_all <- regress_vals_all[, .(sum_x = sum(sum_x), sum_y = sum(sum_y), sum_xy = sum(sum_xy), 
                                           sum_x2 = sum(sum_x2), n = sum(n)), keyby = .(pset)]
  
  
}


