#!/usr/bin/env Rscript
setwd("/Users/qiawenliu/Box Sync/FYP/sem_dif/")

library(readr)
source("qualtrics.R")

survey_name <- ""# your survey name
# Get raw responses from Qualtrics
qualtrics <- get_qualtrics_responses(survey_name, force_request=TRUE,convertVariables=FALSE,useLabels=FALSE)
# Tidy wide format to long
#qualtrics$subj_id <- qualtrics$ResponseId
#colnames(qualtrics)[colnames(qualtrics) == 'ResponseID'] <- 'subj_id'
responses <- tidy_qualtrics(qualtrics)
# Extract survey questions
questions <- get_qualtrics_questions(survey_name)


write_csv(qualtrics, "qualtrics.csv")
write_csv(responses, "responses.csv")
write_csv(questions, "questions.csv")

