# ---- free-responses ----
library(tidyverse)
library(magrittr)

library(programmingquestionnaire)
data("questions")
data("questionnaire")

free_response_question_names <- c(
  "cr1describe", "cr2describe", "cp1describe",
  "repo1describe", "rec1describe",
  "fp1describe", "pipe1describe",
  "cfo3", "oss2", "inter3", "fp5",
  "pa1example",
  "best",
  "design1", "recursive", "metaphor", "history",
  "design2", "reusable", "challenges", "nontransfer"
)

get_question_text <- function(name) {
  filter(questions, question_name == name)$question_text
}