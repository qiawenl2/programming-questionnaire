# Questions

``` r
source("R/sqlite.R")
questionnaire <- collect_table("questionnaire")
head(questionnaire)
```

    ## # A tibble: 6 x 20
    ##   subj_id        cr1   cr2   cp1 repo1  rec1  cfo1  cfo2  cfo3  oss1  oss2
    ##   <chr>        <int> <int> <int> <int> <int> <int> <int> <int> <int> <int>
    ## 1 R_02lGHY18r…     4    NA     4     4     5     1     4    NA     2    NA
    ## 2 R_08jNDkIvk…     5    NA     3     2     3     3     4    NA     3    NA
    ## 3 R_09cRnr92g…    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA
    ## 4 R_0ctalwcZi…    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA
    ## 5 R_0OQ4IaRWO…    NA    NA    NA    NA    NA    NA    NA    NA    NA    NA
    ## 6 R_0PUV8ogrj…     3    NA    NA    NA    NA    NA    NA    NA    NA    NA
    ## # ... with 9 more variables: env1 <int>, env2 <int>, inter1 <int>, inter2
    ## #   <int>, inter3 <int>, cr1describe <chr>, cp1describe <chr>,
    ## #   repo1describe <chr>, rec1describe <chr>
