#!/usr/bin/env Rscript
# Unpack tables from programming-questionnaire.sqlite
library(tidyverse)
devtools::load_all()

csv_names <- list(
  qualtrics="data-raw/qualtrics.csv",
  questions="data-raw/questions.csv",
  responses="data-raw/responses.csv",
  languages="data-raw/languages.csv",
  demographics="data-raw/demographics.csv",
  language_ratings="data-raw/language-ratings.csv",
  questionnaire="data-raw/questionnaire.csv",
  irq="data-raw/irq.csv",
  language_paradigms="data-raw/language-paradigms.csv",
  stack_overflow="data-raw/stack-overflow.csv",
  stack_overflow_ranks="data-raw/stack-overflow-ranks.csv"
)

for(table_name in names(csv_names)) {
  collect_table(table_name) %>%
    readr::write_csv(x = ., path = csv_names[[table_name]])
}
