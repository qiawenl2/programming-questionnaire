# Get languages represented in the survey
get_languages <- function(responses) {
  language_questions <- unique(responses$question_label) %>%
    grep("^languages", x = ., value = TRUE)
  language_ixs <- as.integer(str_match(language_questions, "languages-Language (\\d)")[,2])

  question_label_map <- data_frame(
    question_label = language_questions,
    language_ix = language_ixs
  )
  
  responses %>%
    filter(question_label %in% language_questions) %>%
    left_join(question_label_map) %>%
    select(subj_id, language_ix, response_str) %>%
    arrange(subj_id, language_ix)
}
