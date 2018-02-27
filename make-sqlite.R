#!/usr/bin/env Rscript
source("R/qualtrics.R")
source("R/languages.R")
source("R/questionnaire.R")
source("R/demographics.R")
source("R/irq.R")
source("R/wikipedia.R")


# Load SQLite DB with programming questionnaire
refresh <- FALSE
qualtrics <- get_qualtrics_responses("programming questionnaire", force_request = refresh)
questions <- get_qualtrics_questions("programming questionnaire", force_request = refresh)

responses <- tidy_qualtrics(qualtrics)
languages <- get_languages(responses)
questionnaire <- get_questionnaire(responses)
demographics <- get_demographics(responses)
language_ratings <- get_language_ratings(responses)
irq <- get_irq(responses)

# Fetch data about each language from Wikidata.
# Takes a few minutes.
language_info <- get_language_info(languages)

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
                       language_info = language_info,
                       overwrite = TRUE)
