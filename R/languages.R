source("R/question-types.R")

# Get languages represented in the survey
get_languages <- function(responses) {
  language_questions <- unique(responses$question_label) %>%
    grep("^languages", x = ., value = TRUE)
  language_ixs <- str_match(language_questions, "languages-Language (\\d)")[,2] %>%
    as.integer()

  question_label_map <- data_frame(
    question_label = language_questions,
    language_ix = language_ixs
  )
  
  languages <- responses %>%
    filter(question_label %in% language_questions) %>%
    left_join(question_label_map) %>%
    mutate(response_str = str_to_lower(response_str)) %>%
    select(subj_id, language_ix, response_str) %>%
    drop_na() %>%
    arrange(subj_id, language_ix)
  
  experience <- responses %>%
    filter(question_name == "experience") %>%
    match_language_question_str() %>%
    select(subj_id, language_ix, question_tag, response_str) %>%
    arrange(subj_id, question_tag, language_ix) %>%
    drop_na() %>%
    spread(question_tag, response_str) %>%
    rename(
      age_started = age,
      years_used = years
    ) %>%
    mutate(
      age_started = as.integer(age_started),
      years_used = as.integer(years_used)
    ) %>%
    recode_agreement(response_str_col = "proficiency") %>%
    select(-proficiency, -agreement_label) %>%
    rename(proficiency = agreement_num)

  languages <- left_join(languages, experience)
  
  languages
}


get_language_ratings <- function(responses) {
  question_names <- c("intuitiveness", "reuse", "practices")
  ratings <- responses %>%
    filter(question_name %in% question_names) %>%
    match_language_question_str()

  language_names <- get_languages(responses) %>%
    select(subj_id, language_ix, language_name = response_str)

  ratings %>%
    left_join(language_names) %>%
    select(subj_id, question_name, language_ix, language_name, question_tag, agreement_str = response_str) %>%
    arrange(question_name, question_tag, subj_id, language_ix) %>%
    recode_agreement("agreement_str")
}


match_language_question_str <- function(frame) {
  re_language_question <- "[a-z]+#\\d_Language(\\d)_([A-Za-z]+)"
  labels <- str_match(frame$question_str, re_language_question)[, 2:3] %>%
    as_data_frame() %>%
    rename(
      language_ix = V1,
      question_tag = V2
    ) %>%
    mutate(language_ix = as.integer(language_ix))
  cbind(frame, labels) %>%
    as_data_frame()
}
