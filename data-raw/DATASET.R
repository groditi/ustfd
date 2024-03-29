
datasets <- ustfd:::get_ustfd_datasets()
.dictionaries <- ustfd:::extract_ustfd_dictionaries(datasets)

usethis::use_data(.dictionaries, internal = TRUE, overwrite = TRUE)

csv_path <- fs::path('./', 'data-raw')
purrr::imap(
  .dictionaries,
  ~readr::write_csv(
    .x,
    fs::path(csv_path, fs::path_ext_set(paste0(.y,'-dictionary'), 'csv'))
  )
)

#.ustfd_endpoints <- readr::read_csv('data-raw/fiscal_data_endpoints.csv')

find_fields <- function(endpoint){
  json_response <- ustfd_request(ustfd_query(endpoint))
  meta <- ustfd_response_meta_object(json_response)
  dplyr::select(
    dplyr::bind_rows( purrr::imap(
      purrr::transpose(meta[c(2, 3, 4)]),
      ~ c(.x, field_name = .y)
    ) ),
    field_name, label = 'labels', data_type = 'dataTypes', data_format = 'dataFormats'
  )
}


test_json <- ustfd_request(
  ustfd_query(
    'v1/accounting/mts/mts_table_5',
    fields = c(
      'record_date', 'classification_desc', 'current_month_gross_outly_amt',
      'current_fytd_gross_outly_amt', 'prior_fytd_gross_outly_amt' ,'sequence_number_cd'
    ),
    filter = list(
      record_date = c('>' = '2020-12-31'),
      record_date = c('<=' = '2021-12-31'),
      sequence_number_cd = list('in' = c('16.7.5','16.7.6','16.7.7','16.7.8'))
    ),
    page_size=500
  ),
  process_response = purrr::partial(httr::content, as='text')
)

write(
  test_json,
  file = testthat::test_path('sample-response.json')
)

