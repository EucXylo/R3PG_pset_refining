# EucXylo: Kim Martin and Oluwaseun Gakenou
# 10/08/2021
# R version 4.0.3 (2020-10-10)

# Aim: test r3PG predictions generated using different candidate parameter sets

# This script to reshape and combine R3PG predictions from all psets for each site



expect_var <- c('basal_area', 'dbh', 'height', 'volume')

num_var <- length(expect_var)


## IDENTIFY NUMBER OF MEASUREMENTS PER SITE

pred_per_site <- actual_data %>% 
  
  rename(Site = PlantComp) %>%
  
  select(Site, Age) %>%
  
  filter(Age > 3) %>%
  
  count(Site) %>%
  
  arrange(Site) %>%
  
  rename(Pred_per_variable = n) %>%
  
  mutate(Pred_per_pset = Pred_per_variable * num_var)



## IDENTIFY NUMBER OF PARAMETER SETS TO PROCESS


# Read in first site predictions file as a data.table (more efficient than data.frame)

f <- 1

sel_cols <- c('parameter set', 'site', 'date', 'variable', 'predicted', 'actual')

site_predict <- fread(paste0('input R3PG predictions/', p_files[f]), select = sel_cols)

colnames(site_predict)[1] = 'pset'


# Get number of predictions per pset (rows) for this site

site_name <- site_predict$site[1]

msg <- "Site names in 'input actual/actual_data.csv' do not match site names in 'input R3PG predictions' files."
if (pred_per_site[f, 'Site'] != site_name) stop(msg)

num_pred_per_var <- pred_per_site[f, 'Pred_per_variable']

num_pred_per_pset <- pred_per_site[f, 'Pred_per_pset']


# Calculate total number of psets

num_psets <- dim(site_predict)[1] / num_pred_per_pset



## CHECK ORDER OF VARIABLES MATCHES EXPECTATIONS, AND DISCARD 'VOLUME'

var_order <- site_predict$variable[1:num_pred_per_pset]  # Expect var order pattern to repeat for each pset

expect_var_order <- rep(expect_var, each = num_pred_per_var)

msg <- paste0("Variable order in '", p_files[f], "' does not match expected order.")
if (!identical(var_order, expect_var_order)) stop(msg)


# discard unneeded 'volume' variable

keep_var <- expect_var_order != 'volume'

site_predict <- site_predict[rep(keep_var, times = num_psets), ]


# update variable info

expect_var <- expect_var[expect_var != 'volume']

num_var <- length(expect_var)

num_pred_per_pset <- num_pred_per_var * num_var




## CONVERT VALUES TO INTEGERS TO IMPROVE STORAGE EFFICIENCY 

# Convert values to scaled integers (multiply by 1e5 to capture all decimal values)

site_predict$int_pred_e5 <- as.integer(site_predict$predicted * 1e5)

site_predict$int_act_e5 <- as.integer(site_predict$actual * 1e5)



## RESHAPE PREDICTIONS (PSETS COLUMN-WISE)

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


# Remove original site predictions dt and connection object

rm(site_predict)
rm(dt_conn)


