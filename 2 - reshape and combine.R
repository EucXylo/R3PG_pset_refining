# EucXylo: Kim Martin and Oluwaseun Gakenou
# 10/08/2021
# R version 4.0.3 (2020-10-10)

# Aim: test r3PG predictions generated using different candidate parameter sets

# This script to reshape and combine R3PG predictions from all psets for each site




## IDENTIFY NUMBER OF MEASUREMENTS PER SITE

pred_per_site <- actual_data %>% 
  
  rename(Site = PlantComp) %>%
  
  select(Site, Age) %>%
  
  filter(Age > 3) %>%
  
  count(Site) %>%
  
  arrange(Site) %>%
  
  rename(Pred_per_variable = n) %>%
  
  mutate(Pred_per_pset = Pred_per_variable * 4)   # 4 variables in original pipeline (dbh, height, basal area, volume)




## IDENTIFY NUMBER OF PARAMETER SETS TO PROCESS


# Read in first site predictions file as a data.table (more efficient than data.frame)

f <- 1

sel_cols <- c('parameter set', 'site', 'date', 'variable', 'predicted', 'actual')

site_predict <- fread(paste0('input R3PG predictions/', p_files[f]), select = sel_cols)


# Get number of predictions per pset (rows) for this site

site_name <- site_predict$site[1]

msg <- "Site names in 'input actual/actual_data.csv' do not match site names in 'input R3PG predictions' files."
if (pred_per_site[1, 'Site'] != site_name) stop(msg)

num_pred_per_var <- pred_per_site[f, 'Pred_per_variable']

num_pred_per_pset <- pred_per_site[f, 'Pred_per_pset']


# Calculate total number of psets

num_psets <- dim(site_predict)[1]/num_pred_per_pset



## CHECK ORDER OF VARIABLES MATCHES EXPECTATIONS, AND DISCARD 'VOLUME'

var_order <- site_predict$variable[1:num_pred_per_pset]

expect_var <- rep(c('basal_area', 'dbh', 'height', 'volume'), each = num_pred_per_var)

msg <- paste0("Variable order in '", p_files[f], "' does not match expected order.")
if (!identical(var_order, expect_var)) stop(msg)


# discard unneeded 'volume' variable 

keep_var <- expect_var != 'volume'

site_predict <- site_predict[rep(keep_var, times = num_psets), ]

new_num_var <- 3



## NORMALISE PREDICTIONS AND ACTUAL VALUES BY MAX ACTUAL VALUES FOR THIS SITE

# Get maximum actual value for each variable in this site

max_val_per_var <- site_predict %>%
  
  slice(1:num_pred_per_pset) %>%
  
  select(site, variable, actual) %>% 
  
  group_by(variable) %>% 
  
  summarise(max(actual)) %>% 
  
  collect()


msg <- paste0("Variable order in 'max_val_per_var' does not match expected order.")
if (!identical(max_val_per_var$variable, c('basal_area', 'dbh', 'height'))) stop(msg)



# Normalise predictions and actual by max actual

actual_all_pred <- rep(max_val_per_var$`max(actual)`, each = num_pred_per_var)

site_predict$norm_predict <- site_predict$predicted / rep(actual_all_pred, times = num_psets)

max_norm_actual <- site_predict$actual[1:(num_pred_per_var * new_num_var)] / actual_all_pred



# Convert normalised values to integer values (units of 1/100 percent) for efficiency

site_predict$norm_predict_int <- as.integer(site_predict$norm_predict * 10000)

max_norm_actual_int <- as.integer(max_norm_actual * 10000)



## CREATE NEW DATAFRAME WITH ONE COLUMN PER PSET (MAX-NORMALISED INTEGER VALUES ONLY)

# reshaped_pred <- data.frame(pset = rep(paste0('pset', 1:num_psets), each  = new_num_var), 
#                             site = site_name,
#                             date = rep(site_predict$date[1:num_pred_per_var], times = new_num_var),
#                             norm_actual = max_norm_actual_int)



dt_conn <- lazy_dt(site_predict) # create a data.table connection to use dplyr

reshaped_pred <- dt_conn %>% 
  
  select('parameter set', site, date, variable, norm_predict_int) %>% 
  
  pivot_wider() 
  
  collect()




