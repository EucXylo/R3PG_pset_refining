# EucXylo: Kim Martin and Oluwaseun Gakenou
# 10/08/2021
# R version 4.0.3 (2020-10-10)

# Aim: test r3PG predictions generated using different candidate parameter sets

# This script to calculate Sum_SE for 'fit-predictions' using slope-intercept for each pset, and actual values for each site



# Create vector of all actual data (to be matched up with slope and intercept to calculate fit-predictions)

all_actual_vals <- actual_data %>%
  
  filter(Age > 3) %>% 
  
  filter(PlantComp %in% sites_processed) %>% 
  
  select(Height, DBH, Basal_area) %>% 

  pivot_longer(cols = everything(), names_to = 'Variables', values_to = 'Values') %>% 
  
  pull(Values)



# Add column to hold (accumulated sum) squared-errors from fit-predictions vs actual

all_regress_vals$Sum_SE <- as.numeric(0)


# For each actual value, calculate fit-prediction from all psets, then sum squared-errors for all actual values

for (v in all_actual_vals) {
  
  # dt_conn <- lazy_dt(all_regress_vals) # create a data.table connection to use dplyr
  # 
  # all_regress_vals <- dt_conn %>%
  # 
  #   mutate(actual = v) %>%
  #   
  #   mutate(fit_predict = slope*actual + intercept) %>% 
  #   
  #   mutate(SE = (fit_predict - actual)^2) %>% 
  #   
  #   mutate(Sum_SE = SE + Sum_SE) %>% 
  # 
  #   show_query()  # get native data.table query to run on data.table (see below)
  
  all_regress_vals <- all_regress_vals[, `:=`(actual = ..v)][, 
                                         `:=`(fit_predict = slope * actual + intercept)][, 
                                         `:=`(SE = (fit_predict - actual)^2)][, 
                                         `:=`(Sum_SE = SE + Sum_SE)]
  
}


# Remove unneeded values and add number of SE accumulated in Sum_SE

# dt_conn <- lazy_dt(all_regress_vals) # create a data.table connection to use dplyr
# 
# all_regress_vals <- dt_conn %>%
# 
#   select(pset, slope, intercept, Sum_SE) %>%
# 
#   mutate(n = length(all_actual_vals)) %>%
# 
#   show_query()  # get native data.table query to run on data.table (see below)


all_regress_vals <- all_regress_vals[, .(pset, slope, intercept, Sum_SE)][, `:=`(n = length(..all_actual_vals))]




