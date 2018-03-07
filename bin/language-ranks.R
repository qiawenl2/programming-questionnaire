#!/usr/bin/env Rscript
devtools::load_all()

stack_overflow <- get_stack_overflow()
n_respondents <- length(unique(stack_overflow$respondent))
stack_overflow_ranks <- stack_overflow %>%
  count(language_name) %>%
  arrange(desc(n)) %>%
  mutate(
    rank = 1:n(),
    pct = round(n/n_respondents, digits = 2)
  )

write_csv(stack_overflow, "data-raw/stack-overflow.csv")
write_csv(stack_overflow_ranks, "data-raw/stack-overflow-ranks.csv")