#read csv
  planets_geo <- readr::read_csv("data-raw/planets_geo.csv")

#store
  save(planets_geo, file = "data/planets_geo.rda")
