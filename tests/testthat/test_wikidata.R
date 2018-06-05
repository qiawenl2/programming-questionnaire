context("programming languages")

test_that("expected languages are found", {
  tests <- list(
      "asp.net" = "Q178817",
          "sql" = "Q47607",
   "javascript" = "Q2005"
  )
  for (name in names(tests)) {
    wikidata_item <- get_programming_language(name)
    expect_equal(wikidata_item$id, tests[[name]])
  }
})

test_that("not real languages are not found", {
  tests <- c(
    "pt-br"
  )
  for (name in tests) {
    expect_error(get_programming_language(name))
  }
})

context("programming paradigms")

test_that("expected paradigms are found", {
  tests <- list(
    "python" = c("imperative programming"),
    "javascript" = c("functional programming")
  )
  for (name in names(tests)) {
    programming_paradigms <- get_programming_paradigms(name)
    expect_true(all(tests[[name]] %in% programming_paradigms))
  }
})