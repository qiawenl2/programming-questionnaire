qualtrics := data-raw/qualtrics.csv data-raw/questions.csv data-raw/responses.csv
survey := data-raw/languages.csv data-raw/language-ratings.csv data-raw/questionnaire.csv data-raw/demographics.csv data-raw/irq.csv
languages := data-raw/language-paradigms.csv data-raw/stack-overflow.csv data-raw/stack-overflow-ranks.csv

.PHONY: neo4j

all: programming-questionnaire.sqlite languages.md beliefs.md

data-blitz.pdf: data-blitz.Rmd
	Rscript -e 'rmarkdown::render("$<", output_format = "all", ouput_file = "$@")'

qualtrics: $(qualtrics)
$(qualtrics): bin/qualtrics.R
	./bin/qualtrics.R

survey: $(survey)
$(survey): bin/survey.R
	./bin/survey.R

languages: $(languages)
data-raw/language-paradigms.csv: bin/language-paradigms.R
	./bin/language-paradigms.R
data-raw/stack-overflow.csv data-raw/stack-overflow-ranks.csv: bin/language-ranks.R
	./bin/language-ranks.R

programming-questionnaire.sqlite: bin/sqlite.R $(qualtrics) $(survey) $(languages)
	./bin/sqlite.R

neo4j: bin/neo4j.R
	./bin/neo4j.R --clear

languages.md: languages.Rmd
	Rscript -e 'rmarkdown::render("$<", output_format = "md_document", output_file = "$@")'
beliefs.md: beliefs.Rmd
	Rscript -e 'rmarkdown::render("$<", output_format = "md_document", output_file = "$@")'
clean:
	rm -rf languages_cache/ languages_files/
	rm -rf beliefs_cache/ beliefs_files/
	rm -rf data-blitz_cache/ data-blitz_files/
