library(WikidataR)


# Extract programming language metadata from Wikipedia
get_language_info <- function(languages) {
  unique(languages$language_name) %>%
    map(get_programming_language) %>%
    bind_rows() %>%
    as_data_frame()
}


# Get the programming paradigms associated with a language from Wikipedia
get_programming_paradigms <- function(name) {
  tryCatch({
    programming_language <- get_programming_language(name)
  }, error = function(e) {
    cat(paste0('Error: \'', name, '\' is not a programming language'))
    return(data_frame())
  })
  
  programming_paradigm_id <- "P3966"
  paradigms <- NULL
  tryCatch({
    paradigms <- programming_language[["claims"]][[programming_paradigm_id]][["mainsnak"]][["datavalue"]][["value"]][["id"]] %>%
      purrr::map(get_label_from_id) %>%
      unlist()
  }, error = function(e) {
    cat(paste0('Error getting paradigms for language \'', name, '\'.'))
    return(data_frame(language_name = name, wikidata_id = programming_language$id))
  })
  
  if(is.null(paradigms)) {
    paradigms <- get_instance_of_properties(programming_language$id)
  }
  
  data_frame(
    language_name = name,
    wikidata_id = programming_language$id,
    paradigm = paradigms
  )
}


# Get the Wikidata item for a programming language
get_programming_language <- function(name) {
  candidates <- find_item(name)
  for(candidate in candidates) {
    candidate_properties <- get_instance_of_properties(candidate$id)
    is_programming_language <- (
      grepl("programming language", candidate$description, ignore.case = TRUE) |
      grepl("scripting language", candidate$description, ignore.case = TRUE) |
      "programming language" %in% candidate_properties
    )
    if(is_programming_language) {
      return(get_item(candidate$id)[[1]])
    }
  }
  
  stop(paste(name, "is not a programming language"))
}


get_instance_of_properties <- function(wikidata_id) {
  instance_of <- "P31"  # identifier for "instance_of" Wikidata property
  get_item(wikidata_id)[[1]][["claims"]][[instance_of]][["mainsnak"]][["datavalue"]][["value"]][["id"]] %>%
    purrr::map(get_label_from_id) %>%
    unlist()
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


add_manual_languages <- function(wikipedia_languages) {
  manual_languages <- tibble::tribble(
    ~language_name,          ~paradigm,
    "unix shell", "scripting language",
    "hlsl"
  )
  bind_rows(wikipedia_languages, manual_languages)
  wikipedia_languages
}