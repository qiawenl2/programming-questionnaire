library(RNeo4j)

connect_neo4j <- function(username = NULL, password = NULL) {
  if(is.null(username)) username <- "neo4j"
  if(is.null(password)) password <- Sys.getenv("NEO4J_PASSWORD")
  RNeo4j::startGraph('http://localhost:7474/db/data',
                     username = username, password = password)
}

get_functional_v_imperative <- function() {
  dplyr::bind_rows(
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
  RNeo4j::cypher(graph, query)
}

get_functional_and_imperative <- function() {
  graph <- connect_neo4j()
  query = '
  MATCH (language:Language)
  MATCH (language) -[:TYPEOF]-> (:Paradigm { name: "functional" })
  MATCH (language) -[:TYPEOF]-> (:Paradigm { name: "imperative" })
  RETURN language.name as language_name'
  RNeo4j::cypher(graph, query)
}

get_imperative_not_functional <- function() {
  graph <- connect_neo4j()
  query = '
  MATCH (language:Language)
  MATCH (language) -[:TYPEOF]-> (:Paradigm { name: "imperative" })
  WHERE NOT (language)-[:TYPEOF]-> (:Paradigm { name: "functional" })
  RETURN language.name as language_name'
  RNeo4j::cypher(graph, query)
}

get_functional_v_object <- function() {
  dplyr::bind_rows(
    functional = get_functional_not_object(),
    both = get_functional_and_object(),
    `object-oriented` = get_object_not_functional(),
    .id = "paradigm_name"
  )
}

get_functional_not_object <- function() {
  graph <- connect_neo4j()
  query = '
  MATCH (language:Language)
  MATCH (language) -[:TYPEOF]-> (:Paradigm { name: "functional" })
  WHERE NOT (language)-[:TYPEOF]-> (:Paradigm { name: "object-oriented" })
  RETURN language.name as language_name'
  RNeo4j::cypher(graph, query)
}

get_functional_and_object <- function() {
  graph <- connect_neo4j()
  query = '
  MATCH (language:Language)
  MATCH (language) -[:TYPEOF]-> (:Paradigm { name: "functional" })
  MATCH (language) -[:TYPEOF]-> (:Paradigm { name: "object-oriented" })
  RETURN language.name as language_name'
  RNeo4j::cypher(graph, query)
}

get_object_not_functional <- function() {
  graph <- connect_neo4j()
  query = '
  MATCH (language:Language)
  MATCH (language) -[:TYPEOF]-> (:Paradigm { name: "object-oriented" })
  WHERE NOT (language)-[:TYPEOF]-> (:Paradigm { name: "functional" })
  RETURN language.name as language_name'
  RNeo4j::cypher(graph, query)
}

load_languages_in_graph_db <- function(language_info) {
  graph <- connect_neo4j()
  
  RNeo4j::addConstraint(graph, "Language", "name")
  RNeo4j::addConstraint(graph, "Paradigm", "name")
  
  query = "
  MERGE (language:Language { name: {language_name} })
  MERGE (paradigm:Paradigm { name: {paradigm_name} })
  CREATE (language)-[:TYPEOF]->(paradigm)
  "
  tx = RNeo4j::newTransaction(graph)
  for(i in 1:nrow(language_info)) {
    row = language_info[i, ]
    RNeo4j::appendCypher(tx, query,
                 language_name=row$language_name,
                 paradigm_name=row$paradigm_name)
  }
  RNeo4j::commit(tx)
}

load_stack_overflow_language_ranks <- function(stack_overflow_ranks) {
  graph <- connect_neo4j()
  RNeo4j::addConstraint(graph, "Language", "stack_overflow_rank")
  query = "MATCH (language:Language { name: {language_name} })
           SET language.stack_overflow_rank = {rank}
           RETURN language"
  tx = RNeo4j::newTransaction(graph)
  for(i in 1:nrow(stack_overflow_ranks)) {
    row = stack_overflow_ranks[i, ]
    RNeo4j::appendCypher(tx, query,
                 language_name=row$language_name,
                 rank=row$rank)
  }
  RNeo4j::commit(tx)
}
