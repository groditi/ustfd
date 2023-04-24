
#' Retrieve multiple pages of Fiscal Data API in a single call
#'
#' @description
#'
#' `ustfd_all_pages()` is similar to `ustfd_simple()` with the difference that,
#' for requests that generate multiple pages of results, it will request all
#' pages and merge them into a single result.
#'
#' @param endpoint required string representing an API endpoint
#' @param filter optional list used to subset the data. known filter operators
#' are '>', '>=', '<', '<=', '=', and 'in'
#' @param fields optional string vector of the fields to be retrieved
#' @param sort optional string or string vector. Ordering defaults to ascending,
#' to specify descending order precede the field name with '-'
#' @param page_size optional integer for pagination
#' @param slowly pause between http requests when set to `TRUE`
#' @param pause length, in seconds, to pause
#' @param quiet when set to `FALSE` updates will be output via a message
#' @param user_agent optional string
#'
#' @return a list containing the following items
#'  * `meta` - the metadata returned by the API
#'  * `data` - the payload returned by the API in table form.
#'  See [`ustfd_response_payload()`]
#'
#' @export
#'
#' @family ustfd_user
#'
#' @examples
#' \dontrun{
#' library(ustfd)
#'
#' exchange_rates <- ustfd_all_pages(
#'   'v1/accounting/od/rates_of_exchange',
#'    fields = c(
#'     'country_currency_desc', 'exchange_rate','record_date','effective_date'
#'    ),
#'    filter = list(
#'      record_date = c('>=' = '2020-01-01'),
#'      country_currency_desc = list('in' = c('Canada-Dollar','Mexico-Peso'))
#'    )
#' )
#' }
ustfd_all_pages <- function(
    endpoint, filter=NULL, fields=NULL, sort=NULL, page_size=10000,
    slowly = FALSE, pause = 0.25, quiet = TRUE,
    user_agent='http://github.com/groditi/ustfd'
){

  message <- "Requesting {endpoint} page {page_number} of {page_count}"
  get_page <- function(page_number, page_count){
    if( !quiet ) rlang::inform(glue::glue(message))
    query <- ustfd_query(
      endpoint = endpoint,
      filter = filter,
      fields = fields,
      sort = sort,
      page_size = page_size,
      page_number = page_number
    )
    ustfd_request(query, user_agent)
  }

  if( slowly ){
    rate <- purrr::rate_delay(pause)
    get_page <- purrr::slowly(get_page, rate = rate, quiet = quiet)
  }

  pages <- list(get_page(1, '?'))
  record_count <- pages[[1]]$meta$`total-count`
  page_count <- pages[[1]]$meta$`total-pages`
  if (page_count > 1)
    pages <- append(pages, purrr::map(seq(2, page_count), get_page, page_count))

  all_records <- purrr::list_flatten(purrr::map(pages, 'data'))
  if(record_count != length(all_records))
    rlang::abort('record_count mismatch')

  all_data <- parsed_payload(all_records, pages[[1]]$meta$dataTypes)
  keep <- c('labels', 'dataTypes', 'dataFormats','total-count','total-pages')

  return(
    list(
      meta = pages[[1]]$meta[keep],
      data = all_data
    )
  )
}


