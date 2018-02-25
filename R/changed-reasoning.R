source("R/question-types.R")

get_changed_reasoning <- function(responses) {
  question_names <- c("cr1", "cr1describe", "cr2")
  changed_reasoning <- responses %>%
    filter(question_name %in% question_names) %>%
    select(subj_id, question_label, response_str) %>%
    spread(question_label, response_str) %>%
    drop_na() %>%
    rename(
      changed_reasoning = changed,
      changed_reasoning_describe = changedDescribe,
      largest_effect = largestEffect
    ) %>%
    recode_agreement(response_str_col = "changed_reasoning")

  changed_reasoning
}