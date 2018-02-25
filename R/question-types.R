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