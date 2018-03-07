library(RNeo4j)
devtools::load_all()

clear_graph = TRUE

graph <- startGraph()
if(clear_graph) clear(graph, input = FALSE)

language_info <- collect_table("language_info")
load_languages_in_graph_db(language_info)

stack_overflow_ranks <- collect_table("stack_overflow_ranks")
load_stack_overflow_language_ranks(stack_overflow_ranks)
