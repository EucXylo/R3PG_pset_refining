# EucXylo: Kim Martin and Oluwaseun Gakenou
# 10/08/2021
# R version 4.0.3 (2020-10-10)

# Aim: test r3PG predictions generated using different candidate parameter sets

# This script to install necessary libraries and contain function definitions



## LIBRARIES

# install if not already installed

libs <- c('data.table',  # for efficiently handling large in-memory datasets
          'tidyverse',   # for easy-to-read queries
          'dtplyr')      # for translating tidyverse queries into stable, fast native data.table queries

for (lib in libs){
  
  if (!require(lib, character.only = TRUE)) install.packages(lib, dependencies = TRUE)  
  library(lib, character.only = TRUE)
  
}



## FUNCTIONS

funcs <- list.files('functions')

for (f in funcs) {
  
  source(paste0('functions/', f))
  
}


