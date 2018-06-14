#' Recode string responses to a multiple choice question.
recode_multiple_choice <- function(frame, question_name, choices, ints = NULL) {
  if(is.null(ints)) ints <- seq_along(choices)
  choice_map <- data_frame(
    response_num = ints,
    response_label = factor(choices, levels = choices)
  )
  choice_map[question_name] <- choice_map$response_label
  
  if(missing(frame)) return(choice_map)
  
  # Overwrite response column
  frame[question_name] <- factor(frame[[question_name]], levels = choices)

  result <- left_join(frame, choice_map)
  question_name_int <- paste(question_name, "int", sep = "_")
  result[question_name_int] <- result$response_num
  result <- select(result, -response_num, -response_label)
  result
}

# Recode all agreement questions
recode_all_agreement <- function(frame, agreement_cols) {
  agreement_questions <- c(
    "cr1", "cp1", "repo1", "rec1", "cfo1", "cfo2",
    "env1", "env2", "inter1", "inter2", "pa1"
  )
  
  agreement_levels <- c("Strongly disagree",
                        "Somewhat disagree",
                        "Neither agree nor disagree",
                        "Somewhat agree",
                        "Strongly agree")
  for(response_str_col in agreement_questions) {
    frame <- recode_multiple_choice(frame, response_str_col, choices = agreement_levels)
  }
  
  frame
}

# Recode all agreement questions with custom "other" option
recode_all_agreement_other <- function(frame) {
  recode_agreement_other <- function(frame, question_name, other_answer_text, other_answer_value = NA) {
    agreement_levels <- c("Strongly disagree", "Somewhat disagree", "Neither agree nor disagree", "Somewhat agree", "Strongly agree")
    agreement_other_levels <- c(agreement_levels, other_answer_text)
    agreement_other_ints <- c(1:5, NA)
    recode_multiple_choice(frame, question_name, agreement_other_levels, agreement_other_ints)
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
  
  frame %>%
    recode_oss1() %>%
    recode_fp3() %>%
    recode_fp4() %>%
    recode_psych()
}

# Recode multiple choice questions with custom choices
recode_all_multiple_choice <- function(frame) {
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
  
  frame %>%
    recode_fp1() %>%
    recode_pipe1() %>%
    recode_computer()
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