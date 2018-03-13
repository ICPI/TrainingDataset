##   Training Dataset
##   Aaron Chafetz
##   Purpose: create a training dataset for public/non-identifiable use
##   Date: 2018.02.13
##   Updated: 

# NOTES:
#  - user must input folderpath where files are stored locally
#  - requires having Fact View stored locally, assumed different location than project folder
#  - got_map.csv should not be posted publically

#dependencies
  library(tidyverse)

#input
  folderpath <- "~/GitHub/TrainingDataset/"

#import new geography data
  got_geo <- read_csv(file.path(folderpath, "got_geo.csv")) 

#import fact view
  df_mer <- read_rds(Sys.glob("~/ICPI/Data/ICPI_FactView_PSNU_IM_*.Rds"))

#inspect unique psnus and mechids
  # df_mer %>% 
  #   group_by(operatingunit) %>% 
  #   summarise_at(vars(psnu, mechanismid), ~ n_distinct(.), na.rm = TRUE) %>% 
  #   ungroup %>% 
  #   print(n = Inf)

#randomly select a ~25 psnus
  #no dedups or mil, must have either FY17 or FY18 data, drop any line with missing values
  cohort <- df_mer %>% 
    filter(is.na(typemilitary), mechanismid > 1) %>% 
    select(region:implementingmechanismname, fy2017apr, fy2018q1) %>% 
    drop_na(region:psnuuid, mechanismid:implementingmechanismname) %>% 
    select(-fy2017apr, -fy2018q1) %>% 
    distinct() %>% 
    sample_n(nrow(got_geo))

#bind the masked geography to the real
  got_map <- bind_cols(got_geo, cohort)
    rm(cohort, got_geo)
  #export for documentation 
    write_csv(got_map, file.path(folderpath,"got_map.csv"))

#bind the masked data on, remove the original geo data and rename the variables  
  got <- left_join(got_map, df_mer) %>%
    select(-region:-psnuuid) %>% 
    rename_all(~ str_remove(., "got_"))
    rm(got_map)
#remove the mech UID
  got <- got %>% 
    mutate(mechanismuid  = "")
  
#identify the number of mechanisms create masked ones and bind back on, replacing the originals
  mechs <- distinct(got, mechanismid) %>% 
    mutate(mechanismid_new = row_number() + 80000)
  got <- full_join(got, mechs)
    rm(mechs)
  got <- got %>% 
    mutate(mechanismid = mechanismid_new) %>% 
    select(-mechanismid_new)

#identify the number of mechanisms create masked ones and bind back on, replacing the originals
  primepartner <- distinct(got, primepartner)
  got_pp <- read_csv(file.path(folderpath, "got_primepartner.csv"))
  got_pp <- got_pp %>% 
    sample_n(nrow(primepartner))
  primepartner <- bind_cols(primepartner, got_pp)
    rm(got_pp)
  got <- full_join(got, primepartner)
    rm(primepartner)
  got <- got %>% 
    mutate(primepartner = got_primepartner,
           implementingmechanismname = got_primepartner) %>% 
    select(-got_primepartner)

#adjust values, 60% of value & rounding to the nearest 10
  got <- got %>% mutate_if(is.numeric, ~ 10*ceiling((.*0.60)/10))

#export
  write_tsv(got, file.path(folderpath, "ICPI_FactView_PSNU_IM_20180215_v1_3_TRAINING.txt"))
                            