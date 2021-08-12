# EucXylo: Kim Martin and Oluwaseun Gakenou
# 10/08/2021
# R version 4.0.3 (2020-10-10)

# Aim: test r3PG predictions generated using different candidate parameter sets

# This script to reshape and combine R3PG predictions from all psets for each site




## import benchmark package (TEMPORARY)

library('bench')


## read in 

f <- 1


sel_cols <- c('parameter set', 'site', 'date', 'variable', 'predicted', 'actual')

site_results <- fread(paste0('input R3PG predictions/', prfiles[f]), select = sel_cols)



# discard unneeded 'volume' variable

site_results <- site_results[variable != 'volume', ]



# FROM[WHERE, SELECT, GROUP BY]
# DT  [i,     j,      by]

site_results2 <- site_results[, mean(abs(actual - predicted)), by = 'parameter set']

site_results3 <- site_results[, mean(predicted/actual), by = 'parameter set']



#

test_vals <- site_results[`parameter set` == 'pset1']
