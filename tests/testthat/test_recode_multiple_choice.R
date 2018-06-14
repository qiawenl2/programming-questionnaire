library(dplyr)

context("Recode multiple choice questions")

result <- data_frame(response = c("A", "B", "C")) %>%
  recode_multiple_choice("response", choices = c("C", "B", "A"))

test_that("response strings are converted to factors", {
  expect_equal(levels(result$response), c("C", "B", "A"))
})

test_that("response strings are converted to factors", {
  expect_equal(result$response_int, c(3, 2, 1))
})

context("Recode multiple choice with missing")

test_that("choice levels are not dropped", {
  result <- data_frame(response = c("A", "B", NA)) %>%
    recode_multiple_choice("response", choices = c("C", "B", "A"))
  
  expect_equal(as.character(result$response), c("A", "B", NA))
  expect_equal(levels(result$response), c("C", "B", "A"))
})