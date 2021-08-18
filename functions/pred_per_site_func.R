## IDENTIFY NUMBER OF MEASUREMENTS PER SITE

pred_per_site_func <- function(actual_data) {
  
pred_per_site <- actual_data %>% 
  
  rename(Site = PlantComp) %>%
  
  select(Site, Age) %>%
  
  filter(Age > 3) %>%
  
  count(Site) %>%
  
  arrange(Site) %>%
  
  rename(Pred_per_variable = n) %>%
  
  mutate(Pred_per_pset = Pred_per_variable * num_var)
  
return(pred_per_site)
  
}