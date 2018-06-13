#' Recode string responses to a multiple choice question.
recode_multiple_choice <- function(frame, question_name, choices, ints = NULL) {
  if(is.null(ints)) ints <- seq_along(choices)
  choice_map <- data_frame(
    response_num = ints,
    response_label = factor(choices, levels = choices)
  )
  choice_map[question_name] <- choice_map$response_label
  
  if(missing(frame)) return(choice_map)
  
  frame[question_name] <- factor(frame[question_name], levels = choices)
  result <- left_join(frame, choice_map)
  question_name_int <- paste(question_name, "int", sep = "_")
  result[question_name_int] <- result$response_num
  result <- select(result, -response_num, -response_label)
  result
}

# Recode agreement from response text to agreement
recode_agreement <- function(frame, response_str_col = "response_str", agree_high = TRUE, replace_with_num = FALSE) {
  levels <- c("Strongly disagree", "Somewhat disagree", "Neither agree nor disagree", "Somewhat agree", "Strongly agree")
  if(!agree_high) levels <- rev(levels)
  
  agreement_map <- data_frame(
    agreement_num = seq_along(levels),
    agreement_label = factor(levels, levels = rev(levels))
  )
  agreement_map[response_str_col] <- levels
  
  if(missing(frame)) return(agreement_map)

  result <- left_join(frame, agreement_map)

  if(replace_with_num) {
    result[response_str_col] <- result$agreement_num
    result <- select(result, -agreement_num, -agreement_label)
  }

  result
}

# Recode a bunch of agreement columns, replacing each with a number.
recode_all_agreement <- function(frame, agreement_cols) {
  for(response_str_col in agreement_cols) {
    frame <- recode_agreement(frame, response_str_col, replace_with_num = TRUE)
  }
  frame
}

recode_all_agreement_other <- function(frame) {
  frame %>%
    recode_oss1() %>%
    recode_fp3() %>%
    recode_fp4() %>%
    recode_psych()
}

recode_agreement_other <- function(frame, question_name, other_answer_text, other_answer_value = NA) {
  agreement_levels <- c("Strongly disagree", "Somewhat disagree", "Neither agree nor disagree", "Somewhat agree", "Strongly agree")
  agreement_other_levels <- c(agreement_levels, other_answer_text)
  
  agreement_other_map <- data_frame(
    agreement_num = c(seq_along(agreement_levels), other_answer_value),
    agreement_label = factor(agreement_other_levels, levels = agreement_other_levels)
  )
  agreement_other_map[question_name] <- agreement_other_map$agreement_label
  
  if(missing(frame)) return(agreement_other_map)
  frame[question_name] <- factor(frame[question_name], levels = agreement_other_levels)
  result <- left_join(frame, agreement_other_map)
  question_name_int <- paste(question_name, "int", sep = "_")
  result[question_name_int] <- result$agreement_num
  result <- select(result, -agreement_num, -agreement_label)
  result
}

recode_oss1 <- function(frame) {
  other_answer_text <- "I don't know enough about open source languages to answer the question"
  recode_agreement_other(frame, "oss1", other_answer_text)
}

recode_fp3 <- function(frame) {
  other_answer_text <- "I don't know enough about functional programming to answer the question"
  recode_agreement_other(frame, "fp3", other_answer_text)
}

recode_fp4 <- function(frame) {
  other_answer_text <- "I don't know enough about functional programming to answer the question"
  recode_agreement_other(frame, "fp4", other_answer_text)
}

recode_psych <- function(frame) {
  other_answer_text <- "They already do!"
  recode_agreement_other(frame, "psych", other_answer_text, other_answer_value = 6)
}

recode_all_multiple_choice <- function(frame) {
  frame %>%
    recode_fp1() %>%
    recode_pipe1() %>%
    recode_computer()
}



recode_fp1 <- function(frame) {
  fp1_choices <- c("Program 1 much better",
                   "Program 1 somewhat better",
                   "Both the same",
                   "Program 2 somewhat better",
                   "Program 2 much better")
  recode_multiple_choice(frame, "fp1", fp1_choices)
}

recode_pipe1 <- function(frame) {
  pipe1_choices <- c("Piping much better",
                     "Piping somewhat better",
                     "Both are identical",
                     "Traditional composition somewhat better",
                     "Traditional composition much better",
                     "I don't know enough about piping to answer this question")
  pipe1_ints <- c(-2:2, NA)
  recode_multiple_choice(frame, "pipe1", pipe1_choices, pipe1_ints)
}

recode_computer <- function(frame) {
  computer_choices <- c("(1)  I never think of programming as instructing a person",
                        "(2)",
                        "(3)",
                        "(4)",
                        "(5) I always think of programming as instructing a person")
  recode_multiple_choice(frame, "computer", computer_choices)
}