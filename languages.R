# ---- setup ----
library(knitr)
library(tidyverse)
library(magrittr)
devtools::load_all()

languages <- collect_table("languages")
language_ratings <- collect_table("language_ratings")
language_info <- collect_table("language_info")

language_summary <- languages %>%
  group_by(language_name) %>%
  summarize(
    frequency = n(),
    proficiency = mean(proficiency, na.rm = TRUE),
    years_used = mean(years_used, na.rm = TRUE)
  ) %>%
  rank_by("frequency") %>%
  rank_by("years_used") %>%
  rank_by("proficiency")

# must be ordered!
top20_languages <- order_language_by(language_summary, "frequency_rank", levels_only = TRUE)[1:20]

not_top20_language_summary <- language_summary %>%
  filter(!(language_name %in% top20_languages)) %>%
  summarize(
    frequency = sum(frequency, na.rm = TRUE),
    years_used = mean(years_used, na.rm = TRUE),
    proficiency = mean(proficiency, na.rm = TRUE),
    frequency_rank = Inf,
    years_used_rank = Inf,
    proficiency_rank = Inf
  ) %>%
  mutate(language_name = "other")

top20_language_summary <- language_summary %>%
  filter(language_name %in% top20_languages) %>%
  bind_rows(not_top20_language_summary)

language_ratings_summary <- language_ratings %>%
  group_by(language_name, question_name, question_tag) %>%
  summarize(
    n = n(),
    agreement_num = mean(agreement_num, na.rm = TRUE)
  ) %>%
  ungroup()

top20_ratings_summary <- language_ratings_summary %>%
  filter(language_name %in% top20_languages)

recode_reuse <- function(frame) {
  reuse_levels <- c("adapt",  "reuse", "adopt")
  reuse_map <- data_frame(
    question_tag = reuse_levels,
    reuse_label = factor(reuse_levels, levels = reuse_levels)
  )
  if(missing(frame)) return(reuse_map)
  left_join(frame, reuse_map)
}

top20_reuse <- filter(top20_ratings_summary, question_name == "reuse") %>%
  recode_reuse()

# paradigms ----
language_info <- collect_table("language_info")
language_info_summary <- language_info %>%
  group_by(paradigm) %>%
  summarize(n = n()) %>%
  mutate(pct = prop.table(n)) %>%
  arrange(desc(n))

top20_language_info <- language_info %>%
  filter(language_name %in% top20_languages)

top20_language_info_summary <- top20_language_info %>%
  group_by(paradigm) %>%
  summarize(n = n()) %>%
  mutate(pct = prop.table(n)) %>%
  arrange(desc(n))

top_paradigms_tbl <- left_join(top20_language_info_summary, language_info_summary, by = "paradigm", suffix = c("_top20", "_all")) %>%
  filter(row_number() <= 8)
top_paradigms <- top_paradigms_tbl$paradigm

top20_language_paradigms <- top20_language_info %>%
  filter(paradigm %in% top_paradigms) %>%
  group_by(language_name) %>%
  summarize(n_top8_paradigms = n())

# ---- languages-per-person ----
