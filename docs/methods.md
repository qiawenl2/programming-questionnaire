# Methods

The materials required to reproduce our research are included in this repo.

```bash
# Quickstart
git clone https://github.com/lupyanlab/programming-questionnaire.git
cd programming-questionnaire/
cp qualtrics.yml.template qualtrics.yml
# edit qualtrics.yml to enter your Qualtrics API token
make  # downloads all data and installs it in an R package called "programmingquestionnaire"
```

Requirements:

```R
install.packages(c("qualtRics", "WikidataR", "RSQLite"))
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

Meta-data on programming languages was collected from the Wikidata service.

Note: The R package "WikidataR" is required for downloading language info.

```R
source("R/wikidata.R")
languages <- c("python", "java", "go")
paradigms <- get_programming_paradigms(languages)
```

## Graph data

The relationships between languages and programming paradigms lends itself
nicely to graph-based analysis. To load the languages and their paradigms
collected from Wikidata into a graph database, follow the steps below which
are required to run the "bin/load-neo4j.R" script.

```bash
brew install neo4j  # install the Neo4j graph database with homebrew
neo4j start         # start the db, open a browser to localhost:7474, and set a password
export NEO4J_PASSWORD=mysecretpassword
bin/load-neo4j.R    # load language data in the graph db
```

## StackOverflow Developer Survey

The results of the annual StackOverflow Developer Survey
can be downloaded from here:
[insights.stackoverflow.com/survey](https://insights.stackoverflow.com/survey)

After the results have been downloaded, move them into the expected directory:

```bash
mv ~/Downloads/developer_survey_2017.zip ./data-raw/stack-overflow-developer-survey-2017.zip
unzip ./data-raw/stack-overflow-developer-survey-2017.zip -d ./data-raw/stack-overflow-developer-survey-2017
```

## SQLite Database

The data were processed to yield the following tables. To create all tables and
store them in a SQLite DB, run the "make" command. See the
[Makefile](./Makefile) for more targets of the "make" command.

Note: The R package "RSQLite" is required for storing the data in a SQLite DB.

```bash
make programming-questionnaire.sqlite  # creates "programming-questionnaire.sqlite" with all tables
```

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
: Responses to agreement and free response questions in wide format.

language_paradigms
: Information about programming languages taken from Wikipedia.

### Reading tables from the SQLite DB

Examples of how to read tables in from a SQLite DB in both R and python are included
below.

```R
# in R
library(dplyr)
con <- DBI::dbConnect(RSQLite::SQLite(), "programming-questionnaire.sqlite")
table_name <- "responses"
responses <- tbl(con, table_name) %>% collect()
```

```python
# in python3
import sqlite3
import pandas
con = sqlite3.connect("programming-questionnaire.sqlite")
table_name = 'responses'
responses <- pandas.read_sql_query(f'select * from {table_name}', con)
```

SQLite wrapper functions are stored in "R/sqlite.R".

```
source("R/sqlite.R")
responses <- collect_table("responses")  # expects "programming-questionnaire.sqlite" to exist
```
