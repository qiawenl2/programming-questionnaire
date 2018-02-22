library(qualtRics)
library(yaml)
library(tidyverse)

creds <- yaml.load_file("qualtrics.yml")
registerOptions(api_token = creds$api_token, root_url = creds$root_url)

get_responses <- function(survey_name, ...) {
  survey_id <- get_survey_id_from_name(survey_name)

  # Get raw responses in wide format (one column per subquestion)
  data_dir <- "data"
  if (!dir.exists(data_dir)) dir.create(data_dir)
  results <- getSurvey(survey_id, save_dir = data_dir, ...)

  # Extract subquestion info from column attributes
  subquestion_labels <- lapply(results, attributes) %>%
    map(extract_subquestion_label)
  subquestions <- data_frame(
    subq_id = names(subquestion_labels),
    subq_label = unlist(subquestion_labels)
  )

  # Melt the wide results to long format
  # Ignore warning about unequal attributes
  suppressWarnings({
    tidied <- results %>%
      gather(subq_id, response, -ResponseID)
  })

  # Merge in subquestion labels
  # Ignore message about what column is used for joining
  suppressMessages({
    tidied <- left_join(tidied, subquestions)
  })

  question_labels <- getSurveyQuestions(survey_id) %>%
    mutate(qid = stringr::str_replace(qid, "ID", "")) %>%
    select(qid, question)

  questions_to_subq_map <- subquestions[stringr::str_detect(subquestions$subq_id, "Q\\d+"), ] %>%
    mutate(qid = stringr::str_split_fixed(subq_id, "_", n = 2)[,1]) %>%
    select(subq_id, qid)

  suppressMessages({
    questions_map <- left_join(questions_to_subq_map, question_labels) %>%
      select(qid, question, subq_id)

    tidied <- left_join(tidied, questions_map) %>%
      select(ResponseID, qid, question, subq_id, subq_label, response)
  })

  tidied
}

extract_subquestion_label <- function(question_attributes) {
  if (!("label" %in% names(question_attributes))) return("")
  question_attributes$label[[1]]
}

list_recent_surveys <- function(n = 10) {
  getSurveys() %>%
    arrange(desc(lastModified)) %>%
    head(n = n)
}

get_survey_id_from_name <- function(survey_name) {
  getSurveys() %>%
    filter(name == survey_name) %>%
    .$id %>%
    as.character()
}

responses <- get_responses("programming questionnaire")
write.csv(responses, "data/programming-questionnaire.csv", row.names=FALSE)
