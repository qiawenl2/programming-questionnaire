library(WikidataR)


# Extract programming language metadata from Wikipedia
get_language_info <- function(languages) {
  unique(languages$language_name) %>%
    map(get_programming_paradigms) %>%
    bind_rows() %>%
    as_data_frame()
}


# Get the programming paradigms associated with a language from Wikipedia
get_programming_paradigms <- function(name) {
  language_info <- data.frame()
  tryCatch({
    programming_language <- get_programming_language(name)
    instance_of <- "P31"  # identifier for "instance_of" Wikidata property
    paradigms <- programming_language[[1]][["claims"]][[instance_of]][["mainsnak"]][["datavalue"]][["value"]][["id"]] %>%
      purrr::map(get_label_from_id) %>%
      unlist()
    language_info <- data_frame(
      language = name,
      wikidata_id = programming_language[[1]]$id,
      paradigms = paradigms
    )
  }, error = function(e) {
    print(paste0('Error getting paradigms for language \'', name, '\': ', e))
  })
  language_info
}


# Get the Wikidata item for a programming language
get_programming_language <- function(name) {
  candidates <- find_item(name)
  for(candidate in candidates) {
    is_programming_language <- grepl("programming language", candidate$description, ignore.case = TRUE)
    if(is_programming_language) {
      return(get_item(candidate$id))
    }
  }
  print(paste(name, "is not a programming language"))
}





# Extract the label of a Wikidata item
get_wikidata_label <- function(item) {
  item[[1]]$labels$en$value
}


# Get the label for a Wikidata item from its id
get_label_from_id <- function(id) {
  item <- get_item(id)
  get_wikidata_label(item)
}
