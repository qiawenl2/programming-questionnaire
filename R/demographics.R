# responses <- get_qualtrics_responses("programming questionnaire", force_request = TRUE) %>% tidy_qualtrics()

get_demographics <- function(responses) {
  question_names <- c("ageLearn", "gender", "isNative", "nativeLanguages", "otherLanguages", "age", "education", "undergrad", "employment", "employment_other")
  
  demographics <- responses %>%
    filter(question_name %in% question_names) %>%
    select(-question_str, -question_label) %>%
    drop_na() %>%
    spread(question_name, response_str) %>%
    rename(
      age_learn = AgeLearn,
      gender = gender,
      native_english = isNative,
      native_languages = nativeLanguages,
      other_languages = other_languages
    ) %>%
    mutate(
      age_learn = as.numeric(age_learn)
    )
  
  demographics
}