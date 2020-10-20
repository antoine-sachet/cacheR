test_that("int2logical and logical2int work", {
  objs <- list(
    TRUE,
    FALSE,
    NA,
    logical(0),
    rep(T, 10),
    rep(F, 10),
    rep(NA, 10),
    sample(c(T, F), 100, replace = TRUE),
    sample(c(T, F, NA), 100, replace = TRUE)
  )

  purrr::walk(objs, function(obj) {
    expect_equal(obj, int2logical(logical2int(obj)))
  })

})

test_that("inspect_cache runs", {
  path <- tempdir()
  teardown(unlink(path))

  write_cache(iris, path, overwrite = TRUE)
  expect_silent(inspect_cache(file.path(path, "iris")))
})
