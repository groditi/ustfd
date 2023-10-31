#' Return a table of supported and known datasets
#'
#' @description
#'
#' `ustfd_datasets` provides details about 34 known datasets for Fiscal Data.
#' A data frame with 34 rows and the following 7 columns:
#'
#'  * `dataset` - ID of the source dataset (natural key)
#'  * `name` - name of the source dataset
#'  * `summary_text` - description of the data set and the data it covers
#'  * `earliest_date` - the date of the earliest record available for this table
#'  * `data_start_year` - first year in the data set
#'  * `update_frequency` - "Daily", "Monthly", "Quarterly", "Semi-Annually",
#'  "Annually", "As Needed", "Daily (Discontinued)", "Monthly (Discontinued)"
#'  * `notes_and_known_limitations` - notes about
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
#' ustfd_datasets()
#'
#'
#'
ustfd_datasets <- function(){
  return(.dictionaries$datasets)
}

#' Return a table of supported and known tables including the API endpoints
#' for the specified dataset(s). See [`ustfd_datasets()`] for known datasets.
#'
#' @description
#'
#' `ustfd_tables` provides details about 85 known endpoints for Fiscal Data.
#' A data frame with 85 rows and the following 9 columns:
#'
#'  * `dataset` - ID of the source dataset
#'  * `endpoint` - the table's API endpoint (natural key)
#'  * `table_name` - Name of the table within the data set
#'  * `table_description` - a description for the data in the endpoint
#'  * `row_definition` - a description of what each row in the table describes
#'  * `path_name` - API path name
#'  * `date_column` - the name of the table column that holds the record's date
#'  * `earliest_date` - the date of the earliest record available for this table
#'  * `update_frequency` - "Daily", "Monthly", "Quarterly", "Semi-Annually",
#'  "Annually", "As Needed", "Daily (Discontinued)", "Monthly (Discontinued)"
#'
#' @param datasets one or more strings representing a valid dataset ID. If
#' present, only endpoints belonging to matching datasets will be returned
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
#' ustfd_tables(ustfd_datasets()$dataset[2])$endpoint
#'
#'
#'
ustfd_tables <- function(datasets = NULL){
  if(is.null(datasets) ) return(.dictionaries$endpoints)
  dataset <- NULL #make warnings quiet
  dplyr::filter(.dictionaries$endpoints, dataset %in% datasets)
}

#' Return a table of known fields for known endpoints
#'
#' @description
#'
#' `ustfd_table_columns` returns the column dictionaries for the specified endpoint(s).
#' See [`ustfd_tables()`] for known endpoints.
#'
#' @param endpoints one or more strings representing a valid endpoint
#'
#' @details The format of a dictionary is a tibble with one row for every
#' table column and the following columns:
#'
#'  * `endpoint` - the ID of the table this column belongs to
#'  * `colum_name` - the field name recognizable to the API interface
#'  * `data_type` - one of: "DATE", "STRING", "CURRENCY", "NUMBER",
#'   "PERCENTAGE", "YEAR", "QUARTER", "MONTH", "DAY"
#'  * `pretty_name` - a descriptive label
#'  * `definition` -  definition of the colmn's value
#'  * `is_required` - logical value
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
#' ustfd_table_columns(ustfd_tables(ustfd_datasets()$dataset[2])$endpoint)
#'
#'
#'
ustfd_table_columns <- function(endpoints=NULL){
  if(is.null(endpoints) ) return(.dictionaries$fields)
  endpoint <- NULL #make warnings quiet
  dplyr::filter(.dictionaries$fields, endpoint %in% leading_slash(endpoints))
}

#' Tests if an endpoint is known
#'
#' @description
#'
#' See [`ustfd_tables()`] for known endpoints.
#'
#' @param endpoint character vector
#'
#' @return logical matching input size
#'
#' @export
#'
#' @family ustfd_user
#'
#' @examples
#' library(ustfd)
#' endpoint_exists('v2/accounting/od/debt_to_penny')
#'
endpoint_exists <- function(endpoint){
  leading_slash(endpoint) %in% ustfd_tables()$endpoint
}
