#' @title Plaintext reader and writer
#' @rdname plaintext_writer
#'
#' @param type cache_type to write
#' @param cast Optional cast function when reading or writing.
#' @param cast_args Optional extra arguments to the cast function.
plaintext_writer <- function(type,
                             cast = function(x) x,
                             cast_args = list()) {
  function(x, path, ...) {
    meta <- list(
      cache_type = type,
      class = class(x)
    )
    set_cache_meta(path, meta)
    # Saving names in attributes rather than meta in case it is long
    write_attributes(x, path, exclude = "class")
    x_cast <- rlang::exec(cast, x, !!! cast_args)
    readr::write_csv(data.frame(x = x_cast), file.path(path, "object"),
                     na = "__NA__")
  }
}

#' @rdname plaintext_writer
plaintext_reader <- function(cast = function(x) x) {
  function(path) {
    out <- readr::read_csv(file.path(path, "object"),
                           col_types = readr::cols(x = readr::col_character()),
                           skip_empty_rows = FALSE, na = "__NA__",
                           quoted_na = FALSE)
    out <- cast(out[["x"]])
    meta <- get_cache_meta(path)
    attributes(out) <- read_attributes(path)
    class(out) <- meta$class
    out
  }
}

#' Logical / Integer conversion
#'
#' (TRUE, FALSE, NA) <-> (1, 0, NA)
#'
#' @param vec Logical or integer vector to convert
logical2int <- function(vec) {
  if_else(vec, 1L, 0L)
}

#' @describeIn logical2int Integer (0, 1, NA) to Logical (FALSE, TRUE, NA)
int2logical <- function(vec) {
  c(FALSE, TRUE)[vec + 1L]
}
