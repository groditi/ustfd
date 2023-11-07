
#' Retrieve multiple pages of Fiscal Data API in a single call
#'
#' @description
#'
#' `ustfd_all_pages()` is similar to `ustfd_simple()` with the difference that,
#' for requests that generate multiple pages of results, it will request all
#' pages and merge them into a single result.
#'
#' While care has been taken to optimize `ustfd_all_pages()`, for requests
#' spanning more than 10 pages you should consider breaking up the call further
#' if memory use is a concern, especially if you are writing the results to disk
#' or a database with atomic transactions.
#'
#' @inheritParams ustfd_query
#' @inheritParams ustfd_request
#' @param slowly pause between http requests when set to `TRUE`
#' @param pause length, in seconds, to pause
#' @param quiet when set to `FALSE` updates will be output via a message
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
    endpoint, filter=NULL, fields=NULL, sort=NULL, page_size=10000L,
    slowly = FALSE, pause = 0.25, quiet = TRUE,
    user_agent='http://github.com/groditi/ustfd'
){

  paged_request <- function(page_number){
    if( !quiet )
      rlang::inform(glue::glue("Requesting {endpoint} page {page_number}"))

    ustfd_request(
      ustfd_query(
        endpoint = endpoint,
        filter = filter,
        fields = fields,
        sort = sort,
        page_size = page_size,
        page_number = page_number
      ),
      user_agent
    )
  }

  if( slowly ){
    rate <- purrr::rate_delay(pause)
    paged_request <- purrr::slowly(paged_request, rate = rate, quiet = quiet)
  }

  keep <- c('labels', 'dataTypes', 'dataFormats','total-count','total-pages')
  page <- paged_request(1)
  meta <- page$meta[keep]

  idx_start <- 1
  idx_end <- length(page$data)
  all_records <- vector(mode='list', length = meta$`total-count`)
  all_records[idx_start:idx_end] <- page$data
  rm(page)

  if((page_count <- meta$`total-pages`) > 1){
    for(page_num in 2:page_count){
      page_data <- paged_request(page_num)$data
      idx_start <- idx_end + 1
      idx_end <- idx_end + length(page_data)

      all_records[idx_start:idx_end] <- page_data
    }
  }

  parsed <- parsed_payload(all_records, meta$dataTypes)
  return(
    list(
      meta = meta,
      data = parsed
    )
  )
}


