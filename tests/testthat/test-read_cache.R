context("test-read_cache")

check_inverse <- function(obj, path, name = "obj") {
  write_cache(obj, path, name = name, overwrite = TRUE)
  res <- read_cache(file.path(path, name))
  testthat::expect_equal(obj, res)
}

check_all_inverses <- function(objs) {
  path <- tempdir()
  teardown(unlink(path))
  purrr::imap(objs, function(obj, name) {
    check_inverse(obj, path, name)
  })
}

test_that("Default reader", {
  objs <- list(
    obj1 = 1:10,
    obj2 = lm(mpg ~gear, mtcars)
  )
  check_all_inverses(objs)
})


test_that("List reader", {
  objs <- list(
    obj1 = list(1, 2, 3),
    obj2 = list(a = letters, b = 1),
    obj3 = list()
  )
  check_all_inverses(objs)
})
