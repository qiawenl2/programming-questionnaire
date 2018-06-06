#!/usr/bin/env Rscript
library(devtools)
library(readr)

qualtrics <- read_csv("data-raw/responses.csv")
questions <- read_csv("data-raw/questions.csv")
responses <- read_csv("data-raw/responses.csv")
languages <- read_csv("data-raw/languages.csv")
demographics <- read_csv("data-raw/demographics.csv")
language_ratings <- read_csv("data-raw/language-ratings.csv")
language_info <- read_csv("data-raw/language-info.csv")
questionnaire <- read_csv("data-raw/questionnaire.csv")
irq <- read_csv("data-raw/irq.csv")
language_paradigms <- read_csv("data-raw/language-paradigms.csv")
stack_overflow <- read_csv("data-raw/stack-overflow.csv")
stack_overflow_ranks <- read_csv("data-raw/stack-overflow-ranks.csv")

use_data(qualtrics, questions, responses,
         languages, demographics, language_ratings,
         questionnaire, irq, language_paradigms, language_info,
         stack_overflow, stack_overflow_ranks,
         overwrite = TRUE)

args <- commandArgs(trailingOnly = TRUE)
if(args[[1]] == '--install') {
    document()
    install()
}

