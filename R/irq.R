get_irq <- function(responses) {
  irq_question_names <- unique(responses$question_name) %>%
    grep("^IRQ1", x = ., value = TRUE)

  irq <- responses %>%
    filter(question_name %in% irq_question_names)

  irq$item <- as.integer(str_match(irq$question_name, "IRQ1_IRQ1_(\\d+)")[, 2])

  irq %>%
    select(subj_id, item, question_label, response_str)
}