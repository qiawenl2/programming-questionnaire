recode_functional_v_imperative <- function(frame) {
  levels <- c("imperative", "both", "functional")
  map <- data_frame(
    paradigm_name = levels,
    paradigm_label = factor(levels, levels = levels),
    functional_v_imperative = c(1, 0, 0),
    functional_v_both = c(0, 1, 0)
  )
  if(missing(frame)) return(map)
  left_join(frame, map)
}


recode_functional_v_object <- function(frame) {
  levels <- c("object-oriented", "both", "functional")
  map <- data_frame(
    paradigm_name = levels,
    paradigm_label = factor(levels, levels = levels),
    functional_v_object = c(1, 0, 0),
    functional_v_both = c(0, 1, 0)
  )
  if(missing(frame)) return(map)
  left_join(frame, map)
}

recode_reuse <- function(frame) {
  reuse_levels <- c("adapt",  "reuse", "adopt")
  reuse_map <- data_frame(
    question_tag = reuse_levels,
    reuse_label = factor(reuse_levels, levels = reuse_levels)
  )
  if(missing(frame)) return(reuse_map)
  left_join(frame, reuse_map)
}

mutate_years_used_sqr <- function(frame) {
  frame %>%
    mutate(
      years_used_sqr = years_used * years_used,
      years_used_z_sqr = years_used_z * years_used_z
    )
}

z_score <- function(x) (x - mean(x, na.rm = TRUE))/sd(x, na.rm = TRUE)

standardize_years_used <- function(frame) {
  mutate(frame, years_used_z = z_score(years_used))
}

standardize_years_used_by_language <- function(frame) {
  frame %>%
    group_by(language_name) %>%
    mutate(years_used_z = z_score(years_used)) %>%
    ungroup()
}