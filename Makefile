qualtrics := data-raw/qualtrics.csv data-raw/questions.csv data-raw/responses.csv
survey := data-raw/languages.csv data-raw/language-ratings.csv data-raw/questionnaire.csv data-raw/demographics.csv data-raw/irq.csv
languages := data-raw/language-paradigms.csv data-raw/stack-overflow.csv data-raw/stack-overflow-ranks.csv

.PHONY: neo4j

all: qualtrics survey languages

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
beliefs.md: beliefs.Rmd
%.md: %.Rmd _output.yml
	Rscript -e 'rmarkdown::render("$<", output_file = "$@")'
clean:
	rm -rf languages.md beliefs.md *_cache/ *_files/
