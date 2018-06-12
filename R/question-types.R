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
  fp1_map <- data_frame(
    response_num = seq_along(fp1_choices),
    response_label = factor(fp1_choices, levels = fp1_choices)
  )
  fp1_map$fp1 <- fp1_map$response_label
  
  if(missing(frame)) return(fp1_map)
  result <- left_join(frame, fp1_map)
  result$fp1 <- result$response_num
  result <- select(result, -response_num, -response_label)
  result
}

recode_pipe1 <- function(frame) {
  pipe1_choices <- c("Piping much better",
                     "Piping somewhat better",
                     "Both are identical",
                     "Traditional composition somewhat better",
                     "Traditional composition much better",
                     "I don't know enough about piping to answer this question")
  pipe1_map <- data_frame(
    response_num = seq_along(pipe1_choices),
    response_label = factor(pipe1_choices, levels = pipe1_choices)
  )
  pipe1_map$pipe1 <- pipe1_map$response_label
  
  if(missing(frame)) return(pipe1_map)
  result <- left_join(frame, pipe1_map)
  result$pipe1 <- result$response_num
  result <- select(result, -response_num, -response_label)
  result
}

recode_computer <- function(frame) {
  computer_choices <- c("(1)  I never think of programming as instructing a person",
                        "(2)",
                        "(3)",
                        "(4)",
                        "(5) I always think of programming as instructing a person")
  computer_map <- data_frame(
    response_num = seq_along(computer_choices),
    response_label = computer_choices
  )
  computer_map$computer <- computer_map$response_label
  
  if(missing(frame)) return(computer_map)
  result <- left_join(frame, computer_map)
  result$computer <- result$response_num
  result <- select(result, -response_num, -response_label)
  result
}