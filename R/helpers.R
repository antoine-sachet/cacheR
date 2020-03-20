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

#' Show all files in a stored object.
#'
#' A simple convenience function, useful for debugging.
#'
#' @param path Path to a stored object.
#'
#' @export
inspect_cache <- function(path) {
  if (requireNamespace("data.tree", quietly = TRUE)) {
    files <- list.files(path, recursive = TRUE, all.files = TRUE, include.dirs = TRUE, full.names = TRUE)
    data.tree::as.Node(data.frame(pathString = files))
  } else {
    message("Optional: install the 'data.tree' package to print a directory tree. Defaulting to file listing instead.")
    list.files(path, recursive = TRUE, all.files = TRUE)
  }
}
