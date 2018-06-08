# ---- beliefs ----
library(tidyverse)
library(magrittr)

library(programmingquestionnaire)
data("questions")
data("questionnaire")
data("languages")

question_names <- c(
  "cr1", "cr1describe", "cr2describe", "cp1", "cp1describe",
  "repo1", "repo1describe", "rec1", "rec1describe", "cfo1", "cfo2", "cfo3",
  "oss1", "oss2", "env1", "env2", "inter1", "inter2", "inter3"
)

get_question_text <- function(name) {
  filter(questions, question_name == name)$question_text
}

# By language ----
language_ranks <- languages %>%
  group_by(language_name) %>%
  summarize(
    frequency = n(),
    proficiency = mean(proficiency, na.rm = TRUE),
    years_used = mean(years_used, na.rm = TRUE)
  ) %>%
  programmingquestionnaire:::rank_by("frequency") %>%
  programmingquestionnaire:::rank_by("years_used") %>%
  programmingquestionnaire:::rank_by("proficiency") %>%
  select(language_name, frequency_rank, years_used_rank, proficiency_rank)

# must be ordered!
top20_languages <- language_ranks %>%
  arrange(frequency_rank) %>%
  filter(frequency_rank <= 20) %>%
  .$language_name

top20_questionnaire <- languages %>%
  filter(language_name %in% top20_languages) %>%
  left_join(questionnaire, .) %>%
  drop_na(language_name)

top20_questionnaire_ranks <- top20_questionnaire %>%
  group_by(language_name) %>%
  summarize(
    cr1 = mean(cr1, na.rm = TRUE),
    cp1 = mean(cp1, na.rm = TRUE),
    rec1 = mean(rec1, na.rm = TRUE),
    cfo1 = mean(cfo1, na.rm = TRUE),
    cfo2 = mean(cfo2, na.rm = TRUE),
    inter1 = mean(inter1, na.rm = TRUE),
    inter2 = mean(inter2, na.rm = TRUE)
  ) %>%
  programmingquestionnaire:::rank_by("cr1") %>%
  programmingquestionnaire:::rank_by("cp1") %>%
  programmingquestionnaire:::rank_by("rec1") %>%
  programmingquestionnaire:::rank_by("cfo1") %>%
  programmingquestionnaire:::rank_by("cfo2") %>%
  programmingquestionnaire:::rank_by("inter1") %>%
  programmingquestionnaire:::rank_by("inter2") %>%
  select(language_name, cr1_rank, cp1_rank, rec1_rank,
         cfo1_rank, cfo2_rank, inter1_rank, inter2_rank)



by_language_plot <- function(name, x = "python", y = 2.5) {
  levels <- arrange_(top20_questionnaire_ranks, .dots = list(paste0(name, "_rank")))$language_name
  top20_questionnaire %>%
    programmingquestionnaire:::order_language_by(use_levels = levels) %>%
    ggplot() +
      aes_string("language_ordered", name) +
      stat_summary(geom = "errorbar", fun.data = "mean_se") +
      coord_flip(ylim = c(1,5)) +
      scale_x_discrete(position = "top") +
      labs(x = "", y = "agreement", title = paste(strwrap(get_question_text(name), 50), collapse = "\n"))
}



# By paradigm ----
data("language_paradigms")
paradigm_ranks <- language_paradigms %>%
  group_by(paradigm_name) %>%
  summarize(
    n_languages = n()
  ) %>%
  programmingquestionnaire:::rank_by("n_languages")
top8_paradigms <- paradigm_ranks %>%
  arrange(n_languages_rank) %>%
  filter(n_languages_rank <= 8) %>%
  .$paradigm_name

data("languages")
questionnaire_by_top8_paradigms <- languages %>%
  left_join(language_paradigms) %>%
  filter(paradigm_name %in% top8_paradigms) %>%
  left_join(questionnaire, .) %>%
  drop_na(paradigm_name) %>%
  group_by(paradigm_name) %>%
  summarize(
    cr1 = mean(cr1, na.rm = TRUE),
    cp1 = mean(cp1, na.rm = TRUE),
    rec1 = mean(rec1, na.rm = TRUE),
    cfo1 = mean(cfo1, na.rm = TRUE),
    cfo2 = mean(cfo2, na.rm = TRUE),
    inter1 = mean(inter1, na.rm = TRUE),
    inter2 = mean(inter2, na.rm = TRUE)
  ) %>%
  programmingquestionnaire:::rank_by("cr1") %>%
  programmingquestionnaire:::rank_by("cp1") %>%
  programmingquestionnaire:::rank_by("rec1") %>%
  programmingquestionnaire:::rank_by("cfo1") %>%
  programmingquestionnaire:::rank_by("cfo2") %>%
  programmingquestionnaire:::rank_by("inter1") %>%
  programmingquestionnaire:::rank_by("inter2")

by_paradigm_plot <- function(name) {
  questionnaire_by_top8_paradigms %<>% programmingquestionnaire:::order_paradigm_by(paste0(name, "_rank"))
  ggplot(questionnaire_by_top8_paradigms) +
    aes_string("paradigm_ordered", name) +
    geom_point() +
    # annotate("label", x = x, y = , label = paste(strwrap(get_question_text(name), 33), collapse = "\n")) +
    coord_flip(ylim = c(1,5)) +
    scale_x_discrete(position = "top") +
    labs(x = "", y = "agreement")
}

# Functional v imperative ----
data("languages")
functional_v_imperative_languages <- programmingquestionnaire:::get_functional_v_imperative()
functional_v_imperative <- languages %>%
  left_join(language_paradigms) %>%
  filter(paradigm_name %in% c("functional", "imperative")) %>%
  inner_join(functional_v_imperative_languages) %>%
  filter(language_ix == 1) %>%
  left_join(questionnaire, .) %>%
  drop_na(paradigm_name)

functional_v_imperative_plot <- ggplot(functional_v_imperative) +
  aes(paradigm_name, cr1) +
  geom_point(position = position_jitter(width = 0.2, height = 0.1)) +
  stat_summary(geom = "errorbar", fun.data = "mean_se", width = 0.2)
