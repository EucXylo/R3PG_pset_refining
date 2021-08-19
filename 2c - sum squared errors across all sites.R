# EucXylo: Kim Martin and Oluwaseun Gakenou
# 10/08/2021
# R version 4.0.3 (2020-10-10)

# Aim: test r3PG predictions generated using different candidate parameter sets

# This script to sum squared errors across all sites, along with number of predictions per pset (for all-sites RMSE)



# create 'accumulation' data.table when starting looping through sites, then progressively sum

if (f == 1) {
  
  all_Sum_SE <- pset_Sum_SE  
  
  rm(pset_Sum_SE)

} else {
  
  
  # confirm that psets in each in each site predictions file match
  
  msg <- paste0("The 'input R3PG predictions' file for ", site_name, " has psets that don't match preceding files.")
  if (!identical(all_Sum_SE[['pset']], pset_Sum_SE[['pset']])) stop(msg)
  
  
  # add sums of squared errors, and accumulate number of predictions (n) of squared errors included in sum
  
  all_Sum_SE <- rbind(all_Sum_SE, pset_Sum_SE)
  
  rm(pset_Sum_SE)
  
  
  # dt_conn <- lazy_dt(all_Sum_SE) # create a data.table connection to use dplyr
  # 
  # all_Sum_SE <- dt_conn %>%
  # 
  #   group_by(pset) %>% 
  #   
  #   summarise(Sum_SE = sum(Sum_SE), n = sum(n)) %>% 
  # 
  #   show_query()  # get native data.table query to run on data.table (see below)
  
  
  all_Sum_SE <- all_Sum_SE[, .(Sum_SE = sum(Sum_SE), n = sum(n)), keyby = .(pset)]
  

  
}


