filter_first_languages <- function(frame) {
  filter(frame, language_ix == 1)
}

filter_known_languages <- function(frame) {
  known_languages <- unique(collect_table("language_paradigms")$language_name)
  filter(frame, language_name %in% known_languages)
}