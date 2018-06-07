context("Remove html tags")

example_question_text_with_html <- "<p>Are there certain design features of a programming language that you wish your favorite language had that would make you more productive?<o:p></o:p></p>"
example_question_text_without_html <- "Are there certain design features of a programming language that you wish your favorite language had that would make you more productive?"

test_that("html tags are removed from from a string", {
  cleaned <- remove_html(example_question_text_with_html)
  expect_equal(cleaned, example_question_text_without_html)
})

test_that("html tags are removed from from a vector of strings", {
  cleaned <- remove_html(rep(example_question_text_with_html, 10))
  expect_equal(cleaned, rep(example_question_text_without_html, 10))
})