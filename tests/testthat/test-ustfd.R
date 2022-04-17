test_that("dictionaries work", {
  expect_equal(
    ustfd_field_dictionary(sort(ustfd_endpoints()$endpoint)[13])$field_name[1],
    'record_date'
    )
})
