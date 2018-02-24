# Collect a table from the SQLite DB
collect_table <- function(table_name, db_name = "programming-questionnaire.sqlite") {
  con <- DBI::dbConnect(RSQLite::SQLite(), db_name)
  tbl(con, table_name) %>%
    collect()
}