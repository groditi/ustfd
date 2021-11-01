
.base_url <- function(){
  httr::parse_url('https://api.fiscaldata.treasury.gov/services/api/fiscal_service')
}

#base_url
#end_point
#

# lt= Less than
# lte= Less than or equal to
# gt= Greater than
# gte= Greater than or equal to
# eq= Equal to
# in= Contained in a given set
# ?filter=reporting_fiscal_year:in:(2007,2008,2009,2010)
# ?filter=funding_type_id:eq:202

.serialize_filter_operator <- function(operator, value){
  serialized_value <- value
  serialized_operator <- paste0(':', operator, ':')
  if(operator == 'in'){
    serialized_value <- paste0('(',paste(value, collapse=','),')')
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
  if('page_size' %in% names(query) )
    query_params[['page[size]']] <- as.integer(query$page_size)
  if('page_number' %in% names(query) )
    query_params[['page[number]']] <- as.integer(query$page_number)

  query_url <- httr::modify_url(
    url = .base_url(),
    path = c(.base_url()$path, query$endpoint),
    query = query_params
  )
  return(query_url)
}

ustfd_request <- function(query, user_agent='http://github.com/groditi/ustfd'){
  response <- httr::GET(URLdecode(ustfd_url(query)), httr::user_agent(user_agent))
  httr::stop_for_status(response)
  if(response$status_code > 200)
    stop(httr::http_status(response)$message)

  return(response)
}

ustfd_json_response <- function(response){
  if(httr::headers(response)[['content-type']] != 'application/json')
    stop(paste(httr::headers(response)[['content-type']], 'is not JSON'))

  parsed <- httr::content(response, as = 'parsed', simplifyVector = FALSE)
  if('error' %in% names(parsed))
    stop(parsed$message)

  date_types <- c('DATE')
  percent_types <- c('PERCENTAGE')
  currency_types <- c('CURRENCY')
  numeric_types <- c('YEAR','DAY','MONTH','QUARTER','NUMBER')

  meta_types <- parsed$meta$dataTypes
  numeric_cols <- names(meta_types[meta_types %in% numeric_types])
  date_cols <- names(meta_types[meta_types %in% date_types])
  percent_cols <-names(meta_types[meta_types %in% percent_types])
  currency_cols <-names( meta_types[meta_types %in% currency_types])

  tib <- dplyr::bind_rows(parsed$data)
  if(length(numeric_cols) >= 1)
    tib <- dplyr::mutate(tib,dplyr::across(numeric_cols, as.numeric))
  if(length(date_cols) >= 1)
    tib <- dplyr::mutate(tib,dplyr::across(date_cols, lubridate::ymd))
  if(length(currency_cols) >= 1)
    tib <- dplyr::mutate(tib,dplyr::across(currency_cols, readr::parse_number))
  if(length(percent_cols) >= 1)
    tib <- dplyr::mutate(tib,dplyr::across(percent_cols, ~readr::parse_number(.x)*.01))

  return(tib)
}

