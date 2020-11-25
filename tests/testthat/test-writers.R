context("test-writers")

check_dir_contains <- function(path, name, expected_content) {
  files_in_dir <- list.files(file.path(path, name), recursive = TRUE, all.files = TRUE)
  testthat::expect_setequal(
    files_in_dir,
    expected_content)
}

check_objs <- function(objs, expected_content) {
  path <- tempdir()
  teardown(unlink(path))
  purrr::imap(objs, function(obj, name) {
    write_cache(obj, path, name = name, overwrite = TRUE)
    check_dir_contains(path, name, expected_content)
  })
}

test_that("Default method", {
  expected_content <- c("cache_meta", "object")
  objs <- list(
    mtcars = lm(mpg ~ gear, data = mtcars),
    letters = letters,
    num = 1:10,
    a = 1
  )
  check_objs(objs, expected_content)
})

test_that("List method", {
  expected_content <- c("cache_meta",
                        "1/cache_meta", "1/object",
                        "2/cache_meta", "2/object")

  objs <- list(
    obj1 = list(a = letters, b = LETTERS),
    obj2 = list(letters, LETTERS),
    obj3 = list(1, 1)
  )

  check_objs(objs, expected_content)
})

test_that("List method for long lists", {
  expected_content <- c("cache_meta",
                        purrr::flatten_chr(
                          purrr::map(1:9, ~ paste0("0", ., c("/cache_meta", "/object")))),
                        "10/cache_meta", "10/object")

  objs <- list(
    obj1 = as.list(1:10),
    obj2 = purrr::map(1:10, ~ letters)
  )

  check_objs(objs, expected_content)
})

test_that("List with attributes", {
  expected_content <- c("cache_meta",
                        purrr::flatten_chr(
                          purrr::map(1:3, ~ paste0(., c("/cache_meta", "/object")))))
  # Same thing in /.attributes
  expected_attributes <- c("attr/cache_meta",
                           paste0("attr/1/", expected_content))

  li <- list(1, "2", FALSE)
  attr(li, "test") <- li
  objs <- list(
    list_attr = li
  )

  check_objs(objs, c(expected_content, expected_attributes))
})


test_that("Data.frame method", {
  expected_content <- c("cache_meta",
                        # DFs and tibbles have 1 attribute (class)
                        "attr/cache_meta",
                        "attr/1/cache_meta",
                        "attr/1/object",
                        # Columns are stored in a list in data/
                        "data/cache_meta",
                        purrr::flatten_chr(
                          purrr::map(1:4, ~ paste0("data/", ., c("/cache_meta", "/object")))),
                        # The factor has attributes
                        "data/4/attr/cache_meta",
                        "data/4/attr/1/cache_meta",
                        "data/4/attr/1/object")

  objs <- list(
    df = data.frame(a = 1, b = "char", c = FALSE, d = factor("fac"), stringsAsFactors = F),
    tbl = tibble(a = 1, b = "char", c = FALSE, d = factor("fac"))
  )

  check_objs(objs, expected_content)
})

test_that("Character method", {
  expected_content <- c("cache_meta",
                        "object")

  objs <- list(str1 = "Hello",
               str2 = c("Hello", "Bye"),
               str3 = c("Hello", "Bye", ""),
               empty_str = character(0))

  check_objs(objs, expected_content)
})
