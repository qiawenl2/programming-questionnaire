
get_stack_overflow <- function() {
  responses <- readr::read_csv("data-raw/stack-overflow-developer-survey-2017/survey_results_public.csv")
  languages <- responses %>%
    select(Respondent, HaveWorkedLanguage) %>%
    mutate(Language = str_split(HaveWorkedLanguage, "; ")) %>%
    select(Respondent, Language) %>%
    unnest() %>%
    drop_na() %>%
    mutate(Language = str_to_lower(Language)) %>%
    rename(respondent = Respondent, language_name = Language)
  languages
}
