# Verify language inputs
devtools::load_all()

# Write all language names to a file.
write_all_languages <- function() {
  languages <- collect_table("languages")
  given_languages <- unique(languages$language_name) %>% sort()
  write.csv(data.frame(language_name=given_languages), "data-raw/language-names.csv",
            row.names = FALSE)
}

# Paste the language names that need to be recoded.
paste_language_name_recodes <- function() {
  read_csv("data-raw/language-names-recoded.csv") %>%
    drop_na(new_language_name) %>%
    datapasta::tribble_paste()
}

# Write unknown languages to a file.
write_unknown_languages <- function() {
  languages <- collect_table("languages")
  language_info <- collect_table("language_info")
  given_languages <- unique(languages$language_name)
  known_languages <- unique(language_info$language_name)
  unknown_languages <- given_languages[!(given_languages %in% known_languages)] %>% sort()
  write.csv(data.frame(unknown_language=unknown_languages),
            "data-raw/unknown-languages.csv", row.names=FALSE)
}


paste_known_languages <- function() {
  read_csv("data-raw/unknown-languages-recoded.csv") %>%
    drop_na(is_language) %>%
    select(-is_language) %>%
    .$language_name %>%
    dput()
}