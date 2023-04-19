#' Form a Query
#'
#' @description
#'
#' `ustfd_query()` will verify the endpoint is valid and return a list suitable
#' for passing to [ustfd_url()] and [ustfd_request()].
#'
#' @param endpoint required string representing an API endpoint
#' @param filter optional list used to subset the data. known filter operators
#' are '>', '>=', '<', '<=', '=', and 'in'
#' @param fields optional string vector of the fields to be retrieved
#' @param sort optional string or string vector. Ordering defaults to ascending,
#' to specify descending order precede the field name with '-'
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
