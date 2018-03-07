library(WikidataR)


# Retrieve metadata about programming languages from Wikidata
fetch_language_info_from_wikidata <- function(language_names) {
    language_info <- data_frame(language_name = language_names[1:20]) %>%
      get_all_programming_languages() %>%
      extract_instance_of_properties() %>%
      extract_programming_paradigms() %>%
      select(language_name, instance_of, paradigm) %>%
      gather(property_type, property_name, -language_name) %>%
      unnest() %>%
      mutate(paradigm_name = str_replace(property_name, " programming( language)?", "")) %>%
      select(language_name, paradigm_name) %>%
      unique()
}

get_all_programming_languages <- function(languages) {
  languages$programming_language <- map(languages$language_name, function(name) {
    programming_language <- list()
    tryCatch({
      programming_language <- get_programming_language(name)
    }, error = function(e) {
      print(e)
    })
    return(programming_language)
  })
  return(languages)
}


# Get the Wikidata item for a programming language
get_programming_language <- function(name) {
  candidates <- find_item(name)
  for(candidate in candidates) {
    if(is.null(candidate$description)) {
      description <- ""
    } else {
      description <- candidate$description
    }

    is_programming_language <- (
      grepl("programming language", description, ignore.case = TRUE) |
      "programming language" %in% get_instance_of_properties(candidate$id)
    )
    if(is_programming_language) {
        programming_language <- get_item(candidate$id)[[1]]
        return(programming_language)
    }
  }
  
  stop(paste(name, "is not a programming language"))
}


extract_instance_of_properties <- function(languages) {
  languages$instance_of <- map(languages$programming_language, function(programming_language) {
    properties <- character()
    if(is.null(programming_language)) return(properties)
    tryCatch({
      properties <- get_instance_of_properties(programming_language)
    }, error = function(e) {
      print(e)
    })
    return(properties)
  })
  return(languages)
}


get_instance_of_properties <- function(wikidata_item) {
  if(typeof(wikidata_item) == "character") {
    wikidata_item <- get_item(wikidata_item)[[1]]
  }
  instance_of <- "P31"  # identifier for "instance_of" Wikidata property
  wikidata_item$claims[[instance_of]]$mainsnak$datavalue$value$id %>%
    purrr::map(get_label_from_id) %>%
    unlist() %>%
    as.character()
}


extract_programming_paradigms <- function(languages) {
  languages$paradigm <- map(languages$programming_language, function(programming_language) {
    paradigms <- character()
    if(is.null(programming_language)) return(paradigms)
    tryCatch({
      paradigms <- get_programming_paradigms(programming_language)
    }, error = function(e) {
      print(e)
    })
    return(paradigms)
  })
  return(languages)
}


# Get the programming paradigms associated with a language from Wikipedia
get_programming_paradigms <- function(programming_language) {
  if(typeof(programming_language) == "character") {
    programming_language <- get_programming_language(programming_language)
  }
  programming_paradigm_id <- "P3966"
  tryCatch({
    paradigms <- programming_language$claims[[programming_paradigm_id]]$mainsnak$datavalue$value$id %>%
      purrr::map(get_label_from_id) %>%
      unlist() %>%
      as.character()
  }, error = function(e) {
    stop(paste0('Error getting paradigms for language \'', name, '\'.'))
  })
  
  return(paradigms)
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
    "unix shell", "scripting language"
  )
  bind_rows(wikipedia_languages, manual_languages)
  wikipedia_languages
}