languages.md: languages.Rmd _output.yml
%.md: %.Rmd
	Rscript -e 'rmarkdown::render("$<", output_file = "$@")'
clean:
	rm -rf *.md *_cache/ *_files/