#' Create a directory if it does not already exist.
#'
#' Create the directory or does nothing it it already exists.
#' Stops with an error if the directory creation fails.
#'
#' @return TRUE on success
#' @param dir Directory to create
create_if_needed <- function(dir) {
  if (dir.exists(dir)) {
    return(TRUE)
  }
  status <- dir.create(dir, showWarnings = FALSE, recursive = TRUE)
  if (!status) {
    stop(glue("Failed to create directory {dir}"))
  }
  status
}

#' Show all files in a cached object.
#'
#' A simple wrapper around list.files.
#' Useful for debugging.
#'
#' @param path Path to a stored object.
#'
#' @export
inspect_cache <- function(path) {
  list.files(path, recursive = TRUE, all.files = TRUE)
}
