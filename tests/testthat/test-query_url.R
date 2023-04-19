test_that("urls are correct", {



  query1 <- ustfd_query('/v1/accounting/mts/mts_table_1')
  url1 <- ustfd_url(query1)
  query2 <- ustfd_query(
    'v1/accounting/mts/mts_table_1',
    filter = list(record_date = c('>=' = '2012-12-31')),
    sort = 'record_date',
    page_size = 120.0,
    page_number = 50.0,
    fields = c('record_date', 'parent_id', 'current_month_gross_rcpt_amt')
  )
  url2 <- ustfd_url(query2)

  expect_error({
    ustfd_url(
      ustfd_query(
        '/v1/accounting/mts/mts_table_1',
        filter = list(record_date = c('!=' = '2012-12-31'))
      )
    )
  })

  expect_equal(httr::parse_url(url1)$query, list(format = 'json') )
  expect_equal(
    sort(names(httr::parse_url(url2)$query)),
    sort(c(
      names(query2[!names(query2) %in% c('endpoint','page_size','page_number')]),
      'page[size]','page[number]'
      )
    )
  )

  expect_equal(httr::parse_url(url2)$query$'page[size]', as.character(query2$page_size) )
  expect_equal(httr::parse_url(url2)$query$'page[number]', as.character(query2$page_number) )
  expect_equal(httr::parse_url(url2)$query$filter, 'record_date:gte:2012-12-31' )
  expect_equal(httr::parse_url(url2)$query$sort, query2$sort )
  expect_equal(httr::parse_url(url2)$query$fields, paste(query2$fields, collapse=','))

  query3 <- ustfd_query(
    '/v1/accounting/mts/mts_table_1',
    filter = list(
      record_date = c('>=' = '2015-12-31'),
      record_date = c('<=' = '2016-12-31')
      ),
    sort = c('record_date', 'parent_id'),
  )
  url3 <- ustfd_url(query3)

  expect_equal(httr::parse_url(url3)$query$sort, paste(query3$sort, collapse=','))
  expect_equal(httr::parse_url(url3)$query$filter, 'record_date:gte:2015-12-31,record_date:lte:2016-12-31')

})
