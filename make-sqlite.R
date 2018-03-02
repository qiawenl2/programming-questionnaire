#!/usr/bin/env Rscript
devtools::load_all()

# Load SQLite DB with programming questionnaire
refresh <- FALSE
qualtrics <- get_qualtrics_responses("programming questionnaire", force_request = refresh)
questions <- get_qualtrics_questions("programming questionnaire", force_request = refresh)

responses <- tidy_qualtrics(qualtrics)
languages <- get_languages(responses) %>%
  recode_language_names()
language_ratings <- get_language_ratings(responses, languages)
questionnaire <- get_questionnaire(responses)
demographics <- get_demographics(responses)
irq <- get_irq(responses)

db_name = "programming-questionnaire.sqlite"
write_tables_to_sqlite(db_name,
                       qualtrics = responses,
                       questions = questions,
                       responses = responses,
                       languages = languages,
                       demographics = demographics,
                       language_ratings = language_ratings,
                       questionnaire = questionnaire,
                       irq = irq,
                       overwrite = TRUE)


language_info <- get_language_info(languages) %>%
  add_manual_languages()
write_tables_to_sqlite(db_name,
                       language_info = language_info,
                       overwrite = TRUE)
