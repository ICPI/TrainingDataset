
#cleanup
planet_sites <- readLines("data-raw/planets_sites.csv") %>% 
  stringr::str_trim() %>% 
  stringr::str_to_title()

#save as vector
save(planet_sites, file = "data/planet_sites.rda")
