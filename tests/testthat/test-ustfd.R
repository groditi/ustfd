test_that("dictionaries work", {
  expect_equal(
    ustfd_table_columns(sort(ustfd_tables()$endpoint)[13])$column_name[1],
    'record_date'
  )

  expect_equal(
    ustfd:::leading_slash('/v2/accounting/od/debt_to_penny'),
    'v2/accounting/od/debt_to_penny'
  )

  expect_equal(
    ustfd:::leading_slash(c('/a/b/c', 'a/b/c')),
    c('a/b/c', 'a/b/c')
  )

  expect_equal(
    endpoint_exists(c('v2/accounting/od/debt_to_penny','v2/accounting/od/debt_to_penny/dfggh')),
    c(TRUE, FALSE)
  )
})
