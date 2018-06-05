qualtrics := data-raw/qualtrics.csv data-raw/questions.csv data-raw/responses.csv
survey := data-raw/languages.csv data-raw/language-ratings.csv data-raw/questionnaire.csv data-raw/demographics.csv data-raw/irq.csv
languages := data-raw/language-paradigms.csv data-raw/stack-overflow.csv data-raw/stack-overflow-ranks.csv

.PHONY: neo4j rdata

all: programming-questionnaire.sqlite rdata docs/languages.md docs/beliefs.md

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

rdata: bin/rdata.R $(qualtrics) $(survey) $(languages)
	./bin/rdata.R --install

neo4j: bin/neo4j.R
	./bin/neo4j.R --clear

docs/languages.md: docs/languages.Rmd
	Rscript -e 'rmarkdown::render("$<", output_format = "md_document")'
docs/beliefs.md: docs/beliefs.Rmd
	Rscript -e 'rmarkdown::render("$<", output_format = "md_document")'
clean:
	rm -f docs/languages.md docs/beliefs.md
	rm -f programming-questionnaire.sqlite
	rm -rf ${qualtrics} ${survey} ${languages} data/*.rda
	rm -rf docs/languages_cache/ docs/languages_files/
	rm -rf docs/beliefs_cache/ docs/beliefs_files/
