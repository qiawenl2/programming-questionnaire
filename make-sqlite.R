#!/usr/bin/env Rscript
source("R/qualtrics.R")
source("R/languages.R")
source("R/demographics.R")

# Load SQLite DB with programming questionnaire
qualtrics <- get_qualtrics_responses("programming questionnaire")
questions <- get_qualtrics_questions("programming questionnaire")
responses <- tidy_qualtrics(qualtrics)
languages <- get_languages(responses)

# demographics not working because of duplicate question name isNative.
# The duplication has been fixed, but Qualtrics DBs need to refresh.
# demographics <- get_demographics(responses)


db_name = "programming-questionnaire.sqlite"
write_tables_to_sqlite(db_name,
                       qualtrics = responses,
                       questions = questions,
                       responses = responses,
                       languages = languages,
                       # demographics = demographics,
                       overwrite = TRUE)
