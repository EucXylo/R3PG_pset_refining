# R3PG_pset_refining

Pipeline to identify the best 'psets' (parameter sets, generated as combinations of test parameters in the 'R3PG_parameter_testing' pipeline)


## v2021-09-16_v1

Change from previous version - uses actual data from 'input actual/actual_data.csv', instead of using actual data column that is present in the site prediction files (some errors in previous 'actual' values)


## v2021-09-08_v1

Takes site predictions (from 'R3PG_parameter_testing' pipeline) and combines with 'actual_data.csv' to calculate RMSE (predicted vs actual, not line fit) for all psets (all variables, including combined, for each site). Also outputs Sum_SE (predicted vs actual), Sum_SE_fit (line fit to predictions-vs-actual vs actual/ideal) and eRMSE (calculated using the previous two values) for each pset, across all sites and variables.

NB: Only dbh, height, and basal_area used - volume excluded.