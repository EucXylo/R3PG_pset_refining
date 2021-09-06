# EucXylo: Kim Martin and Oluwaseun Gakenou
# 10/08/2021
# R version 4.0.3 (2020-10-10)

# Aim: test r3PG predictions generated using different candidate parameter sets

# This script to calculate 'extended RMSE' combining R3PG predictions and actual-vs-R3PG line-fit predictions



# Check Sum_SE psets and number of values summed match

msg <- "Error matching up SumSE from R3PG predictions and line-fit predictions."
if (!identical(all_Sum_SE$pset, all_regress_vals$pset)) stop(msg)
if (!identical(all_Sum_SE$n, all_regress_vals$n)) stop(msg)


# Combine Sum_SE and number of values from R3PG predictions and line-fit predictions

all_Sum_SE$Sum_SE <- all_Sum_SE$Sum_SE + all_regress_vals$Sum_SE

all_Sum_SE$n <- all_Sum_SE$n + all_regress_vals$n


# Calculate eRMSE

all_Sum_SE$eRMSE <- sqrt(all_Sum_SE$Sum_SE / all_Sum_SE$n)
