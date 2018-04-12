# Methods

The materials required to reproduce our research are included in this repo.
To get started, start by cloning this repo.

```bash
git clone https://github.com/lupyanlab/programming-questionnaire.git
cd programming-questionnaire/
```

## Qualtrics

The survey was created in Qualtrics. In order to obtain the survey data, you
must have a Qualtrics account, and have access to the survey. Once you have
an account and have access to the survey, you can download the survey data
from within R by authenticating your identity with your Qualtrics API key.

### Authenticating

After obtaining your Qualtrics API key, place it in a file named "qualtrics.yml"
in the project root directory (e.g., "programming-questionnaire/qualtrics.yml").
To create the qualtrics.yml file from a template, copy the file "qualtrics.yml.template"
to the expected location. Then edit the file, replacing YOUR_API_TOKEN_HERE
with your Qualtrics API key.

```bash
cp qualtrics.yml.template qualtrics.yml
# edit qualtrics.yml to replace YOUR_API_TOKEN_HERE with your Qualtrics API token.
```

### Downloading the data from Qualtrics

To download the survey data from Qualtrics, source the functions in
"R/qualtrics.R". This gives you the two primary functions,
`get_qualtrics_responses` and `get_qualtrics_questions`. The argument
to these functions is the name of the Qualtrics survey being downloaded.

Note: The R package `qualtRics` is required for downloading the data.

```R
source("R/qualtrics.R")  # authenticates with qualtrics.yml
qualtrics <- get_qualtrics_responses("programming questionnaire")
questions <- get_qualtrics_questions("programming questionnaire")
```

## Wikidata

Meta-data on programming languages was taken from the Wikidata service.

Note: The R package "WikidataR" is required for downloading language info.

```R
source("R/wikidata.R")
language_info <- get_language_info(languages)
```

## StackOverflow Developer Survey

The results of the annual StackOverflow Developer Survey
can be downloaded from here:
[insights.stackoverflow.com/survey](https://insights.stackoverflow.com/survey)

## Data

Once acquired, the data were processed to yield the following tables.

### Tables

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

### Create all tables in a SQLite DB

To create all tables and store them in the SQLite DB, run the "make-sqlite.R" script.

Note: The R package "RSQLite" is required for storing the data in a SQLite DB.

```bash
make programming-questionnaire.sqlite  # creates "programming-questionnaire.sqlite" with all tables
```

### Reading tables from the SQLite DB

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

