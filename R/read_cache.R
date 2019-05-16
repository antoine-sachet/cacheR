get_cache_meta <- function(path) {
  yaml::read_yaml(file.path(path, ".cache_meta"))
}

get_cache_type <- function(path) {
  meta <- get_cache_meta(path)
  return(meta$cache_type)
}


#' Read data previsouly saved with write_cache
#'
#' @param path Path (including object name)
#'
#' @export
read_cache <- function(path) {
  if (!file.exists(file.path(path, ".cache_meta"))) {
    stop("Could not find .cache_meta in {path}. Is this the correct path?")
  }
  type <- get_cache_type(path)
  reader <- get(paste0("read_cache.", type), mode = "function")
  reader(path)
}

#' Read attributes, if any, at the path.
read_attributes <- function(path) {
  attr_path <- file.path(path, ".attributes")
  if (exists(attr_path)) {
    out <- read_cache(attr_path)
  } else {
    out <- NULL
  }
  return(out)
}

read_cache.rds.gz <- function(path) {
  readr::read_rds(file.path(path, "object"))
}

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
