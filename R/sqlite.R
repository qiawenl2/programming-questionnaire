# Collect a table from the SQLite DB
collect_table <- function(table_name, db_name = "programming-questionnaire.sqlite") {
  con <- DBI::dbConnect(RSQLite::SQLite(), db_name)
  frame <- tbl(con, table_name) %>%
    collect()
  DBI::dbDisconnect(con)
  frame
}

# List the tables in a SQLite DB.
list_tables <- function(db_name = "programming-questionnaire.sqlite") {
  con <- DBI::dbConnect(RSQLite::SQLite(), db_name)
  table_names <- DBI::dbListTables(con)
  DBI::dbDisconnect(con)
  table_names
}