
recode_agreement <- function(frame) {
  levels <- c("Strongly agree", "Somewhat agree", "Neither agree nor disagree", "Somewhat disagree", "Strongly disagree")
  agreement_map <- data_frame(
    response_str = rev(levels),
    agreement_num = seq_along(levels),
    agreement_label = factor(levels, levels = rev(levels))
  )
  if(missing(frame)) return(agreement_map)
  left_join(frame, agreement_map)
}
  