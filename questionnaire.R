# ---- setup ----
library(tidyverse)
library(magrittr)
devtools::load_all()

questions <- collect_table("questions")
question_names <- c(
  "cr1", "cr1describe", "cr2describe", "cp1", "cp1describe",
  "repo1", "repo1describe", "rec1", "rec1describe", "cfo1", "cfo2", "cfo3",
  "oss1", "oss2", "env1", "env2", "inter1", "inter2", "inter3"
)

get_question_text <- function(name) {
  filter(questions, question_name == name)$question_text
}

questionnaire <- collect_table("questionnaire")

# By language ----
language_ranks <- collect_table("languages") %>%
  group_by(language_name) %>%
  summarize(
    frequency = n(),
    proficiency = mean(proficiency, na.rm = TRUE),
    years_used = mean(years_used, na.rm = TRUE)
  ) %>%
  rank_by("frequency") %>%
  rank_by("years_used") %>%
  rank_by("proficiency") %>%
  select(language_name, frequency_rank, years_used_rank, proficiency_rank)

# must be ordered!
top20_languages <- language_ranks %>%
  arrange(frequency_rank) %>%
  filter(frequency_rank <= 20) %>%
  .$language_name

top20_questionnaire_ranks <- collect_table("languages") %>%
  filter(language_name %in% top20_languages) %>%
  left_join(questionnaire, .) %>%
  drop_na(language_name) %>%
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
  rank_by("cr1") %>%
  rank_by("cp1") %>%
  rank_by("rec1") %>%
  rank_by("cfo1") %>%
  rank_by("cfo2") %>%
  rank_by("inter1") %>%
  rank_by("inter2") %>%
  select(language_name, cr1_rank, cp1_rank, rec1_rank,
         cfo1_rank, cfo2_rank, inter1_rank, inter2_rank)

by_language_plot <- function(name, x = "python", y = 2.5) {
  questionnaire_by_top20_language %<>% order_language_by(paste0(name, "_rank"))
  ggplot(questionnaire_by_top20_language) +
    aes_string("language_ordered", name) +
    geom_point() +
    annotate("label", x = x, y = y, label = paste(strwrap(get_question_text(name), 33), collapse = "\n")) +
    coord_flip(ylim = c(1,5)) +
    scale_x_discrete(position = "top") +
    labs(x = "", y = "agreement")
}

# By paradigm ----
language_info <- collect_table("language_info")
paradigm_ranks <- language_info %>%
  group_by(paradigm) %>%
  summarize(
    n_languages = n()
  ) %>%
  rank_by("n_languages")
top8_paradigms <- paradigm_ranks %>%
  arrange(n_languages_rank) %>%
  filter(n_languages_rank <= 8) %>%
  .$paradigm

questionnaire_by_top8_paradigms <- collect_table("languages") %>%
  left_join(language_info) %>%
  filter(paradigm %in% top8_paradigms) %>%
  left_join(questionnaire, .) %>%
  drop_na(paradigm) %>%
  group_by(paradigm) %>%
  summarize(
    cr1 = mean(cr1, na.rm = TRUE),
    cp1 = mean(cp1, na.rm = TRUE),
    rec1 = mean(rec1, na.rm = TRUE),
    cfo1 = mean(cfo1, na.rm = TRUE),
    cfo2 = mean(cfo2, na.rm = TRUE),
    inter1 = mean(inter1, na.rm = TRUE),
    inter2 = mean(inter2, na.rm = TRUE)
  ) %>%
  rank_by("cr1") %>%
  rank_by("cp1") %>%
  rank_by("rec1") %>%
  rank_by("cfo1") %>%
  rank_by("cfo2") %>%
  rank_by("inter1") %>%
  rank_by("inter2")

by_paradigm_plot <- function(name) {
  questionnaire_by_top8_paradigms %<>% order_paradigm_by(paste0(name, "_rank"))
  ggplot(questionnaire_by_top8_paradigms) +
    aes_string("paradigm_ordered", name) +
    geom_point() +
    # annotate("label", x = x, y = , label = paste(strwrap(get_question_text(name), 33), collapse = "\n")) +
    coord_flip(ylim = c(1,5)) +
    scale_x_discrete(position = "top") +
    labs(x = "", y = "agreement")
}