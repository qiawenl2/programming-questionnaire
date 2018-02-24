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
    mutate(response_str = str_to_lower(response_str)) %>%
    select(subj_id, language_ix, response_str) %>%
    drop_na() %>%
    arrange(subj_id, language_ix)
}


get_language_ratings <- function(responses) {
  question_names <- c("experience", "intuitiveness", "reuse", "practices")
  ratings <- responses %>%
    filter(question_name %in% question_names)

  re_question_rating_str <- "[a-z]+#\\d_Language(\\d)_([A-Za-z]+)"
  labels <- str_match(ratings$question_str, re_question_rating_str)[, 2:3] %>%
    as_data_frame() %>%
    rename(
      language_ix = V1,
      question_tag = V2
    ) %>%
    mutate(language_ix = as.integer(language_ix))
  
  language_names <- get_languages(responses) %>%
    select(subj_id, language_ix, language_name = response_str)
  
  cbind(ratings, labels) %>%
    as_data_frame() %>%
    left_join(language_names) %>%
    select(subj_id, question_str, question_name, language_ix, language_name, question_tag, response_str)
}