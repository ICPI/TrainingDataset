
#scrape
  url <- "https://en.wikipedia.org/wiki/List_of_proper_names_of_stars"
  planets_primepartners <- get_wikitable(url)

#clean up
  planets_primepartners <- planets_primepartners %>% 
    dplyr::select(constellation = Constellation, star_name = Modern.proper.name) %>% 
    dplyr::mutate(star_name = stringr::str_remove_all(star_name, "[citation needed]|†")) %>% 
    dplyr::filter(star_name != "-") %>% 
    dplyr::rename(primepartner_mw = constellation,
                  mech_name_mw = star_name)

#save
  readr::write_csv(planets_primepartners, "data-raw/planets_primepartners.csv")
  save(planets_primepartners, file = "data/planets_primepartners.rda")
  