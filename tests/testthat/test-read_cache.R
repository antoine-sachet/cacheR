context("test-read_cache")

check_inverse <- function(obj, path, name = "obj") {
  write_cache(obj, path, name = name, overwrite = TRUE)
  res <- read_cache(file.path(path, name))
  testthat::expect_equal(obj, res)
}

test_that("Data.frame reader", {
  path <- tempdir()
  teardown(unlink(path))

  check_inverse(mtcars, path)
})


test_that("List reader", {
  path <- tempdir()
  teardown(unlink(path))

  objs <- list(
    obj1 = list(1, 2, 3),
    obj2 = list(a = letters, b = 1),
    obj3 = list()
  )
  purrr::imap(objs, function(obj, name) {
    check_inverse(obj, path, name)
  })
})
