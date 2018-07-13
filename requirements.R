# Set CRAN mirror so this can be run as a script
repos <- getOption("repos")
repos["CRAN"] <- "https://cran.rstudio.com/"
options(repos = repos)

install.packages("tidyverse")
install.packages("qualtRics")
install.packages("WikidataR")
install.packages("RSQLite")
install.packages("ggridges")
install.packages("patchwork")
