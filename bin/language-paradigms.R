#!/usr/bin/env Rscript
devtools::load_all()
languages <- read_csv("data-raw/languages.csv")
language_paradigms <- unique(languages$language_name) %>%
  fetch_language_info_from_wikidata() %>%
  add_manual_languages()

write_csv(language_paradigms, "data-raw/language-paradigms.csv")