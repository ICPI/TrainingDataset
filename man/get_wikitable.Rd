% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_wikitable.R
\name{get_wikitable}
\alias{get_wikitable}
\title{Scrape Wikipedia table}
\usage{
get_wikitable(url)
}
\arguments{
\item{url}{URl on wikipedia}
}
\description{
Scrape Wikipedia table
}
\examples{
\dontrun{
 url <- "https://en.wikipedia.org/wiki/List_of_proper_names_of_stars"
 stars <- get_names(url)
}
}
