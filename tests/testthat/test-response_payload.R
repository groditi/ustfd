
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
