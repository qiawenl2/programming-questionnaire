all: languages.md questionnaire.md
languages.md: languages.Rmd
questionnaire.md: questionnaire.Rmd
%.md: %.Rmd _output.yml
	Rscript -e 'rmarkdown::render("$<", output_file = "$@")'
clean:
	rm -rf *.md *_cache/ *_files/