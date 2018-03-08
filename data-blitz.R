# ---- languages ----
library(knitr)
library(tidyverse)
library(magrittr)
library(ggrepel)
devtools::load_all()

t_ <- list(base = theme_minimal(base_size=18),
           geom_text_size = 6)

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
top20_language_names <- top20_languages

top20_language_summary <- language_summary %>%
  filter(language_name %in% top20_languages)

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
  scale_x_discrete("") +
  scale_y_continuous(breaks = seq(0, 200, by = 50)) +
  coord_flip(ylim = c(0, 240), expand = FALSE) +
  labs(x = "", y = "", title = "Frequency in sample") +
  t_$base

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
  aes(stack_overflow_rank, survey_rank) +
  geom_point() +
  geom_abline(intercept = 0, slope = 1) +
  geom_text_repel(aes(label = language_name), size = t_$geom_text_size) +
  scale_x_reverse(breaks = c(1, seq(5, 30, by = 5)), position = "top") +
  scale_y_reverse(breaks = c(1, seq(5, 30, by = 5)), position = "right") +
  annotate("label", x = 20, y = 2, label = "overrepresented", size = t_$geom_text_size) +
  annotate("label", x = 8, y = 25, label = "underrepresented", size = t_$geom_text_size) +
  coord_cartesian(xlim = c(-1, 32), ylim = c(-1, 32)) +
  labs(x = "Stack Overflow Rank", y = "Rank in Sample", 
       title = "Representativeness of sample") +
  t_$base

# paradigms ----
language_paradigms <- collect_table("language_paradigms")

paradigm_ranks <- language_paradigms %>%
  group_by(paradigm_name) %>%
  summarize(n = n()) %>%
  mutate(pct = prop.table(n)) %>%
  arrange(desc(n))

top_paradigms <- paradigm_ranks$paradigm_name[1:8]

top20_language_paradigms <- language_paradigms %>%
  filter(language_name %in% top20_languages)

top20_language_paradigms_summary <- top20_language_paradigms %>%
  group_by(paradigm_name) %>%
  summarize(n = n()) %>%
  mutate(pct = prop.table(n)) %>%
  arrange(desc(n))

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

# proficiency ----

mutate_years_used_sqr <- function(frame) {
  frame %>%
    mutate(
      years_used_sqr = years_used * years_used,
      years_used_z_sqr = years_used_z * years_used_z
    )
}

z_score <- function(x) (x - mean(x, na.rm = TRUE))/sd(x, na.rm = TRUE)

top20_languages <- collect_table("languages") %>%
  filter(language_name %in% top20_language_names) %>%
  group_by(language_name) %>%
  mutate(years_used_z = z_score(years_used)) %>%
  ungroup() %>%
  mutate_years_used_sqr()

proficiency_mod <- lmer(proficiency ~ years_used_z + years_used_z_sqr +
                          (years_used_z + years_used_z_sqr|language_name) +
                          (1|subj_id),
                        data = filter(top20_languages, years_used < 20))

years_used_density_plot <- ggplot(languages) +
  aes(years_used) +
  geom_density(aes(group = language_name), alpha = 0.5, size = 0.2) +
  geom_density(aes(group = 1), size = 2) +
  t_$base +
  labs(x = "years used")

python_params <- coef(proficiency_mod)$language_name %>%
  as.data.frame() %>%
  rownames_to_column("language_name") %>%
  as_data_frame() %>%
  filter(language_name == "python") %>%
  as.list()

languages_python <- filter(top20_languages, language_name == "python")

python_proficiency_plot <- languages_python %>% ggplot() +
  aes(years_used, proficiency) +
  geom_point(position = position_jitter(width = 0.2, height = 0.2)) +
  geom_smooth(method = "lm", formula = y ~ x + I(x^2), se = FALSE) +
  t_$base

proficiency_mod_language_coefs <- coef(proficiency_mod)$language_name %>%
  as.data.frame() %>%
  rownames_to_column("language_name") %>%
  as_data_frame() %>%
  rename(y0 = `(Intercept)`, b1 = years_used_z, b2 = years_used_z_sqr)

ggplot(top20_languages) +
  aes(years_used, proficiency, group = language_name) +
  geom_smooth(method = "lm", formula = y ~ x + I(x^2), stat = "identity",
              data = proficiency_mod_language_coefs) +
  t_$base

# ---- beliefs ----
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

top20_questionnaire <- collect_table("languages") %>%
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
  levels <- arrange_(top20_questionnaire_ranks, .dots = list(paste0(name, "_rank")))$language_name
  top20_questionnaire %>%
    order_language_by(use_levels = levels) %>%
    ggplot() +
    aes_string("language_ordered", name) +
    stat_summary(geom = "errorbar", fun.data = "mean_se") +
    coord_flip(ylim = c(1,5)) +
    scale_x_discrete(position = "top") +
    labs(x = "", y = "agreement", title = paste(strwrap(get_question_text(name), 50), collapse = "\n")) +
    t_$base
}

# By paradigm ----
language_paradigms <- collect_table("language_paradigms")
paradigm_ranks <- language_paradigms %>%
  group_by(paradigm_name) %>%
  summarize(
    n_languages = n()
  ) %>%
  rank_by("n_languages")
top8_paradigms <- paradigm_ranks %>%
  arrange(n_languages_rank) %>%
  filter(n_languages_rank <= 8) %>%
  .$paradigm_name

questionnaire_by_top8_paradigms <- collect_table("languages") %>%
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

# Functional v imperative ----
functional_v_imperative <- collect_table("languages") %>%
  left_join(language_paradigms) %>%
  filter(paradigm_name %in% c("functional", "imperative")) %>%
  inner_join(get_functional_v_imperative()) %>%
  filter(language_ix == 1) %>%
  left_join(questionnaire, .) %>%
  drop_na(paradigm_name)

functional_v_imperative_plot <- ggplot(functional_v_imperative) +
  aes(paradigm_name, cr1) +
  geom_point(position = position_jitter(width = 0.2, height = 0.1)) +
  stat_summary(geom = "errorbar", fun.data = "mean_se", width = 0.2)
