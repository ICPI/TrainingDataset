##   Training Dataset
##   Aaron Chafetz
##   Purpose: create a training dataset for public/non-identifiable use
##   Date: 2018-12-19
##   Updated: 


# NOTES -------------------------------------------------------------------

#  - user must supply filepath for local PSNUxIM MSD
#  - requires having MSD (.txt) stored locally
#  - requires having planets_psnuuids2map.csv saved in Input which identifies the actual PSNUs that will be masked


# DEPENDENCIES ------------------------------------------------------------

library(magrittr)


# FUNCTION ----------------------------------------------------------------


gen_training_planets <- function(msd_filepath){
  
  #set seed for sampling to ensure same order ever time
    set.seed(14)
  
  #import new geography data
    planets_geo <- readr::read_csv("Input/planets_geo.csv",
                             col_types = readr::cols(.default = "c")) %>% 
      dplyr::rename_all(tolower)
  
  #bind list of real PSNUs onto new geography data frame
    planets_geo <- readr::read_csv("Input/planets_psnuuids2map.csv",
                    col_types = readr::cols(.default = "c")) %>% 
      dplyr::bind_cols(planets_geo)
    
  #import MSD
    df_mer <- ICPIutilities::read_msd(msd_filepath, to_lower = FALSE)

  #store upper & lower case headers for applying ordering and snake casing
    headr <- names(df_mer)
    order <- tolower(headr)
    
  #convert to lower for ease of use
    df_mer <- dplyr::rename_all(df_mer, tolower)
    
  #keep data only from select PSNUs, bind the masked geography to the real
    df_mw <- dplyr::inner_join(df_mer, planets_geo, by = "psnuuid")
    
    rm(df_mer)
    
  #remove the mech UID
    df_mw <- df_mw %>% 
      dplyr::mutate(mechanismuid  = "")
  
  #identify the number of mechanisms create masked ones and bind back on, replacing the originals
    mechs <- df_mw %>% 
      dplyr::distinct(mechanismid) %>% 
      dplyr::arrange(mechanismid)
  
    new_mechs <- seq(1200, 1800,1) %>% #mechanism id can fall between 1200 and 1800
      sample(nrow(mechs)) %>% #sample n number of mech ids based on n of mechanisms
      as.character(.) %>% 
      dplyr::bind_cols(mechs, mechanismid_mw = .) %>% 
      dplyr::mutate(mechanismid_mw = ifelse(mechanismid %in% c("00000", "00001"), 
                                            stringr::str_replace(mechanismid, "0000", "000"),
                                            mechanismid_mw),
                    mechanismid_mw = paste0("0", mechanismid_mw)) 
  
  #add masked partner & mechanism names
    partners <- readr::read_csv("Input/planets_primepartners.csv",
                                col_types = readr::cols(.default = "c")) %>% 
      dplyr::rename(primepartner_mw = contellation,
                    implementingmechanismname_mw = star_name) %>% 
      dplyr::sample_n(nrow(mechs)) %>% #sample primeparter and mech names from list
      dplyr::bind_cols(new_mechs, .) #bind onto mechanism list

  #bind mechanism info onto dataset
    df_mw <- df_mw %>% 
      dplyr::select(mechanismid) %>% 
      dplyr::left_join(., partners, by = "mechanismid") %>% 
      dplyr::select(-mechanismid) %>% 
      dplyr::bind_cols(df_mw, .) 
  
  #remove the original geo data and rename the variables  
    unmasked <- df_mw %>% 
      dplyr::select(dplyr::ends_with("_mw")) %>% 
      names() %>% 
      stringr::str_remove("_mw")
    
    df_mw <- df_mw %>% 
      dplyr::select(-unmasked) %>% 
      dplyr::rename_all(~ stringr::str_remove(., "_mw")) %>% 
      dplyr::select(order)
  
  #adjust values, 60% of value & rounding to the nearest 10 and then remove zeros
    df_mw <- df_mw %>% 
      dplyr::mutate_if(is.numeric, ~ 10*ceiling((.*0.60)/10)) %>% 
      dplyr::mutate_if(is.numeric, ~ ifelse(. == 0, NA, .))

  #convert back to uppercase names
    names(df_mw) <- headr
  
  #export
    msd_filepath <- msd_filepath %>% 
      basename() %>% 
      stringr::str_replace("MER_Structured_Dataset", "MER_Structured_TRAINING_Dataset") 
      
    readr::write_tsv(df_mw, file.path("Output/", msd_filepath), na = "")
} 


# GENERATE TRAINING DATASET -----------------------------------------------

#filepath for MSD (.txt)
  msd_filepath <- "~/ICPI/Data/MER_Structured_Dataset_PSNU_IM_FY17-18_20181115_v1_2.txt"

#genreate training dataset
  gen_training_planets(msd_filepath)
