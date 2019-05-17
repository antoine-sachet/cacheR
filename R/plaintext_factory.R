#' @title Plaintext reader and writer factories
#' @rdname plaintext_factory
#' @param type cache_type to write
#' @param cast cast function (from character)
plaintext_writer_factory <- function(type, cast = function(x) x) {
  function(x, path, ...) {
    meta <- list(
      cache_type = type,
      class = class(x)
    )
    set_cache_meta(path, meta)
    # Saving names in attributes rather than meta in case it is long
    write_attributes(x, path, exclude = "class")
    readr::write_lines(cast(x), path = file.path(path, "object"))
  }
}

#' @rdname plaintext_factory
plaintext_reader_factory <- function(cast = function(x) x) {
  function(path) {
    out <- readr::read_lines(file.path(path, "object"))
    out <- cast(out)
    meta <- get_cache_meta(path)
    attributes(out) <- read_attributes(path)
    class(out) <- meta$class
    out
  }
}
