# EucXylo: Kim Martin and Oluwaseun Gakenou
# 10/08/2021
# R version 4.0.3 (2020-10-10)

# Aim: test r3PG predictions generated using different candidate parameter sets

# This script to check input files exist and match requirements



## WARNING

warning("All input files must be closed, or this process will fail.")



## GET SITE INPUT FILES AND IGNORE NON-CSV FORMAT FILES

p_files <- list.files('input R3PG predictions')  # get file names from input folder

msg <- "Not all files in 'input sites' are csv format."
if (any(!grepl("csv$", p_files, ignore.case=T))) stop(msg)


# Check that all input files are from the same (timestamped) run

run_tstamp <- substr(p_files[1], regexpr('[0-9]{10}', p_files[1]), regexpr('[0-9]{10}', p_files[1]) + 9)

msg <- "Files in 'input R3PG predictions' do not have a shared timestamp."
if (!all(grepl(run_tstamp, p_files))) stop(msg)





## GET FILE CONTAINING ACTUAL DATA PER SITE (WILL COUNT MEASUREMENTS IN TREES > 3YR OLD)

msg <- "Missing 'input actual/actual_data.csv' file."
if (!file.exists('input actual/actual_data.csv')) stop(msg)


actual_data <- read.csv('input actual/actual_data.csv')


msg <- "Missing expected fields ('PlantComp', 'Age') in 'input actual/actual_data.csv'."
if (!all(c('PlantComp', 'Age') %in% colnames(actual_data))) stop(msg)




## GET TIMESTAMP FOR OUTPUT FILES

tstamp <- format(Sys.time(), '%y%m%d%H%M')




## DELETE AND RECREATE OUTPUT FOLDERS

output_dirs <- c('output site RMSE',    # for saving RMSE for each site (per pset, per variable in each pset)
                 'output trace')        # for saving session info etc about each run

for (odir in output_dirs) {
  
  unlink(odir, recursive = TRUE)
  
  dir.create(odir)
  
}



## SAVE TIMESTAMPED SESSION INFO

sink(paste0('output trace/', tstamp, '_session_info.txt'))
sessionInfo()
sink()





