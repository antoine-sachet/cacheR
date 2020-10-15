context("test-write_cache")


test_that("write_cache uses given file name", {
  path <- tempdir()
  teardown(unlink(path))

  write_cache(iris, path, name = "mtcars", overwrite = T)
  expect_equal(read_cache("mtcars", path), iris)
})

test_that("write_cache captures variable name if not given one", {
  path <- tempdir()
  teardown(unlink(path))

  write_cache(iris, path, overwrite = T)
  expect_equal(read_cache("iris", path), iris)
})

test_that("write_cache prompts to overwrite and overwrites when prompted", {
  path <- tempdir()
  teardown(unlink(path))

  write_cache(iris, path, name = "iris", overwrite = T)
  # Should refuse to overwrite without overwrite = T
  expect_error(write_cache(iris, path, name = "iris"), "overwrite")

  write_cache(mtcars, path, name = "iris", overwrite = T)
  # Should have overwritten with mtcars dataset
  expect_equal(read_cache("iris", path), mtcars)
})

test_that("write_cache returns data invisibly", {
  path <- tempdir()
  teardown(unlink(path))

  expect_invisible(write_cache(iris, path, name = "iris", overwrite = T))
  return_val <- write_cache(iris, path, name = "iris", overwrite = T)
  expect_equal(return_val, iris)
})

test_that("write_cache stores cache version in top level metadata", {
  path <- tempdir()
  teardown(unlink(path))

  write_cache(iris, path, name = "iris", overwrite = T)
  meta <- get_cache_meta(file.path(path, "iris"))
  expect_true("version" %in% names(meta))
  expect_true(rlang::is_scalar_character(meta[["version"]]))
})


