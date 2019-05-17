#' Read data previously saved with write_cache
#'
#' @param name Name of the object to read
#' @param path Path to the cache directory
#'
#' @seealso \link{write_cache}
#' @export
read_cache <- function(name, path) {
  path <- file.path(path, name)
  if (!file.exists(file.path(path, ".cache_meta"))) {
    stop(glue("Could not find .cache_meta in {path}. Is this the correct path?"))
  }
  type <- get_cache_type(path)
  reader <- get(paste0("read_cache.", type), mode = "function")
  reader(path)
}

#' @rdname read_cache_functions
#' @title Internal read_cache functions.
#' @description This functions are called by `read_cache` when appropriate.
#' @param path Path (including object name)
#' @seealso read_cache
read_cache.rds.gz <- function(path) {
  readr::read_rds(file.path(path, "object"))
}

#' @rdname read_cache_functions
read_cache.list <- function(path) {
  meta <- get_cache_meta(path)

  # Identifying all elements (in numbered directories)
  elems <- list.dirs(path, recursive = FALSE, full.names = FALSE)
  if (is.unsorted(elems)) {
    elems <- sort(elems)
  }

  out <- purrr::map(elems,
             read_cache, path = path)
  attributes(out) <- read_attributes(path)
  names(out) <- meta$names
  out
}

#' @rdname read_cache_functions
read_cache.data.frame <- function(path) {
  out <- read_cache("data", path = path)
  meta <- get_cache_meta(path)
  attributes(out) <- read_attributes(path)
  names(out) <- meta$names
  class(out) <- meta$class
  out
}

#' @rdname read_cache_functions
read_cache.character <- function(path) {
  out <- readr::read_lines(file.path(path, "object"))
  meta <- get_cache_meta(path)
  attributes(out) <- read_attributes(path)
  class(out) <- meta$class
  out
}

