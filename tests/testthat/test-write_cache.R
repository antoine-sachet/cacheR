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


