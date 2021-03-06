#!/usr/bin/env Rscript --vanilla
# Compile csvs in "data-raw/" to rda files in "data/"
library(tidyverse)
library(devtools)
source("R/question-types.R")

qualtrics <- read_csv("data-raw/responses.csv")
questions <- read_csv("data-raw/questions.csv")
responses <- read_csv("data-raw/responses.csv")
languages <- read_csv("data-raw/languages.csv")
demographics <- read_csv("data-raw/demographics.csv")
language_ratings <- read_csv("data-raw/language-ratings.csv")

# Load questionnaire and set factors
questionnaire <- read_csv("data-raw/questionnaire.csv") %>%
  recode_all_agreement() %>%
  recode_all_agreement_other() %>%
  recode_all_multiple_choice()

irq <- read_csv("data-raw/irq.csv")
language_paradigms <- read_csv("data-raw/language-paradigms.csv")
stack_overflow <- read_csv("data-raw/stack-overflow.csv")
stack_overflow_ranks <- read_csv("data-raw/stack-overflow-ranks.csv")

devtools::use_data(qualtrics, questions, responses, languages, demographics,
                   language_ratings, questionnaire, irq, language_paradigms,
                   stack_overflow, stack_overflow_ranks, overwrite = TRUE)
