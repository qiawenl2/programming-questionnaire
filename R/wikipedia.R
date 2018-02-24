library(WikidataR)


get_language_info <- function(language_names) {
  language_names %>%
    map(get_programming_paradigms) %>%
    bind_rows() %>%
    as_data_frame()
}


get_programming_paradigms <- function(name) {
  language_info <- data.frame()
  tryCatch({
    programming_paradigm <- "P3966"
    programming_language <- get_programming_language(name)
    paradigms <- programming_language[[1]][["claims"]][[programming_paradigm]][["mainsnak"]][["datavalue"]][["value"]][["id"]] %>%
      purrr::map(get_label_from_id) %>%
      unlist()
    language_info <- data_frame(
      language = name,
      paradigms = paradigms
    )
  }, error = function(e) {
    print(paste0('Error getting paradigms for language: ', name))
  })
  language_info
}


# Get the Wikidata item for a programming language.
get_programming_language <- function(name) {
  candidates <- find_item(name)
  for (candidate in items) {
    is_programming_language <- grepl("programming language", candidate$description)
    if(is_programming_language) {
      return(get_item(candidate$id))
    }
  }
  stop(paste(name, "is not a programming language"))
}


get_label_from_id <- function(id) {
  item <- get_item(id)
  get_label(item)
}


get_label <- function(item) {
  item[[1]]$labels$en$value
}


get_item_from_name <- function(name) {
  id <- find_item(name)[[1]]$id
  get_item(id)
}

