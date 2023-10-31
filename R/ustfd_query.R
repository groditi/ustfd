#' Request filtered API results
#'
#' @description
#' Fiscal Data API allows for the filtering of results on the server side,
#' leading to a smaller payload. The combinations of fields and operators
#' supported are not currently defined, so it is suggested you test the desired
#' combinations before relying on them.
#'
#' @section Syntax:
#' A filter should be a named list of key-value pairs where the name corresponds
#' to the field that should be filtered and the value is a character vector or a
#' list where the name of an item corresponds to the operator and the value
#' corresponds to the operand. One field may have more than one filter.
#'
#' @section Operators:
#'  - `>`, `<`  Greater-than and lesser-than
#'  - `>=`, `<=`  Greater-/lesser-than or equal-to
#'  - `=`  Equal to
#'  - `in`  Subset-of
#'
#' @examples
#' \dontrun{
#'  #records with a record_date no older than 10 days ago
#'  list(record_date = c('>=' = lubridate::today()-10))
#'
#'  #records with a record_date between two dates
#'  list(
#'    record_date = c('>=' = '2022-01-01'),
#'    record_date = c('<=' = '2022-12-31')
#'  )
#'
#'  #records with a specific record_date
#'  list(record_date = c('=' = lubridate::today()-2))
#'
#'  #records where record_date is any of a set of specific dates
#'  list(
#'    record_date = list('in' = c('2022-06-13','2022-06-15','2022-06-17')
#'  )
#' }
#'
#' @name filter-syntax
NULL

#' Form a Query
#'
#' @description
#'
#' `ustfd_query()` will verify the endpoint is valid and return a list suitable
#' for passing to [ustfd_url()] and [ustfd_request()].
#'
#' @param endpoint required string representing an API endpoint
#' @param filter optional list used to subset the data. See [filter-syntax] for
#' more information.
#' @param fields optional character vector of the fields to be retrieved
#' @param sort optional string or character vector. Ordering defaults to
#' ascending, to specify descending order precede the field name with '-'
#' @param page_size optional integer for pagination
#' @param page_number optional integer for pagination
#'
#' @return a list
#'
#' @export
#'
#' @family ustfd_user
#'
#' @examples
#'
#' library(ustfd)
#' ustfd_query(
#'   'v2/accounting/od/utf_qtr_yields',
#'    filter = list(record_date = c('>=' = lubridate::today()-10))
#' )
#' ustfd_query(
#'   'v2/accounting/od/utf_qtr_yields',
#'    filter = list(record_date = list('in' = c('2020-03-15','2020-03-16','2020-03-17')))
#' )
#' ustfd_query(
#'   'v2/accounting/od/utf_qtr_yields',
#'    filter = list(record_date = c('=' = '2020-03-15'))
#' )
#'
#'
#'
ustfd_query <- function(endpoint, filter=NULL, fields=NULL, sort=NULL, page_size=NULL, page_number=NULL){
  endpoint <- leading_slash(endpoint)
  if(! endpoint_exists(endpoint))
    rlang::warn(paste0('Endpoint "', endpoint,'" not known. see data ustfd_tables.'))

  query <- list(
    format = 'json',
    filter = filter,
    fields = fields,
    sort = sort,
    endpoint = endpoint,
    page_size = page_size,
    page_number = page_number
  )

  return(purrr::compact(query[!is.na(query)]))
}

leading_slash <- function(endpoints){
  idx <- which(substr(endpoints,1,1) == '/')
  endpoints[idx] <- substr(endpoints[idx], 2, nchar(endpoints[idx]))
  return(endpoints)
}
