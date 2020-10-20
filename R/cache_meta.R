#' @title Read and write cache meta and type.
#' @rdname cache_meta
#' @param path Directory
get_cache_meta <- function(path) {
  yaml::read_yaml(file.path(path, "cache_meta"))
}

#' @rdname cache_meta
#' @param meta Named list to write in metadata file
set_cache_meta <- function(path, meta) {
  yaml::write_yaml(meta, file.path(path, "cache_meta"))
}

#' @rdname cache_meta
#' @param ... Named arguments to be added in meta file
update_cache_meta <- function(path, ...) {
  meta_file <- file.path(path, "cache_meta")

  dots <- rlang::list2(...)
  if (!rlang::is_named(dots)) {
    stop("Arguments must be named in update_cache_meta")
  }

  if (!file.exists(meta_file)) {
    set_cache_meta(path, dots)
  } else {
    current_meta <- yaml::read_yaml(meta_file)

    # Merging with current_meta first to keep KEY order
    keys <- unique(names(c(current_meta, dots)))
    # Merging with dots first so it overrides current_meta on duplicate keys
    merged <- c(dots, current_meta)
    # Deduplicating
    merged <- merged[keys]
    set_cache_meta(path, merged)
  }
}

#' @rdname cache_meta
get_cache_type <- function(path) {
  meta <- get_cache_meta(path)
  meta$cache_type
}

#' @rdname cache_meta
get_cache_version <- function(path) {
  meta <- get_cache_meta(path)
  if ("version" %in% names(meta)) {
    meta[["version"]]
  } else "1.0.2" # last version without cache_version
}

#' Get current cacheR version
#' @noRd
current_version <- function() {
  unname(getNamespaceVersion("cacheR"))
}

#' Check if directory contains a cached object
#' Simply checking the existence of cache_meta.
#' @param path Directory to check
is_cached_object <- function(path) {
  file.exists(file.path(path, "cache_meta"))
}
