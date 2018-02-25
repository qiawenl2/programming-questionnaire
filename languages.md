# Top languages

``` r
source("R/sqlite.R")
languages <- collect_table("languages")
```

| subj\_id           | language\_ix | response\_str | age\_started | years\_used | proficiency |
| :----------------- | -----------: | :------------ | -----------: | ----------: | ----------: |
| R\_02lGHY18refVcJj |            1 | javascript    |           30 |          20 |           5 |
| R\_02lGHY18refVcJj |            2 | perl          |           30 |          15 |           4 |
| R\_02lGHY18refVcJj |            3 | ocaml         |           47 |           3 |           4 |
| R\_02lGHY18refVcJj |            4 | java          |           38 |           7 |           3 |
| R\_02lGHY18refVcJj |            5 | haskell       |           47 |           3 |           4 |
| R\_08jNDkIvkIto1tT |            1 | c             |           18 |           8 |           5 |

![](languages_files/figure-gfm/top-languages-1.png)<!-- -->

# Language ratings

``` r
language_ratings <- collect_table("language_ratings")
```

| subj\_id           | question\_str                      | question\_name | language\_ix | language\_name | question\_tag | response\_str  |
| :----------------- | :--------------------------------- | :------------- | -----------: | :------------- | :------------ | :------------- |
| R\_3n0mQhZotJ0IGZS | intuitiveness\#1\_Language1\_forMe | intuitiveness  |            1 | smalltalk      | forMe         | Strongly agree |
| R\_WwblriWUfI0hh5v | intuitiveness\#1\_Language1\_forMe | intuitiveness  |            1 | smalltalk      | forMe         | Somewhat agree |
| R\_ymO3u2gi12sTZKN | intuitiveness\#1\_Language1\_forMe | intuitiveness  |            1 | clojure        | forMe         | Somewhat agree |
| R\_1jDNLC64x5r0M4d | intuitiveness\#1\_Language1\_forMe | intuitiveness  |            1 | java           | forMe         | Strongly agree |
| R\_1eKT4RBIDttcK1R | intuitiveness\#1\_Language1\_forMe | intuitiveness  |            1 | c++            | forMe         | Strongly agree |
| R\_u2IJAfvjtX3j8Kl | intuitiveness\#1\_Language1\_forMe | intuitiveness  |            1 | python         | forMe         | Strongly agree |

## Intuitiveness

    ## Joining, by = "response_str"

![](languages_files/figure-gfm/intuitiveness-1.png)<!-- -->
