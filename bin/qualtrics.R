#!/usr/bin/env Rscript
devtools::load_all()

qualtrics <- get_qualtrics_responses("programming questionnaire")
questions <- get_qualtrics_questions("programming questionnaire")
responses <- tidy_qualtrics(qualtrics)

write_csv(qualtrics, "data-raw/qualtrics.csv")
write_csv(questions, "data-raw/questions.csv")
write_csv(responses, "data-raw/responses.csv")