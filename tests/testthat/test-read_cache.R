context("test-read_cache")

check_inverse <- function(obj, path, name = "obj") {
  write_cache(obj, path, name = name, overwrite = TRUE)
  res <- read_cache(name, path)
  testthat::expect_equal(obj, res)
}

check_all_inverses <- function(objs) {
  path <- tempdir()
  teardown(unlink(path))
  if (is.null(names(objs))) {
    names(objs) <- paste("obj", 1:length(objs))
  }
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

test_that("Data.frame reader", {
  objs <- list(
    obj1 = mtcars,
    obj2 = iris,
    obj3 = tibble::as_tibble(iris),
    obj4 = data.frame(),
    obj5 = data.frame(a = character(0)),
    obj6 = tibble::tibble(),
    obj7 = dplyr::group_by(iris, Species),
    obj8 = dplyr::mutate(iris, Species = factor(Species))
  )
  check_all_inverses(objs)
})

test_that("Nested lists", {
  objs <- list(
    obj1 = list(mtcars, list(iris)),
    obj2 = list(list(), list()),
    obj3 = list(a = list(), list(c = list(), list())),
    obj4 = list(a = list(), letters = letters, list(c = list(1:10), list(), iris)),
    obj5 = list(model = lm(mpg ~ gear, data = mtcars), data = mtcars)
  )
  objs$all <- rlang::list2(!!! objs)
  check_all_inverses(objs)
})

test_that("Characters", {
  objs <- list(
    list(letters), # character
    list(purrr::set_names(letters, LETTERS)), # named character
    character(0),
    c(hello = "world", a = NA_character_),
    NA_character_
  )
  check_all_inverses(objs)
})


test_that("Factors", {
  objs <- list(
    list(factor(letters)), # factor
    list(factor(letters, levels = head(letters))), # factor with NAs
    factor(character(0))
  )
  check_all_inverses(objs)
})


test_that("Integers", {
  objs <- list(
    list(1:10),
    integer(0),
    NA_integer_,
    c(a = -1, b = NA_integer_)
  )
  check_all_inverses(objs)
})

test_that("Logicals", {
  objs <- list(
    c(TRUE, FALSE),
    c(TRUE, FALSE, NA),
    c(a = TRUE, b = FALSE, c = NA),
    logical(0)
  )
  check_all_inverses(objs)
})
