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
- WikidataR

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

questionnaire
: Responses to agreement questions and short responses in wide format.

language_info
: Information about programming languages taken from Wikipedia.

## Create all tables

To create all tables and store them in the SQLite DB, run the "make-sqlite.R" script.

Note: The R package "RSQLite" is required for storing the data in a SQLite DB.
Note: The R package "WikidataR" is required for downloading language info.

```bash
./make-sqlite.R  # creates programming-questionnaire.sqlite with all tables
```

## Reading tables from the SQLite DB

The logic for reading a table in from a SQLite DB file is simple in R and python.

```R
# in R
library(dplyr)
con <- DBI::dbConnect(RSQLite::SQLite(), "programming-questionnaire.sqlite")
responses <- tbl(con, "responses") %>% collect()
```

```python
# in python
import sqlite3
import pandas
con = sqlite3.connect("programming-questionnaire.sqlite")
responses <- pandas.read_sql_query('select * from responses', con)
```

SQLite wrapper functions are stored in "R/sqlite.R".

```
source("R/sqlite.R")
responses <- collect_table("responses")  # expects "programming-questionnaire.sqlite"
```
