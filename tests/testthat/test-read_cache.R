context("test-read_cache")

check_inverse <- function(obj, path, name = "obj") {
  write_cache(obj, path, name = name, overwrite = TRUE)
  res <- read_cache(name, path)
  testthat::expect_equal(obj, res,
                         label = glue("{name}: written and read objects should match"))
}

check_all_inverses <- function(objs) {
  path <- tempdir()
  on.exit(unlink(path))

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

test_that("List with attributes", {
  li1 <- li2 <- list(1, 2, 3)
  attr(li1, "test") <- TRUE
  attr(li2, "nested") <- li1

  objs <- list(
    li1 = li1,
    li2 = li2
  )
  check_all_inverses(objs)
})

test_that("Data.frame reader", {
  objs <- list(
    mtcars = mtcars,
    iris = iris,
    iris_tbl = tibble::as_tibble(iris),
    df_empty1 = data.frame(),
    df_empty2 = data.frame(a = character(0)),
    df_empty3 = data.frame(a = character(0), b = numeric(0), c = integer(0)),
    tbl_empty1 = tibble::tibble(),
    tbl_empty2 = tibble::tibble(a = character(0), b = numeric(0), c = integer(0)),
    df_grouped = dplyr::group_by(iris, Species),
    iris_fac = dplyr::mutate(iris, Species = factor(Species))
  )
  check_all_inverses(objs)
})

test_that("read_cache handles all data types", {
  list_all_types  <- list(
    char = letters,
    int  = 1:26,
    num  = 1:26 + 0.5,
    num2 = 1:26 + pi,
    lgl  = sample(c(TRUE, FALSE), 26, replace = TRUE),
    cplx = 1:26 + 1i,
    cplx2 = 1:26 + pi + pi * 1i,
    raw  = purrr::map_raw(letters, charToRaw),
    expr = lapply(letters,
                  function(letter) substitute(expression(x), list(x = letter))),
    sym  = rlang::syms(letters),
    null = purrr::map(letters, ~ NULL),
    fct  = purrr::map(letters, ~ function() .x),
    builtin = purrr::map(letters, ~ `c`),
    env  = purrr::map(letters, ~ as.environment(list(x = .x))),
    list = purrr::map(letters, list)
  )

  tbl_all_types <- tibble::as_tibble(list_all_types)

  objs <- list(
    list_all_types = list_all_types,
    tbl_all_types = tbl_all_types
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


test_that("Characters with new line", {
  objs <- list(
    obj1 = "line1
            line2"
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

test_that("Nested df and list-columns", {
  expect_true(requireNamespace("tidyr", quietly = TRUE))
  objs <- list(
    nested_df =
      iris %>%
      group_by(Species) %>%
      tidyr::nest() %>%
      mutate(model = purrr::map(data, lm, formula = Sepal.Length ~ .))
  )
  check_all_inverses(objs)
})

test_that("read_cache should fail gracefully if an invalid name is passed", {
  testthat::expect_error(cacheR::read_cache(1:3, tempdir()),
                         regexp = "should be a string vector")
  testthat::expect_error(cacheR::read_cache("non_existing_object", tempdir()),
                         regexp = "does not look like a cached object")
})

test_that("read_cache should fail to read cache with no version", {
  path <- tempdir()
  teardown(unlink(path))

  # Simulate a cache with no version
  write_cache(iris, path, overwrite = TRUE)
  cache_meta <- get_cache_meta(file.path(path, "iris"))
  cache_meta$version <- NULL
  set_cache_meta(file.path(path, "iris"), cache_meta)

  testthat::expect_error(cacheR::read_cache("iris", path),
                         regexp = "version")
})

test_that("read_cache should warn on version mismatch", {
  path <- tempdir()
  teardown(unlink(path))

  # Simulate a cache with no version
  write_cache(iris, path, overwrite = TRUE)
  cache_meta <- get_cache_meta(file.path(path, "iris"))
  cache_meta$version <- "9.9.9"
  set_cache_meta(file.path(path, "iris"), cache_meta)

  testthat::expect_warning(cacheR::read_cache("iris", path),
                           regexp = "version")
})

test_that("Character vector with empty strings", {
  objs <- list(
    str1 = c("hello", "", "", "bye"),
    df1 = tibble::tibble(str = c("hello", "", "")),
    df2 = tibble::tibble(str = c("", "", "bye")),
    df3 = tibble::tibble(str = c("hello", "", "bye"))
  )
  check_all_inverses(objs)
})
