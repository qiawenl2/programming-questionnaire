source("R/question-types.R")

get_questionnaire <- function(responses) {
  agreement_questions <- c(
    "cr1", "cp1", "repo1", "rec1", "cfo1", "cfo2", "cfo3",
    "oss1", "oss2", "env1", "env2", "inter1", "inter2", "inter3"
  )
  free_response_questions <- c(
    "cr1describe", "cr2describe", "cp1describe",
    "repo1describe", "rec1describe",
    "fp1describe", "pipe1describe",
    "cfo3", "oss2", "inter3", "fp5",
    "pa1example",
    "best",
    "design1", "recursive", "metaphor", "history",
    "design2", "reusable", "challenges", "nontransfer"
  )
  question_names <- c(agreement_questions, free_response_questions)

  questionnaire <- responses %>%
    filter(question_name %in% question_names) %>%
    select(subj_id, question_name, response_str) %>%
    spread(question_name, response_str) %>%
    recode_all_agreement(agreement_questions)

  questionnaire[c("subj_id", question_names)]  # reorder columns
}

get_question_text <- function(name) {
  e_ <- new.env()
  data("questions", package = "programmingquestionnaire", envir = e_)
  filter(e_$questions, question_name == name)$question_text
}

create_wrapped_title <- function(name) {
  get_question_text(name) %>%
    strwrap(50) %>%
    paste(collapse = "\n")
}