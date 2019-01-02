#' Generate a Site Name
#'
#' @export
#' @importFrom magrittr %>%
#' 
#' @examples
#' \dontrun{
#'   gen_sitename()
#'   }

gen_sitename <- function(){
  name <- sample(planets_sites, 1)
  type <- sample(planets_site_types, 1)
  num <-  seq(1,100) %>% 
    stringr::str_pad(3, pad = "0") %>% 
    sample(1)
  sitename <- paste(name, type, num)
  
  return(sitename)
}