#' @title Read and write cache meta and type.
#' @rdname cache_meta
#' @param path Directory
get_cache_meta <- function(path) {
  yaml::read_yaml(file.path(path, ".cache_meta"))
}

#' @rdname cache_meta
get_cache_type <- function(path) {
  meta <- get_cache_meta(path)
  return(meta$cache_type)
}

#' @rdname cache_meta
#' @param meta Metadata object (named list)
set_cache_meta <- function(path, meta) {
  yaml::write_yaml(meta, file.path(path, ".cache_meta"))
}
