# EucXylo: Kim Martin and Oluwaseun Gakenou
# 10/08/2021
# R version 4.0.3 (2020-10-10)

# Aim: test r3PG predictions generated using different candidate parameter sets

# This script to read in large files containing predictions for all psets (one file per site)



# Read in site predictions file and rename 'parameter set' column to 'pset'

site_predict <- fread(paste0('input R3PG predictions/', p_files[f]), select = sel_cols)

colnames(site_predict)[1] = 'pset'


# Check only one site name is referenced in the predictions file

site_name <- unique(site_predict$site)

msg <- paste0("File 'input R3PG predictions/", p_files[f], "' does not have a consistent 'site' name.")
if (length(site_name) != 1) stop(msg)

sites_processed <- c(sites_processed, site_name)


# Check site name is in expected row of 'predictions per site' dataframe for referencing

msg <- "Site names in 'input actual/actual_data.csv' do not match site names in 'input R3PG predictions' files."
if (pred_per_site[f, 'Site'] != site_name) stop(msg)


# Check variable order matches expectations

num_pred_per_var <- pred_per_site[f, 'Pred_per_variable']

num_pred_per_pset <- pred_per_site[f, 'Pred_per_pset']

var_order <- site_predict$variable[1:num_pred_per_pset]  # Expect var order pattern to repeat for each pset

expect_var_order <- rep(expect_var, each = num_pred_per_var)

msg <- paste0("Variable order in '", p_files[f], "' does not match expected order.")
if (!identical(var_order, expect_var_order)) stop(msg)


# Drop unwanted variables

for (uvar in setdiff(expect_var, want_var)) {
  
  site_predict <- site_predict[site_predict$variable != uvar, ]
  
}


# Update number of predictions per pset (after dropping 'volume' predictions)

num_pred_per_pset <- num_pred_per_var * length(want_var)


