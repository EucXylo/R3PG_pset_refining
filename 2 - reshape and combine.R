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

colnames(site_predict)[1] = 'pset'


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



# Convert values to scaled integers (multiply by 1e5 to capture all decimal values)

site_predict$int_pred_e5 <- as.integer(site_predict$predicted * 1e5)

site_predict$int_act_e5 <- as.integer(site_predict$actual * 1e5)



# Reshape to one column for each pset

dt_conn <- lazy_dt(site_predict) # create a data.table connection to use dplyr

reshaped_pred <- dt_conn %>% 
  
  select(pset, site, date, variable, int_act_e5, int_pred_e5) %>% 
  
  pivot_wider(names_from = pset,
              values_from = int_pred_e5) %>%  
  
  show_query()  # get native data.table query to run on data.table (see below)

reshaped_pred <- dcast(site_predict[, .(pset, site, date, variable, int_act_e5, int_pred_e5)], 
                       formula = site + date + variable + int_act_e5 ~ pset, value.var = "int_pred_e5")


# NB: reshaped_predict rows are ordered by date, then variable name
# NB: reshaped_predict pset columns are ordered alphabetically (pset1, pset10, pset100, ...)



pset_order  <- sort(paste0('pset', c(1:num_psets)))

(identical(colnames(reshaped_pred)[5:(num_psets+4)], pset_order))



test <- reshaped_pred[, c(1:6)]

offset <- 9 * 12

cf_pset <- site_predict %>% 
  
  slice((1 + offset):(12 + offset)) %>% 
  
  arrange(date, variable) %>% 
  
  collect()


(identical(test$pset10, cf_pset$int_pred_e5))
