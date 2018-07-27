##   Training Dataset
##   Aaron Chafetz
##   Purpose: create a training dataset for public/non-identifiable use
##   Date: 2018-03-13
##   Updated: 2018-07-27

# NOTES:
#  - user must input folderpath where files are stored locally
#  - requires having Fact View stored locally, assumed different location than project folder
#  - got_map.csv should not be posted publically



gen_training <- function(msd_folderpath){
  
  #import new geography data
    got_geo <- readr::read_csv("Input/got_geo.csv",
                        col_types = readr::cols(.default = "c")) 
  
  #import fact view
    df_mer <- readr::read_rds(Sys.glob(file.path(msd_folderpath, "MER_Structured_Dataset_PSNU_IM_*.Rds")))
  
  #randomly select a ~25 psnus
    #identify current period and prior fy apr
    curr_pd <- ICPIutilities::identifypd(df_mer)
    prior_apr <- paste0("fy",ICPIutilities::identifypd(df_mer, "year") - 1,"apr")
    
    #no dedups or mil, must have either FY17 or FY18 data, drop any line with missing values
    cohort <- df_mer %>% 
      dplyr::filter(is.na(typemilitary), mechanismid > 1) %>% 
      dplyr::select(region:implementingmechanismname, prior_apr, curr_pd) %>% 
      dplyr::mutate_at(dplyr::vars(prior_apr, curr_pd), ~ ifelse(. == 0, NA, .)) %>% 
      tidyr::drop_na(region:psnuuid, mechanismid:implementingmechanismname, prior_apr, curr_pd) %>% 
      dplyr::select(-prior_apr, -curr_pd) %>% 
      dplyr::distinct() %>% 
      dplyr::sample_n(nrow(got_geo))
    
      rm(curr_pd, prior_apr)
  #bind the masked geography to the real
    got_map <- dplyr::bind_cols(got_geo, cohort)
      rm(cohort, got_geo)
    #export for documentation 
      fs::dir_create("Input")
      readr::write_csv(got_map, "Input/got_map.csv")
  
  #bind the masked data on, remove the original geo data and rename the variables  
    got <- dplyr::left_join(got_map, df_mer) %>%
      dplyr::select(-region:-psnuuid) %>% 
      dplyr::rename_all(~ stringr::str_remove(., "got_"))
      rm(got_map)
  #remove the mech UID
    got <- got %>% 
      dplyr::mutate(mechanismuid  = "")
    
  #identify the number of mechanisms create masked ones and bind back on, replacing the originals
    mechs <- dplyr::distinct(got, mechanismid) %>% 
             dplyr::mutate(mechanismid_new = dplyr::row_number() + 80000,
                           mechanismid_new = as.character(mechanismid_new))
    got <- dplyr::full_join(got, mechs)
      rm(mechs)
    got <- got %>% 
      dplyr::mutate(mechanismid = mechanismid_new) %>% 
      dplyr::select(-mechanismid_new)
  
  #identify the number of mechanisms create masked ones and bind back on, replacing the originals
    primepartner <- dplyr::distinct(got, primepartner)
    got_pp <- readr::read_csv("Input/got_primepartner.csv",
                              col_types = readr::cols(.default = "c"))
    got_pp <- got_pp %>% 
      dplyr::sample_n(nrow(primepartner))
    primepartner <- dplyr::bind_cols(primepartner, got_pp)
      rm(got_pp)
    got <- dplyr::full_join(got, primepartner)
      rm(primepartner)
    got <- got %>% 
      dplyr::mutate(primepartner = got_primepartner,
                    implementingmechanismname = got_primepartner) %>% 
      dplyr::select(-got_primepartner)
  
  #adjust values, 60% of value & rounding to the nearest 10
    got <- got %>% dplyr::mutate_if(is.numeric, ~ 10*ceiling((.*0.60)/10))
  
  #remove zeros
    got <- got %>% dplyr::mutate_if(is.numeric, ~ ifelse(. == 0, NA, .))
    
  #convert back to uppercase names
    headr <- readr::read_tsv(Sys.glob(file.path(msd_folderpath, "MER_Structured_Dataset_PSNU_IM_*.txt")), 
                      col_types = readr::cols(.default = "c"),
                      n_max = 0) %>%
      names()
    
    names(got) = headr
      rm(headr)
    
  #export
    readr::write_tsv(got, "Output/MER_Structured_TRAINING_Dataset_PSNU_IM_FY17-18_20180622_v2_1.txt", na = "")
    rm(got, df_mer)                          
}
