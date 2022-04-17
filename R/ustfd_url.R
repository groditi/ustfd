
.base_url <- function(){
  httr::parse_url('https://api.fiscaldata.treasury.gov/services/api/fiscal_service')
}


# lt= Less than
# lte= Less than or equal to
# gt= Greater than
# gte= Greater than or equal to
# eq= Equal to
# in= Contained in a given set
# ?filter=reporting_fiscal_year:in:(2007,2008,2009,2010)
# ?filter=funding_type_id:eq:202

.known_filter_operators <- function(){
  list(
    '<' = 'lt',
    '<=' = 'lte',
    '>' = 'gt',
    '>=' = 'gte',
    '=' = 'eq',
    'in'  = 'in'
  )
}

.serialize_filter_operator <- function(operator, value){
  known_operators <- .known_filter_operators()

  if( !(operator %in% names(known_operators)) )
    stop(paste('Unknown', operator, 'Operator not in:', paste(names(known_operators), collapse=',')))


  serialized_operator <- paste0(':', known_operators[[operator]], ':')
  if(operator == 'in'){
    serialized_value <- paste0('(',paste(value, collapse=','),')')
  } else {
    serialized_value <- value
  }
  return(paste0(serialized_operator, serialized_value))
}

.serialize_filter <- function(filter){
  paste(
    purrr::imap(filter, ~paste0(.y, .serialize_filter_operator(names(.x)[1], .x[[1]]))),
    collapse = ','
  )
}

.serialize_fields <- function(fields){
  paste(fields, collapse=',')
}

.serialize_sort <- function(sort){
  paste(sort, collapse=',')
}

# .serialize_format <- function(format){
#   if(!format %in% c('xml','json','csv'))
#     warning(paste('Format "',format,'" is not supported',sep=''))
#   paste('sort', format, sep='=')
# }

#' Generate URL To Acces US Treasury Fiscal Data API
#'
#' @description
#'
#' `ustfd_url()` will generate a URL suitable for querying the Fiscal Data API.
#'
#' @param query required list
#'
#' @return a httr url object
#'
#' @export
#'
#' @family ustfd_low_level
#'
#' @examples
#'
#' library(ustfd)
#' ustfd_url(ustfd_query('/v1/accounting/dts/dts_table_4'))
#'
#'
ustfd_url <- function(query){

  query_params <- list()

  if(('filter' %in% names(query)) & is.list(query$filter))
    query_params[['filter']] <- .serialize_filter(query$filter)
  if(('fields' %in% names(query)) & length(query$fields) >= 1)
    query_params[['fields']] <- .serialize_fields(query$fields)
  if(('sort' %in% names(query)) & length(query$sort) >= 1)
    query_params[['sort']] <- .serialize_sort(query$sort)
  if('format' %in% names(query))
    query_params[['format']] <- query$format
  if('page_size' %in% names(query) & is.numeric(query$page_size))
    query_params[['page[size]']] <- as.integer(query$page_size)
  if('page_number' %in% names(query) & is.numeric(query$page_number))
    query_params[['page[number]']] <- as.integer(query$page_number)

  query_url <- httr::modify_url(
    url = .base_url(),
    path = c(.base_url()$path, query$endpoint),
    query = query_params
  )
  return(query_url)
}
