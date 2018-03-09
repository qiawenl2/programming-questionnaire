# ---- data-blitz
library(knitr)
library(tidyverse)
library(magrittr)
library(ggrepel)
library(lme4)
devtools::load_all()

t_ <- list(base = theme_minimal(base_size=18),
           geom_text_size = 6)

# must be ordered!
top20_language_names <- collect_table("languages") %>%
  filter_known_languages() %>%
  group_by(language_name) %>%
  summarize(frequency = n()) %>%
  arrange(desc(frequency)) %>%
  .$language_name %>%
  .[1:20]

# language frequencies ----
language_frequencies <- collect_table("languages") %>%
  filter(language_name %in% top20_language_names)
language_frequencies$language_ordered <- factor(language_frequencies$language_name,
                                                levels = rev(top20_language_names))
  
language_frequencies_plot <- ggplot(language_frequencies) +
  aes(language_ordered) +
  geom_bar(stat = "count") +
  scale_x_discrete("") +
  scale_y_continuous(breaks = seq(0, 200, by = 50)) +
  coord_flip(ylim = c(0, 210), expand = FALSE) +
  labs(x = "", y = "", title = "Frequency in sample") +
  t_$base

# representativeness ----
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

# languages-per-person ----
languages_per_person <- collect_table("languages") %>%
  filter_known_languages() %>%
  group_by(subj_id) %>%
  summarize(n = n())

languages_per_person_plot <- ggplot(languages_per_person) +
  aes(n) +
  geom_bar(stat = "count") +
  coord_cartesian(expand = FALSE) +
  t_$base +
  labs(title = "Languages per person")

# experience ----
years_used <- collect_table("languages") %>%
  filter(language_name %in% top20_language_names)

years_used_density_plot <- ggplot(years_used) +
  aes(years_used) +
  geom_density(aes(group = language_name), alpha = 0.5, size = 0.2, adjust = 2) +
  geom_density(aes(group = 1), size = 2) +
  t_$base +
  labs(x = "years used", title = "Language experience")

# proficiency ----
proficiency_data <- collect_table("languages") %>%
  filter(language_name %in% top20_language_names) %>%
  standardize_years_used_by_language() %>%
  mutate_years_used_sqr() %>%
  drop_na(proficiency) %>%
  filter(years_used > 1)

proficiency_mod <- lmer(proficiency ~ years_used_z + years_used_z_sqr +
                          (years_used_z + years_used_z_sqr|language_name) +
                          (1|subj_id),
                        data = proficiency_data)

proficiency_pred_xs <- unique(proficiency_data[,c("language_name", "years_used", "years_used_z", "years_used_z_sqr")]) %>%
  drop_na(years_used)
proficiency_pred_xs$subj_id <- NA
proficiency_pred_ys <- predict(proficiency_mod, proficiency_pred_xs, re.form = ~(years_used_z + years_used_z_sqr|language_name))

proficiency_preds <- cbind(proficiency_pred_xs, proficiency = proficiency_pred_ys) %>%
  as_data_frame()

proficiency_plot <- ggplot(proficiency_preds) +
  aes(years_used, proficiency, group = language_name) +
  geom_line() +
  scale_x_continuous(breaks = seq(0, 30, by = 5)) +
  scale_y_continuous(breaks = 1:5) +
  coord_cartesian(xlim = c(0, 25), ylim = c(1, 5)) +
  t_$base +
  labs(x = "Years used", y = "Self-reported proficiency")

# python proficiency ----
python_proficiency_plot <- filter(proficiency_data, language_name == "python") %>% ggplot() +
  aes(years_used, proficiency) +
  geom_point(position = position_jitter(width = 0.2, height = 0.2)) +
  geom_smooth(method = "lm", formula = y ~ x + I(x^2), se = FALSE, color = "black") +
  t_$base +
  coord_cartesian(xlim = c(0, 20), ylim = c(1, 5)) +
  labs(x = "Years used", y = "Self-reported proficiency", title = "Python")


# paradigms per language ----
n_paradigms <- collect_table("language_paradigms") %>%
  group_by(language_name) %>%
  summarize(n_paradigms = n())

questionnaire <- collect_table("questionnaire")

# Functional v imperative top ----
functional_v_imperative_top_language <- collect_table("languages") %>%
  filter_first_languages() %>%
  inner_join(get_functional_v_imperative()) %>%
  left_join(questionnaire, .) %>%
  recode_functional_v_imperative() %>%
  drop_na(paradigm_name)

functional_v_imperative_top_language_plot <- ggplot(functional_v_imperative_top_language) +
  aes(paradigm_label, cr1, color = paradigm_name) +
  geom_point(position = position_jitter(width = 0.15, height = 0.2),
             shape = 1, size = 2, alpha = 0.6) +
  stat_summary(geom = "errorbar", fun.data = "mean_se", width = 0.4, size = 1.5) +
  scale_x_discrete(position = "top") +
  scale_color_brewer(palette = "Set2") +
  t_$base +
  theme(legend.position = "none") +
  coord_flip() +
  labs(x = "", y = "agreement", title = create_wrapped_title("cr1"))


# Functional v imperative all ----
functional_v_imperative_all_language <- collect_table("languages") %>%
  filter_known_languages() %>%
  inner_join(get_functional_v_imperative()) %>%
  left_join(questionnaire, .) %>%
  recode_functional_v_imperative() %>%
  drop_na(paradigm_name)

functional_v_imperative_all_language_plot <- ggplot(functional_v_imperative_all_language) +
  aes(paradigm_label, cr1, color = paradigm_name) +
  geom_point(position = position_jitter(width = 0.15, height = 0.2),
             shape = 1, size = 2, alpha = 0.6) +
  stat_summary(geom = "errorbar", fun.data = "mean_se", width = 0.4, size = 1.5) +
  scale_x_discrete(position = "top") +
  scale_color_brewer(palette = "Set2") +
  t_$base +
  theme(legend.position = "none") +
  coord_flip() +
  labs(x = "", y = "agreement", title = create_wrapped_title("cr1"))


# Functional v object all ----
functional_v_object_all_language <- collect_table("languages") %>%
  filter_known_languages() %>%
  inner_join(get_functional_v_object()) %>%
  left_join(questionnaire, .) %>%
  recode_functional_v_object() %>%
  drop_na(paradigm_name)

functional_v_object_all_language_plot <- ggplot(functional_v_object_all_language) +
  aes(paradigm_label, cr1, color = paradigm_name) +
  geom_point(position = position_jitter(width = 0.15, height = 0.2),
             shape = 1, size = 2, alpha = 0.6) +
  stat_summary(geom = "errorbar", fun.data = "mean_se", width = 0.4, size = 1.5) +
  scale_x_discrete(position = "top") +
  scale_color_brewer(palette = "Set2") +
  t_$base +
  theme(legend.position = "none") +
  coord_flip() +
  labs(x = "", y = "agreement", title = create_wrapped_title("cr1"))

