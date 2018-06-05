filter_first_languages <- function(frame) {
  filter(frame, language_ix == 1)
}

filter_known_languages <- function(frame) {
  e_ <- new.env()
  data("language_paradigms", package = "programmingquestionnaire", envir = e_)
  known_languages <- unique(e_$language_paradigms$language_name)
  filter(frame, language_name %in% known_languages)
}