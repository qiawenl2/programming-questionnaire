# Get languages represented in the survey
get_languages <- function(responses) {
  language_questions <- unique(responses$question_label) %>%
    grep("^languages", x = ., value = TRUE)
  language_ixs <- str_match(language_questions, "languages-Language (\\d)")[,2] %>%
    as.integer()

  question_label_map <- data_frame(
    question_label = language_questions,
    language_ix = language_ixs
  )
  
  languages <- responses %>%
    filter(question_label %in% language_questions) %>%
    left_join(question_label_map) %>%
    mutate(language_name = str_to_lower(response_str)) %>%
    select(subj_id, language_ix, language_name) %>%
    drop_na() %>%
    arrange(subj_id, language_ix)
  
  experience <- responses %>%
    filter(question_name == "experience") %>%
    match_language_question_str() %>%
    select(subj_id, language_ix, question_tag, response_str) %>%
    arrange(subj_id, question_tag, language_ix) %>%
    drop_na() %>%
    spread(question_tag, response_str) %>%
    rename(
      age_started = age,
      years_used = years
    ) %>%
    mutate(
      age_started = as.integer(age_started),
      years_used = as.integer(years_used)
    ) %>%
    recode_agreement("proficiency", replace_with_num = TRUE)

  left_join(languages, experience)
}


# Get ratings of languages in long format
get_language_ratings <- function(responses, languages) {
  question_names <- c("intuitiveness", "reuse", "practices")
  ratings <- responses %>%
    filter(question_name %in% question_names) %>%
    match_language_question_str()

  language_names <- languages %>%
    select(subj_id, language_ix, language_name)

  ratings %>%
    left_join(language_names) %>%
    select(subj_id, question_name, language_ix, language_name, question_tag, agreement_str = response_str) %>%
    arrange(question_name, question_tag, subj_id, language_ix) %>%
    recode_agreement("agreement_str")
}


# Extract language ix and question tag from language question string
match_language_question_str <- function(frame) {
  re_language_question <- "[a-z]+#\\d_Language(\\d)_([A-Za-z]+)"
  labels <- str_match(frame$question_str, re_language_question)[, 2:3] %>%
    as_data_frame() %>%
    rename(
      language_ix = V1,
      question_tag = V2
    ) %>%
    mutate(language_ix = as.integer(language_ix))
  cbind(frame, labels) %>%
    as_data_frame()
}


# Overwrite some language names with corrections.
recode_language_names <- function(languages) {
  recoded_languages <- tibble::tribble(
                    ~language_name, ~new_language_name,
               "apple/hyperscript",      "applescript",
                             "asp",          "asp.net",
                       "assembler",         "assembly",
                        "assembly",         "assembly",
                  "assembly (x86)",         "assembly",
               "assembly language",         "assembly",
         "assembly language (x86)",         "assembly",
                            "bash",       "unix shell",
     "basic (vba/qb and variants)",            "basic",
                         "c sharp",               "c#",
                           "c/c++",              "c++",
                   "clojurescript",          "clojure",
                         "closure",          "clojure",
                           "cmake",       "unix shell",
                     "common lisp",             "lisp",
                          "csharp",               "c#",
                          "delphi",    "object pascal",
                   "delphi/pascal",    "object pascal",
                           "elixi",           "elixir",
                      "emacs-lisp",             "lisp",
                          "fsharp",               "f#",
                            "gawk",       "unix shell",
                          "golang",               "go",
                      "glsl","opengl shading language",
                          "haskel",          "haskell",
                  "hlsl","high level shading language",
                        "html/css",             "html",
                     "idl","interactive data language",
                    "isabelle/hol",         "isabelle",
                            "jaca",             "java",
             "javascript/css/html",       "javascript",
                              "js",       "javascript",
                     "jscript.net",       "javascript",
                           "latex",              "tex",
                   "linux command",       "unix shell",
          "lips (scheme, clojure)",          "clojure",
                     "lsl","linden scripting language",
                         "node.js",       "javascript",
"motorola 68000 assembly language",         "assembly",
                          "mstlsb",           "matlab",
                          "o'caml",            "ocaml",
                     "objective c",      "objective-c",
                      "objectivec",      "objective-c",
                          "pyhton",           "python",
                           "shell",       "unix shell",
                    "shell script",       "unix shell",
                 "shell scripting",       "unix shell",
                             "sml",      "standard ml",
                       "sml/ocaml",            "ocaml",
                           "t-sql",     "transact-sql",
                         "tcl","tool command language",
                              "vb",     "visual basic",
                          "vb.net",     "visual basic",
                             "vba",     "visual basic",
                             "vbs",     "visual basic",
                        "vbscript",     "visual basic",
                     "visualbasic",     "visual basic",
                             "x86",         "assembly",
       "xaml","extensible application markup language")

  untouched <- languages %>%
    filter(!(language_name %in% recoded_languages$language_name))
  recoded <- languages %>%
    inner_join(recoded_languages) %>%
    select(-language_name) %>%
    rename(language_name = new_language_name)
  bind_rows(untouched, recoded)
}
