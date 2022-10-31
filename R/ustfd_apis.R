root_api_url <- 'https://fiscaldata.treasury.gov/page-data'

fd_url <- function(path){
  url <- httr::parse_url(root_api_url)
  httr::modify_url(url, path = c(url$path, path))
}

get_ustfd_datasets <- function(){
  url <- fd_url('sq/d/707360527.json')
  res <- httr::GET(url)
  datasets <- purrr::pluck(httr::content(res), 'data','allDatasets','datasets')
  slugs <- purrr::map_chr(datasets, 'slug')
  dataset_names <- stringr::str_extract(slugs, '[\\w-]+')

  purrr::map(
    purrr::set_names(datasets, dataset_names),
    ~purrr::list_modify(.x, dataset = .x$slug, slug = purrr::zap()),
  )
}

get_ustfd_dataset_definition <- function(dataset){
  path <- c('datasets', dataset, 'page-data.json')
  #return(fd_url(path))
  definition <- httr::content(httr::GET(fd_url(path)))
  return(definition$result$pageContext$config)
}

# extract_ustfd_endpoints_table <- function(datasets){
#   apis <- purrr::map(datasets, 'apis')
#   endpoints <- purrr::reduce(purrr::imap(apis, ~lapply(.x, c, dataset =.y)), c)
#   dplyr::select(
#     purrr::list_rbind(endpoints),
#     dataset, endpoint, name = 'tableName', description = 'tableDescription'
#   )
# }

extract_ustfd_datatset_definitions <- function(dataset_definition){
  page_context <- dataset_definition[c(
    'dataStartYear', 'name', 'summaryText',
    'notesAndKnownLimitations', 'techSpecs'
  )]
  page_context[['dataset']] <- dataset_definition$slug

  api_list <- purrr::map(
    dataset_definition$apis,`[`,
    c('dateField', 'earliestDate', 'endpoint', 'fields', 'lastUpdated',
    'latestDate', 'pathName', 'rowDefinition', 'tableDescription',
    'tableName','updateFrequency')
  )
  names(api_list) <- purrr::map_chr(api_list, 'endpoint')
  page_context[['apis']] <- api_list

  return(page_context)
}

extract_ustfd_dictionaries <- function(datasets){
  dataset_names <- purrr::set_names(as.list(names(datasets)), names(datasets))
  raw_definitions <- lapply(dataset_names, get_ustfd_dataset_definition)
  definitions <- lapply(raw_definitions, extract_ustfd_datatset_definitions)

  dataStartYear <- isRequired <- earliestDate <- dataset <- dateField <- updateFrequency <- NULL
  definitions <- purrr::map(
    definitions,
    ~purrr::list_modify(
      .x,
      !!!.x$techSpecs[c('earliestDate','updateFrequency')],
      techSpecs = purrr::zap()
    )
  )
  definitions_df <- dplyr::mutate(
    dplyr::bind_rows(
      purrr::map(definitions, purrr::list_modify, apis = purrr::zap())
    ),
    dataStartYear = as.integer(dataStartYear),
    earliestDate = lubridate::mdy(earliestDate),
    dataset = stringr::str_extract(dataset, '[\\w-]+'),
    updateFrequency = stringr::str_match(
      updateFrequency, '(?:Updated )([\\w-\\(\\) ]+)'
    )[,2]
  )

  apis <- purrr::map(
    purrr::map(definitions, 'apis'),
    ~purrr::set_names(.x, purrr::map_chr(.x, 'endpoint'))
  )
  reduced_apis <- purrr::reduce(
    purrr::imap(apis, ~purrr::map(.x, purrr::list_modify, dataset = .y) ),
    c
  )
  apis_df <- dplyr::mutate(
    dplyr::bind_rows(
      purrr::map(
        reduced_apis,
        purrr::list_modify,
        fields = purrr::zap(), lastUpdated = purrr::zap(), latestDate = purrr::zap()
      )
    ),
    earliestDate = lubridate::ymd(earliestDate),
    date_column = dateField
  )

  fields <- purrr::imap(
    purrr::map(reduced_apis, 'fields'),
    ~purrr::map(.x, purrr::list_modify, endpoint = .y)
  )

  fields_df <- dplyr::mutate(
    dplyr::bind_rows(purrr::reduce(fields, c)),
    isRequired = as.logical(isRequired)
  )


  dictionary_orders <- list(
    datasets = c(
      'dataset', 'name', 'summary_text', 'earliest_date', 'data_start_year',
      'update_frequency', 'notes_and_known_limitations'
    ),
    endpoints = c(
      'dataset', 'endpoint', 'table_name', 'table_description', 'row_definition',
      'path_name', 'date_column', 'earliest_date', 'update_frequency'
    ),
    fields = c(
      'endpoint', 'column_name', 'data_type', 'pretty_name', 'definition',
      'is_required'
    )
  )

  dictionaries <- purrr::imap(
    purrr::map(
      list(datasets = definitions_df, endpoints = apis_df, fields = fields_df),
      dplyr::rename_with,
      snakecase::to_snake_case
    ),
    ~dplyr::select(.x, dplyr::all_of(dictionary_orders[[.y]]))
  )

  return(dictionaries)
}


