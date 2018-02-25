#!/usr/bin/env Rscript
source("R/qualtrics.R")
source("R/languages.R")
source("R/changed-reasoning.R")
source("R/demographics.R")
source("R/irq.R")
source("R/wikipedia.R")


# Load SQLite DB with programming questionnaire
qualtrics <- get_qualtrics_responses("programming questionnaire")
questions <- get_qualtrics_questions("programming questionnaire")
responses <- tidy_qualtrics(qualtrics)

languages <- get_languages(responses)
changed_reasoning <- get_changed_reasoning(responses)
demographics <- get_demographics(responses)
language_ratings <- get_language_ratings(responses)
language_info <- get_language_info(languages)
irq <- get_irq(responses)


db_name = "programming-questionnaire.sqlite"
write_tables_to_sqlite(db_name,
                       qualtrics = responses,
                       questions = questions,
                       responses = responses,
                       languages = languages,
                       demographics = demographics,
                       language_info = language_info,
                       language_ratings = language_ratings,
                       changed_reasoning = changed_reasoning,
                       irq = irq,
                       overwrite = TRUE)
