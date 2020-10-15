
check_metas <- function(metas) {
  path <- tempdir(check = TRUE)
  teardown(unlink(path))
  purrr::iwalk(metas, function(meta, label) {
    expect_silent(set_cache_meta(path, meta))
    expect_equal(get_cache_meta(path), meta, label = label)
  })
}

test_that("set_cache_meta and get_cache_meta work", {

  metas <- list(
    meta1 = list(a = "1", b = "2"),
    meta2 = list(a = 1:10, b = 0.23),
    meta3 = list(class = c("tbl", "data.frame")),
    meta4 = list(class = c("tbl", "data.frame"),
                 names = c("a", "b", "c"))
  )

  check_metas(metas)
})


test_that("update_cache_meta works", {

  path <- tempdir(check = TRUE)
  teardown(unlink(path))

  set_cache_meta(path, list(a = 1, b = 2))
  update_cache_meta(path, c = 3)

  expect_equal(get_cache_meta(path), list(a = 1, b = 2, c = 3))
})


test_that("update_cache_meta overrides existing variables", {

  path <- tempdir(check = TRUE)
  teardown(unlink(path))

  set_cache_meta(path, list(a = 1, b = 2, c = 3))
  update_cache_meta(path, b = "b")

  expect_equal(get_cache_meta(path), list(a = 1, b = "b", c = 3))
})

test_that("update_cache_meta follows given order", {

  path <- tempdir(check = TRUE)
  teardown(unlink(path))

  set_cache_meta(path, list(b = 2, c = 3))
  update_cache_meta(path, b = "b", d = 4, a = "a")

  expect_equal(get_cache_meta(path), list(b = "b", c = 3, d = 4, a = "a"))
})


