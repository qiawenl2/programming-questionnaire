# responses <- get_qualtrics_responses("programming questionnaire", force_request = TRUE) %>% tidy_qualtrics()

get_demographics <- function(responses) {
  question_names <- c("ageLearn", "gender", "isNative", "nativeLanguages", "otherLanguages", "age", "education", "undergrad", "employment", "employmentOther")
  
  demographics <- responses %>%
    filter(question_name %in% question_names) %>%
    select(-question_str, -question_label) %>%
    drop_na()
  
  demographics %>%
    group_by(subj_id, question_name) %>%
    summarize(response_str = paste(response_str, collapse = ",")) %>%
    spread(question_name, response_str) %>%
    rename(
      age_learn = ageLearn,
      gender = gender,
      native_english = isNative,
      native_languages = nativeLanguages,
      other_languages = otherLanguages
    ) %>%
    mutate(
      age = as.integer(age),
      age_learn = as.integer(age_learn)
    )
}