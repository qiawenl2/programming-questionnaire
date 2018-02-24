library(qualtRics)
library(yaml)
library(tidyverse)

#' Get raw responses from Qualtrics in wide format with one column per subquestion.
get_qualtrics_responses <- function(survey_name, ...) {
  survey_id <- get_survey_id_from_name(survey_name)

  data_dir <- "data"
  if (!dir.exists(data_dir)) dir.create(data_dir)
  results <- getSurvey(survey_id, save_dir = data_dir, ...)
  
  as_data_frame(results)
}


#' Melt Qualtrics responses to long format with one row per subquestion.
melt_responses <- function(responses, subj_id_col = "ResponseID") {
  responses$subj_id <- responses[[subj_id_col]]
  gather(responses, question_str, response_str, -subj_id)
}


#' Label question name from Qualtrics question label.
label_question_name <- function(melted) {
  re_question_name <- "^([A-Za-z]+)\\.?"
  question_names <- str_match(melted$question_str, re_question_name)[, 2]
  mutate(melted, question_name = question_names)
}


#' Get question labels from column attributes.
get_question_labels <- function(responses) {
  question_labels <- lapply(responses, attributes) %>%
    map(function(question_attributes) {
      if (!("label" %in% names(question_attributes))) return("")
      question_attributes$label[[1]]
    })
    
  question_label_map <- data_frame(
    question_str = names(question_labels),
    question_label = unlist(question_labels)
  )

  question_label_map
}


#' Get survey questions from Qualtrics.
get_qualtrics_questions <- function(survey_name, ...) {
  survey_id <- get_survey_id_from_name(survey_name)
  
  questions <- getSurveyQuestions(survey_id) %>%
    as_data_frame()
  
  questions$question_label <- map(names(questions$qlabel), function(question_id) {
      # Preprocess question labels to replace character(0) with ""
      question_name <- questions$qlabel[[question_id]]
      if(is_empty(question_name)) question_name <- ""
      question_name
    }) %>%
    unlist()
  
  # Remove qlabel list col
  select(questions, -qlabel)
}


#' List recent Qualtrics surveys
list_recent_surveys <- function(n = 10) {
  getSurveys() %>%
    arrange(desc(lastModified)) %>%
    head(n = n)
}


#' Get survey id from survey name
get_survey_id_from_name <- function(survey_name) {
  getSurveys() %>%
    filter(name == survey_name) %>%
    .$id %>%
    as.character()
}


#' Write named table arguments to a SQLite DB.
write_tables_to_sqlite <- function(sqlite_db, ..., overwrite = FALSE) {
  named_tables = list(...)
  con <- DBI::dbConnect(RSQLite::SQLite(), sqlite_db)
  for(table_name in names(named_tables)) {
    DBI::dbWriteTable(con, table_name, named_tables[[table_name]], overwrite = overwrite)
  }
  DBI::dbDisconnect(con)
}

#' List the tables in a SQLite DB.
list_tables <- function(sqlite_db) {
  con <- DBI::dbConnect(RSQLite::SQLite(), sqlite_db)
  table_names <- DBI::dbListTables(con)
  DBI::dbDisconnect(con)
  table_names
}


#' Load SQLite DB with programming questionnaire
load_db <- function(db_name = "programming-questionnaire.sqlite") {
  creds <- yaml.load_file("qualtrics.yml")
  registerOptions(api_token = creds$api_token, root_url = creds$root_url)
  qualtrics <- get_qualtrics_responses("programming questionnaire")
  questions <- get_qualtrics_questions("programming questionnaire")
  labels <- get_question_labels(qualtrics)
  responses <- qualtrics %>%
    melt_responses() %>%
    label_question_name() %>%
    left_join(labels)

  write_tables_to_sqlite(db_name,
                         qualtrics = responses,
                         questions = questions,
                         responses = responses,
                         overwrite = TRUE)
}
