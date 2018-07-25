#!/usr/bin/env Rscript
library(tidyverse)
devtools::load_all()

responses <- read_csv("data-raw/responses.csv")

languages <- get_languages(responses) %>%
  recode_language_names()
language_ratings <- get_language_ratings(responses, languages)

questionnaire <- get_questionnaire(responses)
demographics <- get_demographics(responses)
irq <- get_irq(responses)

write_csv(languages, "data-raw/languages.csv")
write_csv(language_ratings, "data-raw/language-ratings.csv")
write_csv(questionnaire, "data-raw/questionnaire.csv")
write_csv(demographics, "data-raw/demographics.csv")
write_csv(irq, "data-raw/irq.csv")