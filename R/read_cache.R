#' Read data previously saved with write_cache
#'
#' @param path Path (including object name)
#' @seealso \link{write_cache}
#' @export
read_cache <- function(path) {
  if (!file.exists(file.path(path, ".cache_meta"))) {
    stop("Could not find .cache_meta in {path}. Is this the correct path?")
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
  elems <- list.dirs(path, recursive = FALSE)
  if (is.unsorted(elems)) {
    elems <- sort(elems)
  }

  out <- purrr::map(elems,
             read_cache)
  attributes(out) <- read_attributes(path)
  names(out) <- meta$names
  out
}

#' @rdname read_cache_functions
read_cache.data.frame <- function(path) {
  out <- read_cache.list(file.path(path, "data"))
  meta <- get_cache_meta(path)
  attributes(out) <- read_attributes(path)
  names(out) <- meta$names
  class(out) <- meta$class
  out
}
