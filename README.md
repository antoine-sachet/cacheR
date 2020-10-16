# cacheR

<!-- badges: start -->
  [![Travis build status](https://travis-ci.org/antoine-sachet/cacheR.svg?branch=master)](https://travis-ci.org/antoine-sachet/cacheR)
  [![Codecov test coverage](https://codecov.io/gh/antoine-sachet/cacheR/branch/master/graph/badge.svg)](https://codecov.io/gh/antoine-sachet/cacheR?branch=master)
<!-- badges: end -->

The goal of cacheR is to provide I/O functions to save data in named lists to disk in a robust and git-friendly way.

When I deploy shiny apps, I typically need to deploy some data along with it.

The alternatives I have used are:
- an external DB: this can be slow and requires somehow passing or storing sensitive credentials in the app.
- tabular plaintext formats such as CSV: this works fine for data.frame objects, but requires robust readers to ensure data integrity. When the data is already in a DB, it is a waste of time to export it to csv and write readers! It is also not adapted for non-tabular data or complex (e.g. nested) tabular data.
- RDS format to save any kind of objects. Well, yes! For a one-off data dump, you totally could use RDS and in fact the RDS format is used extensively within `cacheR`. To git however, this is a binary file. If you need to regularly update your data, the git repository can grow very quickly! Using plaintext when possible leverages the delta power of git.


`cacheR` is a compromise: it saves data in a directory arborescence whose nodes are either RDS or plaintext files. Lists are broken down in directories/subdirectories. Atomic vectors (character, numeric, factor, logical, integer) are stored in plaintext. Other data types are stored in RDS files.

Data.frames are treated as a special case of lists. Columns can be stored in plaintext, in RDS or in subdirectories, depending on their types. This means hybrid tibbles with nested list, nested data.frames and any other non-standard column types work just fine! All attributes are preserved, so you get back exactly what you saved, including groups, row names if any, etc. 

## Installation

You can install the development version of cacheR from [github](https://github.com/antoine-sachet/cacheR) with:

``` r
remotes::install_github("antoine-sachet/cacheR")
```

## Example

This is a basic example which shows you how to store and retrieve some data.

``` r
library("cacheR")

my_data <- 
  list(data = mtcars, 
       model = lm(mpg ~ gear, data = mtcars),
       details = list(date = "2030-01-01", 
                      version = "1.2"))
                      
# Note the directory must exist
write_cache(my_data, path = "./cache")

cache <- read_cache("my_data", path = "./cache")

all.equal(my_data, cache)
# TRUE, of course!
```

This is an example of data where cacheR really shines.

You could not store easily as (mostly) plaintext without cacheR.

```r
# Let's build a nested data.frame with non-standard column types.

library("cacheR")
library("dplyr")
library("tidyr")

df <- iris %>%
  group_by(Species) %>%
  nest() %>%
  mutate(model = purrr::map(data, lm, formula = Sepal.Length ~ .))
  
# Talk about a non-standard data.frame!
df
# # A tibble: 3 x 3
#   Species    data              model   
#   <fct>      <list>            <list>  
# 1 setosa     <tibble [50 × 4]> <S3: lm>
# 2 versicolor <tibble [50 × 4]> <S3: lm>
# 3 virginica  <tibble [50 × 4]> <S3: lm>

# Saving it in a temporary directory
path <- tempdir()
write_cache(df, path, name = "nested_iris")

# You can have a look at all the files in the cache
# Most of the data is stored in plaintext, with the exception of the `lm` models.
inspect_cache(path)

df_cached <- read_cache("nested_iris", path)

# # A tibble: 3 x 3
#   Species    data              model   
# * <fct>      <list>            <list>  
# 1 setosa     <tibble [50 × 4]> <S3: lm>
# 2 versicolor <tibble [50 × 4]> <S3: lm>
# 3 virginica  <tibble [50 × 4]> <S3: lm>
```

