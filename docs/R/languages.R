# ---- languages ----
library(knitr)
library(tidyverse)
library(magrittr)
library(ggrepel)
library(lme4)

library(programmingquestionnaire)
data("languages")
data("language_ratings")
data("language_paradigms")

t_ <- list(base = theme_minimal(base_size=18),
           geom_text_size = 6)

language_summary <- languages %>%
  filter(language_name %in% unique(language_paradigms$language_name)) %>%
  group_by(language_name) %>%
  summarize(
    frequency = n(),
    proficiency = mean(proficiency, na.rm = TRUE),
    years_used = mean(years_used, na.rm = TRUE)
  ) %>%
  programmingquestionnaire:::rank_by("frequency") %>%
  programmingquestionnaire:::rank_by("years_used") %>%
  programmingquestionnaire:::rank_by("proficiency")

# must be ordered!
top20_languages <- programmingquestionnaire:::order_language_by(language_summary, "frequency_rank", levels_only = TRUE)[1:20]
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
top20_language_summary %<>% programmingquestionnaire:::order_language_by("frequency_rank", reverse = TRUE)
freq_plot <- ggplot(top20_language_summary) +
  aes(language_ordered, frequency) +
  geom_bar(stat = "identity") +
  scale_x_discrete("") +
  scale_y_continuous(breaks = seq(0, 200, by = 50)) +
  coord_flip(ylim = c(0, 240), expand = FALSE) +
  labs(x = "", y = "", title = "Frequency in sample") +
  t_$base

survey_languages <- languages %>%
  count(language_name) %>%
  arrange(desc(n)) %>%
  mutate(survey_rank = 1:n()) %>%
  select(language_name, survey_rank)

stack_overflow <- stack_overflow %>%
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
languages <- languages %>%
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

top20_languages <- languages %>%
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

ggplot(proficiency_mod_language_coefs) +
  aes(years_used, proficiency, group = language_name) +
  geom_line() +
  t_$base

