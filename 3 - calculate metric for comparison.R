



# https://en.wikipedia.org/wiki/Mean_absolute_percentage_error


# Divide all predicted and actual values by the average (or largest value) for that variable in that site



# test lm

site1_lm <- lm(as.matrix(reshaped_pred[ , c(5:1000)]) ~ reshaped_pred$int_act_e5)

offset <- match('pset100', pset_order)

single_lm <- lm(reshaped_pred[[4 + offset]] ~ reshaped_pred$int_act_e5)

summary(single_lm)

site1_coeff <- t(site1_lm$coefficients)


## CALCULATE RMSE FOR CHUNKS PROGRESSIVELY


## MATCH LM COEFF & RMSE VALUES TO PSET (MODIFIED) PARAMETER VALUES?
