# cacheR

The goal of cacheR is to provide I/O functions to save data in named lists to disk in a robust and git-friendly way.

When I deploy shiny apps, I typically need to deploy some data along with it.

Until now, I have used:
- an external DB: this can be slow and requires somehow passing or storing sensitive credentials to the app.
- tabular plaintext formats: this works fine for data.frame objects, but requires robust readers to ensure data quality. When the data is already in a DB, it is a waste of time to export it to csv and write readers! It is also not adapted for non-tabular data.
- RDS format to save any kind of objects! Well, yes! For a one-off data dump, you should use RDS and in fact the RDS format is used extensively by cacheR. To git however, this is a binary file. If you need to regularly update your data, the git repository can grow very quickly!

`cacheR` saves any list in a directory arborescence whose nodes are either RDS or plaintext files. All attributes are preserved, so you get back exactly what you saved.

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
write_cache(my_data, "./cache")

cache <- read_cache("./cache/my_data")

all.equal(my_data, cache)
# TRUE, of course!
```

