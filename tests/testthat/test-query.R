


test_that("warnings work", {
  expect_warning({ustfd_query(endpoint = 'asdfghj')})
  expect_silent( { ustfd_query('/v1/accounting/mts/mts_table_1') } )
})

test_that("params are populated", {
  query1 <- ustfd_query('v1/accounting/mts/mts_table_1')
  expects1 <- list(
    endpoint = 'v1/accounting/mts/mts_table_1',
    format = 'json'
  )
  query2 <- ustfd_query(
    '/v1/accounting/mts/mts_table_1',
    filter = list(record_date = c('>=' = lubridate::today()-10)),
    sort = 'record_date',
    page_size = 120,
    page_number = 50,
    fields = c('record_date', 'parent_id', 'current_month_gross_rcpt_amt')
  )
  expects2 <- list(
    format = 'json',
    endpoint = 'v1/accounting/mts/mts_table_1',
    filter = list(record_date = c('>=' = lubridate::today()-10)),
    fields = c('record_date', 'parent_id', 'current_month_gross_rcpt_amt'),
    sort = 'record_date',
    page_number = 50,
    page_size = 120
  )

  expect_equal(sort(names(query1)), sort(names(expects1)))
  expect_equal(query1[names(query1)], expects1[names(query1)])
  expect_equal(sort(names(query2)), sort(names(expects2)))
  expect_equal(query2[names(query2)], expects2[names(query2)])

})
