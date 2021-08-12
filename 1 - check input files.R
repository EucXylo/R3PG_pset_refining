# EucXylo: Kim Martin and Oluwaseun Gakenou
# 10/08/2021
# R version 4.0.3 (2020-10-10)

# Aim: test r3PG predictions generated using different candidate parameter sets

# This script to check input files exist and match requirements



## WARNING

warning("All input files must be closed, or this process will fail.")



## GET SITE INPUT FILES AND IGNORE NON-CSV FORMAT FILES

prfiles <- list.files('input R3PG predictions')  # get file names from input folder

msg <- "Not all files in 'input sites' are csv format."
if (any(!grepl("csv$", prfiles, ignore.case=T))) stop(msg)

input_pset_results <- sub(".csv$", '', prfiles, ignore.case=T)




## CREATE OUTPUT FOLDERS IF THEY DON'T ALREADY EXIST

if (!dir.exists('output psets')) dir.create('output lm fits')





