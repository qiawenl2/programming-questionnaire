library(RNeo4j)

connect_neo4j <- function(username = NULL, password = NULL) {
  if(is.null(username)) username <- "neo4j"
  if(is.null(password)) password <- Sys.getenv("NEO4J_PASSWORD")
  startGraph('http://ec2-54-245-155-164.us-west-2.compute.amazonaws.com:80/db/data',
             username = username, password = password)
}

get_functional_v_imperative <- function() {
  bind_rows(
    functional = get_functional_not_imperative(),
    both = get_functional_and_imperative(),
    imperative = get_imperative_not_functional(),
    .id = "paradigm_name"
  )
}

get_functional_not_imperative <- function() {
  graph <- connect_neo4j()
  query = '
  MATCH (language:Language)
  MATCH (language) -[:TYPEOF]-> (:Paradigm { name: "functional" })
  WHERE NOT (language)-[:TYPEOF]-> (:Paradigm { name: "imperative" })
  RETURN language.name as language_name'
  cypher(graph, query)
}

get_functional_and_imperative <- function() {
  graph <- connect_neo4j()
  query = '
  MATCH (language:Language)
  MATCH (language) -[:TYPEOF]-> (:Paradigm { name: "functional" })
  MATCH (language) -[:TYPEOF]-> (:Paradigm { name: "imperative" })
  RETURN language.name as language_name'
  cypher(graph, query)
}

get_imperative_not_functional <- function() {
  graph <- connect_neo4j()
  query = '
  MATCH (language:Language)
  MATCH (language) -[:TYPEOF]-> (:Paradigm { name: "imperative" })
  WHERE NOT (language)-[:TYPEOF]-> (:Paradigm { name: "functional" })
  RETURN language.name as language_name'
  cypher(graph, query)
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
