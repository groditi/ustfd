
test_that("payload reading works", {
  expect_silent({
    json_response <- jsonlite::fromJSON(
      testthat::test_path('sample-response.json'),
      simplifyVector = FALSE
    )
  })
})

test_that('meta processing works', {
  json_response <- jsonlite::fromJSON(
    testthat::test_path('sample-response.json'),
    simplifyVector = FALSE
  )

  expect_silent({
    meta <- ustfd_response_meta_object(json_response)
  })
})

test_that('payload processing works', {
  json_response <- jsonlite::fromJSON(
    testthat::test_path('sample-response.json'),
    simplifyVector = FALSE
  )

  #more useful output than expect_silent
  expect_message(
    {payload <- ustfd_response_payload(json_response)},
    NA
  )

})

test_that('graceful zero record payload', {
  json_response <- jsonlite::fromJSON(
    testthat::test_path('sample-response.json'),
    simplifyVector = FALSE
  )

  zero_record_response <- json_response
  zero_record_response$data <- list()
  zero_record_response$meta$count <- 0

  expect_equal(
    names(ustfd_response_payload(json_response)),
    names(ustfd_response_payload(zero_record_response))
  )
  #more useful output than expect_silent
  expect_message(
    {dplyr::union_all(
      ustfd_response_payload(json_response),
      ustfd_response_payload(zero_record_response)
    )},
    NA
  )

})
