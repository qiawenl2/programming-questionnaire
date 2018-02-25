
recode_agreement <- function(frame, agree_high = TRUE, response_str_col = "response_str", replace = FALSE) {
  levels <- c("Strongly disagree", "Somewhat disagree", "Neither agree nor disagree", "Somewhat agree", "Strongly agree")
  if(!agree_high) levels <- rev(levels)
  
  agreement_map <- data_frame(
    agreement_num = seq_along(levels),
    agreement_label = factor(levels, levels = rev(levels))
  )
  agreement_map[response_str_col] <- levels
  
  if(missing(frame)) return(agreement_map)

  result <- left_join(frame, agreement_map)

  if(replace) {
    result[response_str_col] <- result$agreement_num
    result <- select(result, -agreement_num, -agreement_label)
  }

  result
}
