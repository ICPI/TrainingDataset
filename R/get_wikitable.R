#' Scrape Wikipedia table
#'
#' @param url URl on wikipedia
#'
#' @export
#' @importFrom magrittr %>%
#'
#' @examples
#' \dontrun{
#'  url <- "https://en.wikipedia.org/wiki/List_of_proper_names_of_stars"
#'  stars <- get_names(url)
#' }
get_wikitable <- function(url){
  #extract table from wikipedia
  wikitable <- url %>%
    xml2::read_html() %>%
    rvest::html_nodes(xpath='//*[@id="mw-content-text"]/div/table[2]') %>%
    rvest::html_table(fill = TRUE)
  #covert json to df
  df <- wikitable %>% 
    purrr::pluck(data.frame) %>% 
    tibble::as_tibble() 
  return(df)
}

