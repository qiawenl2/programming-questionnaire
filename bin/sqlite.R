#!/usr/bin/env Rscript
devtools::load_all()

write_tables_to_sqlite("programming-questionnaire.sqlite",
                       qualtrics = read_csv("data-raw/responses.csv"),
                       questions = read_csv("data-raw/questions.csv"),
                       responses = read_csv("data-raw/responses.csv"),
                       languages = read_csv("data-raw/languages.csv"),
                       demographics = read_csv("data-raw/demographics.csv"),
                       language_ratings = read_csv("data-raw/language-ratings.csv"),
                       questionnaire = read_csv("data-raw/questionnaire.csv"),
                       irq = read_csv("data-raw/irq.csv"),
                       language_paradigms = read_csv("data-raw/language-paradigms.csv"),
                       stack_overflow = read_csv("data-raw/stack-overflow.csv"),
                       stack_overflow_ranks = read_csv("data-raw/stack-overflow-ranks.csv"),
                       overwrite = TRUE)