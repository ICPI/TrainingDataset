
# Pull List of Contellation/Star Names ------------------------------------


#dependencies
library(magrittr)


#function to extract json of character names and convert to data frame
get_names <- function(url){
  #extract table from wikipedia
  wikitable <- url %>%
    xml2::read_html() %>%
    rvest::html_nodes(xpath='//*[@id="mw-content-text"]/div/table[2]') %>%
    rvest::html_table(fill = TRUE)
  #covert json to df
  df <- wikitable %>% 
    purrr::pluck(data.frame) %>% 
    tibble::as_tibble() %>% 
    dplyr::select(contellation = Constellation, star_name = Modern.proper.name) %>% 
    dplyr::mutate(star_name = stringr::str_remove_all(star_name, "[citation needed]|†")) %>% 
    dplyr::filter(star_name != "-")
}

url <- "https://en.wikipedia.org/wiki/List_of_proper_names_of_stars"

get_names(url) %>% 
readr::write_csv("Input/planet_primepartners.csv")
