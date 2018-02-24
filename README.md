# Reproducing

## Getting the scripts

```bash
git clone https://github.com/lupyanlab/programming-questionnaire.git
cd programming-questionnaire/
```

## Authenticating

Replace the template yaml file with the expected file, "qualtrics.yml",
and update it with your authentication credentials.

```bash
cp qualtrics.yml.template qualtrics.yml
# edit qualtrics.yml to replace YOUR_API_TOKEN_HERE with your Qualtrics API token.
```

## Required packages

- qualtRics
- RSQLite

## Downloading the data

Note: The R package "qualtRics" is required for downloading the data.

```bash
source("R/qualtrics.R")  # authenticates with qualtrics.yml
qualtrics <- get_qualtrics_responses("programming questionnaire")
questions <- get_qualtrics_questions("programming questionnaire")
```

# Data

## Tables

qualtrics
: Raw responses in wide format as if downloaded directly from Qualtrics.

questions
: Survey question data as obtained from the Qualtrics API.

responses
: Response data in long format.

languages
: Programming languages represented in the the sample.

## Create all tables

Note: The R package "RSQLite" is required for storing the data in a SQLite DB.

```bash
Rscript make-sqlite.R  # creates programming-questionnaire.sqlite with all tables above
```

## Reading tables from the SQLite DB

The logic for reading a table in from the SQLite DB is simple.

```R
library(dplyr)
table_name <- "responses"
con <- DBI::dbConnect(RSQLite::SQLite(), db_name)
responses <- tbl(con, table_name) %>%
  collect()
```

SQLite helper functions are stored in "R/sqlite.R".

```
source("R/sqlite.R")
responses <- collect_table("responses")  # expected "programming-questionnaire.sqlite"
```
