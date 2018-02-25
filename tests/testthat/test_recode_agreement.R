context("recode agreement")

labels <- c("Strongly disagree", "Somewhat disagree", "Neither agree nor disagree", "Somewhat agree", "Strongly agree")

test_that("recode agree high", {
  result <- data_frame(response_str = labels) %>%
    recode_agreement()
  expect_equal(result$agreement_num, 1:5)
})

test_that("recode agree low", {
  result <- data_frame(response_str = labels) %>%
    recode_agreement(agree_high = FALSE)
  expect_equal(result$agreement_num, 5:1)
})

test_that("recode custom column", {
  result <- data_frame(custom_response_col = labels) %>%
    recode_agreement(response_str_col = "custom_response_col")
  expect_equal(result$agreement_num, 1:5)
})

test_that("replace response column", {
  result <- data_frame(response_str = labels) %>%
    recode_agreement(replace_with_num = TRUE)
  expect_equal(result$response_str, 1:5)
})

test_that("replace custom response column", {
  result <- data_frame(custom_response_col = labels) %>%
    recode_agreement(response_str_col = "custom_response_col", replace_with_num = TRUE)
  expect_equal(result$custom_response_col, 1:5)
})