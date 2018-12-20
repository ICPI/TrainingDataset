
#scrape
  url <- "https://en.wikipedia.org/wiki/List_of_proper_names_of_stars"
  stars <- get_wikitable(url)

#clean up
  stars <- stars %>% 
    dplyr::select(constellation = Constellation, star_name = Modern.proper.name) %>% 
    dplyr::mutate(star_name = stringr::str_remove_all(star_name, "[citation needed]|†")) %>% 
    dplyr::filter(star_name != "-")

#save
  readr::write_csv(stars, "data-raw/planets_primepartners.csv")
  save(stars, file = "data/planets_primepartners.rda")
  