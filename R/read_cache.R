
#' Read data previously saved with write_cache
#'
#' @param name Name of the object to read
#' @param path Path to the cache directory
#'
#' @seealso \link{write_cache}
#' @export
read_cache <- function(name, path) {
  if (!rlang::is_string(name)) {
    stop("`name` should be a string vector of length 1")
  }

  object_root <- file.path(path, name)
  if (!file.exists(file.path(object_root, ".cache_meta"))) {
    stop(glue("Could not find .cache_meta in {path}. Is this the correct path?"))
  }

  cache_version <- get_cache_version(object_root)
  if (cache_version <= "1.0.2") {
    stop(glue("cacheR version {current_version()} cannot read this old cache."))
  } else if (cache_version != current_version()) {
    warn(glue("Cache was created with cacheR version {cache_version} ",
              "but current cacheR install is version {current_version()}"))
  }

  read_cache_recursive(name, path)
}

#' Internal read_cache functions.
#'
#' `read_cache_recursive` reads a cache without any checks. Always used internally.
#' `read_cache` is the user-facing entry point, performing sense checks.
#'
#' @param name Name of sub-directory
#' @param path Root path
#' @seealso read_cache
#'
#' @rdname read_cache_recursive
read_cache_recursive <- function(name, path) {
  object_root <- file.path(path, name)
  type <- get_cache_type(object_root)
  reader <- get(paste0("read_cache_recursive.", type), mode = "function")
  reader(object_root)
}

read_cache_recursive.rds.gz <- function(path) {
  readr::read_rds(file.path(path, "object"))
}

#' @rdname read_cache_recursive
read_cache_recursive.list <- function(path) {
  meta <- get_cache_meta(path)

  # Identifying all elements (in numbered directories)
  elems <- list.dirs(path, recursive = FALSE, full.names = FALSE)
  elems <- elems[elems != ".attributes"]
  if (is.unsorted(elems)) {
    elems <- sort(elems)
  }

  out <- purrr::map(elems, read_cache_recursive, path = path)
  attributes(out) <- read_attributes(path)
  names(out) <- meta$names
  out
}

#' @rdname read_cache_recursive
read_cache_recursive.data.frame <- function(path) {
  out <- read_cache_recursive("data", path = path)
  meta <- get_cache_meta(path)
  attributes(out) <- read_attributes(path)
  names(out) <- meta$names
  class(out) <- meta$class
  out
}

#' @rdname read_cache_recursive
read_cache_recursive.character <-
  plaintext_reader(cast = as.character)

#' @rdname read_cache_recursive
read_cache_recursive.factor <-
  plaintext_reader(cast = as.integer)

#' @rdname read_cache_recursive
read_cache_recursive.numeric <-
  plaintext_reader(cast = as.numeric)

#' @rdname read_cache_recursive
read_cache_recursive.integer <-
  plaintext_reader(cast = as.integer)

#' @rdname read_cache_recursive
read_cache_recursive.logical <-
  plaintext_reader(cast = purrr::compose(int2logical, as.integer))

#' @rdname read_cache_recursive
read_cache_recursive.complex <-
  plaintext_reader(cast = as.complex)

