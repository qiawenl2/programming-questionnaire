library(RNeo4j)

connect_neo4j <- function(username = NULL, password = NULL) {
  if(is.null(username)) username <- "neo4j"
  if(is.null(password)) password <- Sys.getenv("NEO4J_PASSWORD")
  startGraph('http://ec2-54-245-155-164.us-west-2.compute.amazonaws.com:80/db/data',
             username = username, password = password)
}

load_languages_in_graph_db <- function(language_info) {
  graph <- connect_neo4j()
  
  addConstraint(graph, "Language", "name")
  addConstraint(graph, "Paradigm", "name")
  
  query = "
  MERGE (language:Language { name: {language_name} })
  MERGE (paradigm:Paradigm { name: {paradigm_name} })
  CREATE (language)-[:TYPEOF]->(paradigm)
  "
  tx = newTransaction(graph)
  for(i in 1:nrow(language_info)) {
    row = language_info[i, ]
    appendCypher(tx, query,
                 language_name=row$language_name,
                 paradigm_name=row$paradigm_name)
  }
  commit(tx)
}

load_stack_overflow_language_ranks <- function(stack_overflow_ranks) {
  graph <- connect_neo4j()
  addConstraint(graph, "Language", "stack_overflow_rank")
  query = "MATCH (language:Language { name: {language_name} })
           SET language.stack_overflow_rank = {rank}
           RETURN language"
  tx = newTransaction(graph)
  for(i in 1:nrow(stack_overflow_ranks)) {
    row = stack_overflow_ranks[i, ]
    appendCypher(tx, query,
                 language_name=row$language_name,
                 rank=row$rank)
  }
  commit(tx)
}
