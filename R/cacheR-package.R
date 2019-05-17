#' @keywords internal
#' @import dplyr
#' @import tibble
#' @import rlang
#' @importFrom glue glue
#' @importFrom purrr map
#' @importFrom readr read_rds write_rds read_csv write_csv
#' @importFrom yaml write_yaml read_yaml
#'
#' @seealso \link{write_cache} \link{read_cache}
#'
#' @examples
#' library("cacheR")
#' path <- tempdir()
#'
#' my_data <-
#'   list(data = mtcars,
#'        model = lm(mpg ~ gear, data = mtcars),
#'        details = list(date = "2030-01-01",
#'                       version = "1.2"))
#'
#' write_cache(my_data, path)
#'
#' cache <- read_cache("my_data", path)
#'
#' all.equal(my_data, cache)
#' # TRUE, of course!
#'
#' unlink(path)
"_PACKAGE"
