#' Geography for the Masked Dataset
#' 
#' A dataset containing MER Structured Dataset
#' hieararchy for 9 Priority Sub National Units (PSNUs).
#' All data have an underscore of _mw to designate they 
#' fall in the Milky Way (they duplicate the columns
#' in the MSD they will replace).
#' 
#' @format A dataframe with 9 rows and 9 variables:
#' \describe{
#'   \item{Region_mw}{hieararchy one level below global}
#'   \item{RegionUID_mw}{the unique ID for Region}
#'   \item{OperatingUnit_mw}{the operating unit/country}
#'   \item{OperatingUnitUID_mw}{the unique ID for the Operating Unit}
#'   \item{CountryName_mw}{the country name, ie for regional missions}
#'   \item{SNU1_mw}{sub national unit 1, 1 level below OU}
#'   \item{SNU1Uid_mw}{unique ID for the SNU1}
#'   \item{PSNU1_mw}{sub national level targeting occurs at}
#'   \item{PSNUuid_mw}{unique ID for the PSNU}
#' }
#' 
#' @source Initial developed by Abe Agedew (CDC/ICPI); adjustments by Aaron Chafetz (USAID/ICPI)
"planets_geo"