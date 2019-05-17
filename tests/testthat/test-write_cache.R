context("test-write_cache")

check_dir_contains <- function(path, name, expected_content) {
  testthat::expect_setequal(
    list.files(file.path(path, name), recursive = TRUE, all.files = TRUE),
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
  expected_content <- c(".cache_meta", "object")
  objs <- list(
    mtcars = lm(mpg ~ gear, data = mtcars),
    letters = letters,
    num = 1:10,
    a = 1
  )
  check_objs(objs, expected_content)
})

test_that("List method", {
  expected_content <- c(".cache_meta",
                        "1/.cache_meta", "1/object",
                        "2/.cache_meta", "2/object")

  objs <- list(
    obj1 = list(a = letters, b = LETTERS),
    obj2 = list(letters, LETTERS),
    obj3 = list(1, 1)
  )

  check_objs(objs, expected_content)
})

test_that("List method for long lists", {
  expected_content <- c(".cache_meta",
                        purrr::flatten_chr(
                          purrr::map(1:9, ~ paste0("0", ., c("/.cache_meta", "/object")))),
                        "10/.cache_meta", "10/object")

  objs <- list(
    obj1 = as.list(1:10),
    obj2 = purrr::map(1:10, ~ letters)
  )

  check_objs(objs, expected_content)
})


test_that("Data.frame method", {
  expected_content <- list(
    obj1 = c(".attributes/.cache_meta", ".attributes/1/.cache_meta", ".attributes/1/object",
             ".cache_meta", "data/.cache_meta", "data/01/.cache_meta", "data/01/object",
             "data/02/.cache_meta", "data/02/object", "data/03/.cache_meta",
             "data/03/object", "data/04/.cache_meta", "data/04/object", "data/05/.cache_meta",
             "data/05/object", "data/06/.cache_meta", "data/06/object", "data/07/.cache_meta",
             "data/07/object", "data/08/.cache_meta", "data/08/object", "data/09/.cache_meta",
             "data/09/object", "data/10/.cache_meta", "data/10/object", "data/11/.cache_meta",
             "data/11/object"),
    obj2 = c(".attributes/.cache_meta", ".attributes/1/.cache_meta", ".attributes/1/object",
             ".cache_meta", "data/.cache_meta", "data/1/.cache_meta", "data/1/object",
             "data/2/.cache_meta", "data/2/object", "data/3/.cache_meta",
             "data/3/object", "data/4/.cache_meta", "data/4/object", "data/5/.cache_meta",
             "data/5/object")
  )
  expected_content$obj3 <- expected_content$obj2

  objs <- list(
    obj1 = mtcars,
    obj2 = iris,
    obj3 = tibble::as_tibble(iris)
  )

  purrr::map2(objs, expected_content,
              function(obj, expc) check_objs(list(obj = obj), expc))

})

