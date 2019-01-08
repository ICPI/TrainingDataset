#' Mask Site/Community Information
#'
#' @param df site MSD to mask (post adjusting PSNU level)
#'
#' @importFrom magrittr %>% 
#' @export

mask_sites <- function(df){
  
  #run only on site data
  if("orgunituid" %in% names(df)){
  
  #complete list of sites
    unique_sites <- df %>% 
      dplyr::rename_all(~ tolower(.)) %>% 
      dplyr::filter(facility != "N/A") %>%
      dplyr::distinct(facilityuid)
  
  #mask uids
    maskedsites <- replicate(nrow(unique_sites), generateUID()) %>% 
      dplyr::bind_cols(unique_sites, facilityuid_mw = .)
    
  #mask site names
    maskedsites <- replicate(nrow(unique_sites), gen_sitename()) %>% 
      dplyr::bind_cols(maskedsites, facility_mw = .)
  
  #bind makes uids and names onto MSD
    df <- df %>% 
      dplyr::select(facilityuid) %>% 
      dplyr::full_join(df, maskedsites, by = "facilityuid")
  
  #mask community/facility/orgunit uids and names
  df <- df %>% 
    dplyr::mutate(communityuid_mw == ifelse(communityuid == "?", "?", psnuuid_mw),
                  community_mw == ifelse(communityuid == "?", "Data reported above Community Level", psnu_mw),
                  facilityuid_mw == ifelse(facility == "N/A", "N/A", facility_mw),
                  facility == ifelse(facility == "N/A", "N/A", facility_mw),
                  orgunituid == dplyr::case_when(communityuid_mw == "?" ~ operatingunituid_mw, 
                                                 facility_mw == "N/A"   ~ communityuid_mw,
                                                 TRUE                   ~ facilityuid_mw),
                  sitename == dplyr::case_when(communityuid_mw == "?"   ~ operatingunit_mw, 
                                               facility_mw == "N/A"     ~ community_mw,
                                               TRUE                     ~ facility_mw))
  }
  
  return(df)
  
}


