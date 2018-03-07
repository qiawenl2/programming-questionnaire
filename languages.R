# ---- setup ----
library(knitr)
library(tidyverse)
library(magrittr)
library(ggrepel)
devtools::load_all()

languages <- collect_table("languages")
language_ratings <- collect_table("language_ratings")
language_paradigms <- collect_table("language_paradigms")

language_summary <- languages %>%
  filter(language_name %in% unique(language_paradigms$language_name)) %>%
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

# representativeness ----
top20_language_summary %<>% order_language_by("frequency_rank", reverse = TRUE)
freq_plot <- ggplot(top20_language_summary) +
  aes(language_ordered, frequency) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = language_name), nudge_y = 2, hjust = 0) +
  scale_x_discrete("", labels = c(">20", 20:1)) +
  scale_y_continuous(breaks = seq(0, 400, by = 50)) +
  coord_flip(ylim = c(0, 360), expand = FALSE) +
  labs(x = "", y = "", title = "Frequency") +
  theme_minimal()

survey_languages <- collect_table("languages") %>%
  count(language_name) %>%
  arrange(desc(n)) %>%
  mutate(survey_rank = 1:n()) %>%
  select(language_name, survey_rank)

stack_overflow <- collect_table("stack_overflow") %>%
  count(language_name) %>%
  arrange(desc(n)) %>%
  mutate(stack_overflow_rank = 1:n()) %>%
  select(language_name, stack_overflow_rank)

compare_ranks <- left_join(survey_languages, stack_overflow)
rank_corr_plot <- ggplot(compare_ranks) +
  aes(survey_rank, stack_overflow_rank) +
  geom_point() +
  geom_abline(intercept = 0, slope = 1) +
  geom_text_repel(aes(label = language_name), data = filter(compare_ranks, survey_rank <= 20)) +
  scale_x_reverse(breaks = c(1, seq(5, 30, by = 5)), position = "top") +
  scale_y_reverse(breaks = c(1, seq(5, 30, by = 5)), position = "right") +
  annotate("label", x = 20, y = 5, label = "underrepresented") +
  annotate("label", x = 5, y = 20, label = "overrepresented") +
  coord_cartesian(xlim = c(0, 30), ylim = c(0, 30), expand = FALSE) +
  labs(x = "Rank in Sample", y = "Stack Overflow Rank") +
  theme_minimal()

# paradigms ----
language_paradigms <- collect_table("language_paradigms")
language_paradigms_summary <- language_paradigms %>%
  group_by(paradigm_name) %>%
  summarize(n = n()) %>%
  mutate(pct = prop.table(n)) %>%
  arrange(desc(n))

top20_language_paradigms <- language_paradigms %>%
  filter(language_name %in% top20_languages)

top20_language_paradigms_summary <- top20_language_paradigms %>%
  group_by(paradigm_name) %>%
  summarize(n = n()) %>%
  mutate(pct = prop.table(n)) %>%
  arrange(desc(n))

top_paradigms_tbl <- left_join(top20_language_paradigms_summary, language_paradigms_summary,
                               by = "paradigm_name", suffix = c("_top20", "_all")) %>%
  filter(row_number() <= 8)
top_paradigms <- top_paradigms_tbl$paradigm_name

# ---- languages-per-person ----
languages <- collect_table("languages") %>%
  filter(language_name %in% unique(language_paradigms$language_name)) %>%
  drop_na(proficiency)

subj_proficiencies <- languages %>%
  group_by(subj_id) %>%
  summarize(
    mean_proficiency = mean(proficiency, na.rm = TRUE),
    proficiency_var = var(proficiency, na.rm = TRUE)
  ) %>%
  arrange(desc(mean_proficiency))

languages$subj_id_ordered <- factor(languages$subj_id, levels = subj_proficiencies$subj_id)

ggplot(languages) +
  aes(subj_id_ordered, proficiency) +
  stat_summary(geom = "linerange", fun.data = "mean_se") +
  scale_x_discrete("", labels = NULL, breaks = NULL)
