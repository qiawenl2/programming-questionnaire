#!/usr/bin/env Rscript
devtools::load_all()

args <- commandArgs(trailingOnly = TRUE)
if(args[[1]] == '--clear') {
  library(RNeo4j)
  print('clearing graph')
  graph <- connect_neo4j()
  clear(graph, input = FALSE)
}

language_info <- collect_table("language_info")
load_languages_in_graph_db(language_info)

stack_overflow_ranks <- collect_table("stack_overflow_ranks")
load_stack_overflow_language_ranks(stack_overflow_ranks)
