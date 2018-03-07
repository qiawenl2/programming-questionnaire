library(RNeo4j)

load_languages_in_graph_db <- function(language_info) {
  graph <- startGraph()
  
  addConstraint(graph, "Language", "name")
  addConstraint(graph, "Property", "name")
  
  query = "
  MERGE (language:Language { name: {language_name} })
  MERGE (property:Property { name: {property_name} })
  CREATE (language)-[:WIKIDATA_PROPERTY { name: {property_type} }]->(property)
  "
  tx = newTransaction(graph)
  for(i in 1:nrow(language_info)) {
    row = language_info[i, ]
    appendCypher(tx, query,
                 language_name=row$language_name,
                 property_name=row$property_name,
                 property_type=row$property_type)
  }
  commit(tx)
}

load_stack_overflow_language_ranks <- function(stack_overflow_ranks) {
  graph <- startGraph()
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
