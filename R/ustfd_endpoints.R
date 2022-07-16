#' Return a table of supported and known endpoints
#'
#' @description
#'
#' `ustfd_endpoints` provides details about 80 known endpoints for Fiscal Data.
#' A data frame with 80 rows and the following 4 columns:
#'
#'  * `data_set` - name of the source data_set
#'  * `table_name` - Name of the table within the data set
#'  * `endpoint` - the serialized version of the URL endpoint (natural key)
#'  * `endpoint_description` - a description for the data in the endpoint
#'
#' @return tibble
#'
#' @export
#'
#' @family ustfd_user
#'
#' @source \url{https://fiscaldata.treasury.gov/api-documentation/#list-of-endpoints}
#'
#' @examples
#' library(ustfd)
#' unique(ustfd_endpoints()$data_set)
#'
#'
#'
ustfd_endpoints <- function(){
  .ustfd_endpoints
}

#' Return a table of known fields for known endpoints
#'
#' @description
#'
#' `ustfd_field_dictionary` returns the field dictionaries for the requested endpoint.
#' See [`ustfd_endpoints()`] for known endpoints.
#'
#' @param endpoint a string representing a valid endpoint
#'
#' @details The format of a dictionary is a tibble with one row for every field and
#' the following columns:
#'
#'  * `field_name` - the field name recognizable to the API interface
#'  * `label` - a descriptive label
#'  * `data_type` - one of: "DATE", "STRING", "CURRENCY", "NUMBER",
#'   "PERCENTAGE", "YEAR", "QUARTER", "MONTH", "DAY"
#'  * `data_format` - a description of the data format returned by the API
#'
#' @return tibble
#'
#' @export
#'
#' @family ustfd_user
#'
#' @source \url{https://fiscaldata.treasury.gov/api-documentation/#fields-by-endpoint}
#'
#' @examples
#' library(ustfd)
#' ustfd_field_dictionary(ustfd_endpoints()$endpoint[4])
#'
#'
#'
ustfd_field_dictionary <- function(endpoint){
  .ustfd_field_dictionary[[endpoint]]
}
