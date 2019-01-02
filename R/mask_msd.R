#' Mask MSD, aka Training Dataset
#'
#' @param msd_filepath full file path to the MSD (PSNUxIM) (.txt)
#' @param psnuuids list of PSNU UIDs to select (n must equal 15) 
#'
#' @export
#' @importFrom magrittr %>%
#'
#' @examples
#'  \dontrun{
#'   #filepath for MSD (.txt)
#'     msd_filepath <- "~/ICPI/Data/MER_Structured_Dataset_PSNU_IM_FY17-18_20181115_v1_2.txt"
#'   #genreate training dataset
#'     gen_training_planets(msd_filepath) 
#'   }

mask_msd <- function(msd_filepath, psnuuids){

  #exit if 15 PSNU UIDS are not supplied
    if(length(psnuuids) == 0)   stop("No PSNU UID list supplied")
    if(length(psnuuids) != 15)  stop("Must supply 15 PSNU UIDs.")
  
  #set seed for sampling to ensure same order ever time
    set.seed(14)
    
  #change geography data to lower & bind LIST of real PSNUs onto new/masked geography DATA FRAME
    df_mapping <- planets_geo %>% 
      dplyr::rename_all(tolower) %>% 
      dplyr::bind_cols(psnuuid = psnuuids, .)
    
  #import MSD
    df_mer <- ICPIutilities::read_msd(msd_filepath, to_lower = FALSE)

  #store upper & lower case headers for applying ordering and snake casing
    headr <- names(df_mer)
    order <- tolower(headr)
    
  #convert to lower for ease of use
    df_mer <- dplyr::rename_all(df_mer, tolower)
    
  #keep data only from select PSNUs, bind the masked geography to the real
    df_mw <- dplyr::inner_join(df_mer, df_mapping, by = "psnuuid")
    
    rm(df_mer)
    
  #remove the mech UID
    df_mw <- dplyr::mutate(df_mw, mechanismuid  = as.character(NA))
  
  #identify the number of mechanisms create masked ones and bind back on, replacing the originals
    mechs <- df_mw %>% 
      dplyr::distinct(mechanismid) %>% 
      dplyr::arrange(mechanismid)
  
    new_mechs <- seq(1200, 1800,1) %>% #mechanism id can fall between 1200 and 1800
      sample(nrow(mechs)) %>% #sample n number of mech ids based on n of mechanisms
      as.character(.) %>% 
      dplyr::bind_cols(mechs, mechanismid_mw = .) %>% #combine masked id with dedup
      dplyr::mutate(mechanismid_mw = ifelse(mechanismid %in% c("00000", "00001"), 
                                            stringr::str_replace(mechanismid, "0000", "000"),
                                            mechanismid_mw),
                    mechanismid_mw = paste0("0", mechanismid_mw)) 
  
  #add masked partner & mechanism names
    partners <- planets_primepartners %>% 
      dplyr::sample_n(nrow(mechs)) %>% #sample primeparter and mech names from list
      dplyr::bind_cols(new_mechs, .) %>% #bind onto mechanism list
      dplyr::mutate(primepartner_mw = ifelse(mechanismid %in% c("00000", "00001"), "Dedup", primepartner_mw),
                    implementingmechanismname_mw = ifelse(mechanismid %in% c("00000", "00001"), "Dedup", implementingmechanismname_mw))

  #bind mechanism info onto dataset
    df_mw <- dplyr::left_join(df_mw, partners, by = "mechanismid")
  
  #remove the original hiearchy/partner data and rename the variables and reorder 
    lst_unmaskedvar <- df_mw %>% 
      dplyr::select(dplyr::ends_with("_mw")) %>% 
      names() %>% 
      stringr::str_remove("_mw")
    
    df_mw <- df_mw %>% 
      dplyr::select(-lst_unmaskedvar) %>% 
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



